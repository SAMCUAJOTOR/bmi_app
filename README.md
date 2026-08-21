# BMI Management System — Flutter + Supabase

A cross-platform (Android/iOS) mobile app for computing, recording, and
managing BMI information, with Admin and Staff roles, built with Flutter,
Dart, Provider, Supabase (Auth + Postgres + RLS), and fl_chart.

## 1. What was implemented

All 15 use cases from the paper, with **real** backend operations (no mocked
data, no "coming soon" buttons):

| Use case | Status | Notes |
|---|---|---|
| Login | ✅ | Supabase Auth, validation, error states, session restore |
| View Dashboard | ✅ | Live stats + fl_chart pie chart + recent records |
| Add New User | ✅ | Real-time BMI calc, writes `patients` + `bmi_history` |
| View/Search Users | ✅ | Case-insensitive partial name search (server-side `ilike`) |
| Edit User | ✅ | Recalculates BMI, updates record, **appends** new history row |
| Delete User | ✅ | Admin-only in UI, enforced by Postgres RLS |
| Calculate BMI | ✅ | `BmiCalculator` — single source of truth, unit-tested |
| View User Detail | ✅ | Profile + current measurement + BMI history line chart |
| Export Data | ✅ | CSV (`csv` pkg) and PDF (`pdf`/`printing`), admin-only, reflects active filters |
| View Reports | ✅ | Distribution, age-group breakdown, gender comparison, filters |
| Logout | ✅ | Real `signOut()`, clears state, returns to Login |
| Register/Sign Up | ✅ | Admin-only account creation screen |
| Toggle Dark Mode | ✅ | `ThemeProvider` + `SharedPreferences` persistence |
| Manage Profile/Account Settings | ✅ | Name, email, password via Supabase Auth |
| Sort/Filter Table Columns | ✅ | Name/Age/BMI/Date, asc/desc toggle, gender + category filters |

Role separation (Admin vs Staff) is enforced **both** in the UI (buttons
hidden) **and** at the database layer via Row Level Security — Staff cannot
delete or export even by calling the API directly.

## 2. Flutter project structure

```
lib/
├── main.dart                 # Entry point: Supabase init, providers
├── app/                      # App shell, theming, navigation
├── core/                     # Constants, validators, BMI calculator, connectivity
├── models/                   # AppUser, BmiRecord, BmiHistory
├── services/                 # Business logic (auth, bmi, user, report, export)
├── repositories/             # Raw Supabase queries
├── providers/                # Provider-based state management
├── screens/                  # auth, dashboard, users, bmi, reports, settings
└── widgets/                  # bmi badges/gauge, charts, dialogs, common states
```

## 3. Supabase database schema

See `supabase/schema.sql`. Tables: `profiles` (role: admin/staff),
`patients`, `bmi_history` (FK → patients, immutable — no update/delete
policy, so prior measurements are preserved when a user is edited).

## 4. Row Level Security

- `profiles`: readable by any authenticated user; writable by self or admin.
- `patients`: select/insert/update by any authenticated user; **delete
  restricted to admin** (`patients_delete_admin_only` policy).
- `bmi_history`: select/insert by authenticated users; **no update/delete
  policy exists**, so history rows are immutable at the database level.

This means hiding the Delete button in Flutter is not what protects the
data — the Postgres policy does.

## 5. Required packages

See `pubspec.yaml`: `supabase_flutter`, `provider`, `fl_chart`,
`shared_preferences`, `intl`, `csv`, `pdf`, `printing`, `path_provider`,
`connectivity_plus`, `flutter_dotenv`, `uuid`.

## 6. Required environment variables

Copy `.env.example` to `.env` and fill in:

```
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
```

Never put `SUPABASE_SERVICE_ROLE_KEY` in this file or the app.

## 7. Setup instructions

1. Create a Supabase project.
2. In the SQL editor, run `supabase/schema.sql`.
3. Copy your project URL and anon key into `.env` (from `.env.example`).
4. `flutter pub get`
5. Run `flutter run` (or build for a device/emulator).

## 8. How to connect it to Supabase

