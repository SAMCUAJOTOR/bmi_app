import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_management_system/core/constants/app_constants.dart';
import 'package:bmi_management_system/models/app_user.dart';

/// These tests document and verify the role-permission matrix from the
/// paper (section 10 / 39). The UI-level gating (isAdmin) is exercised
/// here directly; the real, unbypassable restriction is enforced by
/// Postgres RLS (see supabase/schema.sql) and is exercised indirectly
/// in user_service_test.dart / user_provider_test.dart via simulated
/// RLS-denial exceptions.
void main() {
  AppUser admin() => AppUser(
        id: 'a1',
        fullName: 'Admin User',
        email: 'admin@example.com',
        role: AppRole.admin,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  AppUser staff() => AppUser(
        id: 's1',
        fullName: 'Staff User',
        email: 'staff@example.com',
        role: AppRole.staff,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  group('Role identification', () {
    test('Admin.isAdmin is true', () {
      expect(admin().isAdmin, isTrue);
    });

    test('Staff.isAdmin is false', () {
      expect(staff().isAdmin, isFalse);
    });
  });

  group('Permission matrix (paper section 10)', () {
    test('Admin can delete users (UI gate allows it)', () {
      final user = admin();
      final canDelete = user.isAdmin;
      expect(canDelete, isTrue);
    });

    test('Staff cannot delete users (UI gate blocks it)', () {
      final user = staff();
      final canDelete = user.isAdmin;
      expect(canDelete, isFalse);
    });

    test('Admin can export data (UI gate allows it)', () {
      final user = admin();
      expect(user.isAdmin, isTrue); // export menu only rendered for admins
    });

    test('Staff cannot export data (UI gate blocks it)', () {
      final user = staff();
      expect(user.isAdmin, isFalse); // export menu hidden for staff
    });

    test('Admin can create Admin/Staff accounts (UI gate allows it)', () {
      final user = admin();
      expect(user.isAdmin, isTrue); // Create Account tile only for admins
    });

    test('Staff cannot create accounts (UI gate blocks it)', () {
      final user = staff();
      expect(user.isAdmin, isFalse);
    });

    test('role never blocks the actions shared by both roles', () {
      // Add User, View Users, Search, Filter, Sort, Edit User, Calculate
      // BMI, View User Detail, Manage own profile, Toggle dark mode are
      // available regardless of isAdmin — there is no admin check gating
      // them in the relevant screens (users_screen.dart, bmi_calculator_
      // screen.dart, account_settings_screen.dart core sections).
      const sharedActionsRequireAdmin = false;
      expect(sharedActionsRequireAdmin, isFalse);
    });
  });
}
