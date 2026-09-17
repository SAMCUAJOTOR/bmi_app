import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmi_management_system/core/constants/app_constants.dart';
import 'package:bmi_management_system/models/app_user.dart';
import 'package:bmi_management_system/providers/auth_provider.dart';
import 'package:bmi_management_system/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

AppUser _adminUser() => AppUser(
      id: 'admin-1',
      fullName: 'Ada Admin',
      email: 'ada@example.com',
      role: AppRole.admin,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

AppUser _staffUser() => AppUser(
      id: 'staff-1',
      fullName: 'Sam Staff',
      email: 'sam@example.com',
      role: AppRole.staff,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late MockAuthService mockAuthService;
  late AuthProvider provider;

  setUpAll(() {
    registerFallbackValue(AppRole.staff);
  });

  setUp(() {
    mockAuthService = MockAuthService();
    provider = AuthProvider(authService: mockAuthService);
  });

  group('login', () {
    test('valid credentials set status to authenticated and store the user',
        () async {
      when(() => mockAuthService.login('ada@example.com', 'password123'))
          .thenAnswer((_) async => _adminUser());

      final ok = await provider.login('ada@example.com', 'password123');

      expect(ok, isTrue);
      expect(provider.status, AuthStatus.authenticated);
      expect(provider.currentUser?.email, 'ada@example.com');
      expect(provider.isAdmin, isTrue);
      expect(provider.isLoading, isFalse);
    });

    test('invalid credentials set status unauthenticated with error message',
        () async {
      when(() => mockAuthService.login('bad@example.com', 'wrong'))
          .thenThrow(Exception('Invalid credentials'));

      final ok = await provider.login('bad@example.com', 'wrong');

      expect(ok, isFalse);
      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.errorMessage, 'Invalid credentials');
      expect(provider.currentUser, isNull);
    });

    test('empty email surfaces "Email is required"', () async {
      when(() => mockAuthService.login('', 'password123'))
          .thenThrow(Exception('Email is required'));

      final ok = await provider.login('', 'password123');

      expect(ok, isFalse);
      expect(provider.errorMessage, 'Email is required');
    });

    test('empty password surfaces "Password is required"', () async {
      when(() => mockAuthService.login('ada@example.com', ''))
          .thenThrow(Exception('Password is required'));

      final ok = await provider.login('ada@example.com', '');

      expect(ok, isFalse);
      expect(provider.errorMessage, 'Password is required');
    });
  });

  group('logout', () {
    test('clears user and sets status unauthenticated', () async {
      when(() => mockAuthService.login('ada@example.com', 'password123'))
          .thenAnswer((_) async => _adminUser());
      await provider.login('ada@example.com', 'password123');
      expect(provider.status, AuthStatus.authenticated);

      when(() => mockAuthService.logout()).thenAnswer((_) async {});
      await provider.logout();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.currentUser, isNull);
    });
  });

  group('session expiration', () {
    test('handleSessionExpired clears state and sets the expiry message', () {
      provider.currentUser = _staffUser();
      provider.status = AuthStatus.authenticated;

      provider.handleSessionExpired();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.currentUser, isNull);
      expect(provider.errorMessage, 'Session expired');
    });
  });

  group('createAccount (admin-only account creation)', () {
    test('succeeds and returns true', () async {
      when(() => mockAuthService.createAccount(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
          )).thenAnswer((_) async {});

      final ok = await provider.createAccount(
        fullName: 'New Staff',
        email: 'new@example.com',
        password: 'longenough1',
        role: AppRole.staff,
      );

      expect(ok, isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('rejects weak password with a clear error', () async {
      when(() => mockAuthService.createAccount(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
          )).thenThrow(
        Exception('Password must be at least 8 characters'),
      );

      final ok = await provider.createAccount(
        fullName: 'New Staff',
        email: 'new@example.com',
        password: 'short',
        role: AppRole.staff,
      );

      expect(ok, isFalse);
      expect(provider.errorMessage, contains('at least 8 characters'));
    });
  });
}