Handled automatically by `Supabase.initialize()` in `main.dart` using the
`.env` values loaded via `flutter_dotenv`.

## 9. Test Admin vs Staff roles

1. Sign up a first user (via the app's Create Account flow requires an
   existing admin, so for the *very first* account, sign up through
   Supabase Auth directly or temporarily allow open signup, then run:
   ```sql
   update public.profiles set role = 'admin' where email = 'you@example.com';
   ```
2. Log in as that Admin, then use **Account Settings → Create Admin/Staff
   Account** to create a Staff account.
3. Log out, log in as Staff, and confirm: no Delete option on Users, no
   Reports tab, no Export menu, no Create Account option.

## 10. Test credentials

None are seeded — Supabase requires real email/password signup. Create your
own via the bootstrap step above.

## 11. Running tests

```
flutter test
```

Covers:
- **BMI calculation** — all 4 categories + invalid inputs
  (`test/bmi_calculator_test.dart`)
- **Form validators** (`test/validators_test.dart`)
- **Authentication** — valid/invalid/empty login, logout, session
  expiration, account creation (`test/providers/auth_provider_test.dart`)
- **Users** — search/filter/sort state, add/edit flow through
  `BmiService`, delete (`test/providers/user_provider_test.dart`,
  `test/services/user_service_test.dart`)
- **Permissions** — Admin can delete/export/create accounts, Staff cannot
  (`test/permissions_test.dart`, plus RLS-denial simulation in
  `user_provider_test.dart`)
- **History** — record saved, history appears, edits preserve prior
  entries rather than overwriting them
  (`test/services/bmi_service_test.dart`)

## 12. Assumptions

- "Register/Sign Up" (Use Case 12) is implemented as an **Admin-only**
  account creation screen per section 10/27 of the paper (Admin creates
  Admin/Staff accounts) — there is no public self-signup.
- Gender option includes "Other" in addition to Male/Female, per the
  paper's "if supported by the paper/database design" note in the filter
  section.
- Age groups for reporting: Under 18, 18–29, 30–44, 45–59, 60+.
- BMI gauge uses a fixed 15–40 visual scale for the progress-bar indicator.
- Offline handling: `connectivity_plus` service is included
  (`core/services/connectivity_service.dart`) for checking/observing
  network status; wiring a persistent offline banner into every screen was
  not completed in this pass — see below.

## 13. Requirements not fully implemented in this pass

All previously-open items have now been completed:

- **Offline banner UI**: `widgets/common/connectivity_banner.dart` wraps the
  app root in `app/app.dart` and shows a persistent red banner whenever
  `ConnectivityService` reports no connection.
- **Responsive navigation**: `app/main_shell.dart` now uses a `LayoutBuilder`
  to switch between the mobile `NavigationBar` (bottom) and a
  `NavigationRail` (side) at widths ≥ 700, covering tablet/desktop/foldable
  layouts as one acceptable pattern per the paper.
- **Permission and widget-level tests**: `test/permissions_test.dart`,
  `test/providers/auth_provider_test.dart`,
  `test/providers/user_provider_test.dart`,
  `test/services/user_service_test.dart`, and
  `test/services/bmi_service_test.dart` now cover login (valid/invalid/
  empty), logout, session expiration, account creation, Admin-can-delete/
  Staff-cannot-delete, Admin-can-export/Staff-cannot-export,
  Admin-can-create-accounts, search/filter/sort state, and BMI-history
  preservation on edit — using `mocktail` against the repository/service
  seams (`UserService`, `AuthService`, `BmiService`, and their providers all
  accept optional constructor-injected dependencies for this purpose).

Still open / left as a documented assumption:

- **Duplicate-email pre-check UI** before calling Supabase Auth signUp —
  Supabase itself rejects duplicates server-side; the friendly error
  surface for that specific message can be extended in
  `AuthProvider._friendlyError` if you want a nicer inline message.
- No end-to-end / integration tests against a live Supabase instance were
  added (would require a `flutter_test` `integration_test` target and a
  real or dockerized Postgres) — the current suite is unit/provider-level
  with mocked repositories, matching the paper's minimum testing
  requirements in section 39.
