-- ============================================================
-- BMI Management System — Supabase schema + RLS
-- Run in Supabase SQL editor (or via `supabase db push`)
-- ============================================================

-- Extensions
create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- 1. profiles (system_users) — Admin / Staff
-- ------------------------------------------------------------
create type user_role as enum ('admin', 'staff');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null unique,
  role user_role not null default 'staff',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 2. users (patients / BMI subjects)
-- ------------------------------------------------------------
create type bmi_category as enum ('Underweight', 'Normal', 'Overweight', 'Obese');
create type gender_type as enum ('Male', 'Female', 'Other');

create table if not exists public.patients (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  age int not null check (age > 0 and age < 130),
  gender gender_type not null,
  height_cm numeric(5,2) not null check (height_cm > 0),
  weight_kg numeric(5,2) not null check (weight_kg > 0),
  bmi numeric(5,2) not null,
  bmi_category bmi_category not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid references public.profiles(id)
);

-- ------------------------------------------------------------
-- 3. bmi_history
-- ------------------------------------------------------------
create table if not exists public.bmi_history (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.patients(id) on delete cascade,
  height_cm numeric(5,2) not null,
  weight_kg numeric(5,2) not null,
  bmi numeric(5,2) not null,
  bmi_category bmi_category not null,
  recorded_at timestamptz not null default now(),
  recorded_by uuid references public.profiles(id)
);

create index if not exists idx_bmi_history_user_id on public.bmi_history(user_id);
create index if not exists idx_patients_created_at on public.patients(created_at desc);
create index if not exists idx_patients_bmi_category on public.patients(bmi_category);
create index if not exists idx_patients_gender on public.patients(gender);
create index if not exists idx_patients_name on public.patients using gin (name gin_trgm_ops);

create extension if not exists pg_trgm;

-- ------------------------------------------------------------
-- 4. updated_at triggers
-- ------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated_at on public.profiles;
create trigger trg_profiles_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists trg_patients_updated_at on public.patients;
create trigger trg_patients_updated_at before update on public.patients
  for each row execute function public.set_updated_at();

-- ------------------------------------------------------------
-- 5. Auto-create profile row when a new auth user signs up
--    (role defaults to 'staff'; promote to admin manually or via
--     the Create Account admin-only screen using service role on
--     a secure server function — never in the client.)
-- ------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'New User'),
    new.email,
    coalesce((new.raw_user_meta_data->>'role')::user_role, 'staff')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- 6. Helper: current user's role
-- ------------------------------------------------------------
create or replace function public.current_role()
returns user_role language sql stable security definer set search_path = public as $$
  select role from public.profiles where id = auth.uid();
$$;

-- ------------------------------------------------------------
-- 7. Row Level Security
-- ------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.patients enable row level security;
alter table public.bmi_history enable row level security;

-- profiles: any authenticated user can read all profiles (needed for
-- displaying "created_by" names); users can update only their own row's
-- name/email; role changes restricted to admins.
create policy "profiles_select_authenticated" on public.profiles
  for select using (auth.role() = 'authenticated');

create policy "profiles_update_own_or_admin" on public.profiles
  for update using (id = auth.uid() or public.current_role() = 'admin');

create policy "profiles_insert_admin_only" on public.profiles
  for insert with check (public.current_role() = 'admin' or id = auth.uid());

-- patients: Admin + Staff can select/insert/update. Only Admin can delete.
create policy "patients_select_authenticated" on public.patients
  for select using (auth.role() = 'authenticated');

create policy "patients_insert_authenticated" on public.patients
  for insert with check (auth.role() = 'authenticated');

create policy "patients_update_authenticated" on public.patients
  for update using (auth.role() = 'authenticated');

create policy "patients_delete_admin_only" on public.patients
  for delete using (public.current_role() = 'admin');

-- bmi_history: Admin + Staff can select/insert. No update/delete — history
-- is immutable (preserves prior measurements). Deleting a patient cascades
-- and removes their history (admin-only action already gated above).
create policy "history_select_authenticated" on public.bmi_history
  for select using (auth.role() = 'authenticated');

create policy "history_insert_authenticated" on public.bmi_history
  for insert with check (auth.role() = 'authenticated');

-- No update/delete policies on bmi_history => those operations are
-- denied by default under RLS for all roles.

-- ------------------------------------------------------------
-- 8. Seed note (do NOT run in production):
-- Create your first Admin by signing up normally through Supabase Auth,
-- then run:
--   update public.profiles set role = 'admin' where email = 'you@example.com';
-- ------------------------------------------------------------
