import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repo;

  AuthService({AuthRepository? repository})
      : _repo = repository ?? AuthRepository();

  bool get isLoggedIn => _repo.currentSession != null;

  Future<AppUser> login(String email, String password) async {
    if (email.trim().isEmpty) throw Exception('Email is required');
    if (password.isEmpty) throw Exception('Password is required');

    final res = await _repo.signIn(email: email.trim(), password: password);
    final user = res.user;
    if (user == null) throw Exception('Invalid credentials');
    return _repo.fetchProfile(user.id);
  }

  Future<AppUser?> restoreSession() async {
    final authUser = _repo.currentAuthUser;
    if (authUser == null) return null;
    try {
      return await _repo.fetchProfile(authUser.id);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() => _repo.signOut();

  /// Admin-only account creation (Register / Sign Up use case).
  Future<void> createAccount({
    required String fullName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    if (password.length < AppConstants.minPasswordLength) {
      throw Exception(
          'Password must be at least ${AppConstants.minPasswordLength} characters');
    }
    await _repo.createAccount(
      email: email.trim(),
      password: password,
      fullName: fullName.trim(),
      role: role,
    );
  }

  Future<void> updateName(String userId, String fullName) =>
      _repo.updateProfileName(userId, fullName);

  Future<void> updateEmail(String userId, String newEmail) async {
    await _repo.updateEmail(newEmail);
    await _repo.updateProfileEmail(userId, newEmail);
  }

  Future<void> updatePassword(String newPassword) async {
    if (newPassword.length < AppConstants.minPasswordLength) {
      throw Exception(
          'Password must be at least ${AppConstants.minPasswordLength} characters');
    }
    await _repo.updatePassword(newPassword);
  }
}
