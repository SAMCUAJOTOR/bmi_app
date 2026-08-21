import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;
  bool isLoading = false;
  String? errorMessage;

  bool get isAdmin => currentUser?.role == AppRole.admin;
  bool get isLoggedIn => status == AuthStatus.authenticated;

  Future<void> restoreSession() async {
    isLoading = true;
    notifyListeners();
    final user = await _authService.restoreSession();
    currentUser = user;
    status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.login(email, password);
      currentUser = user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      status = AuthStatus.unauthenticated;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called automatically when Supabase reports the session expired.
  void handleSessionExpired() {
    currentUser = null;
    status = AuthStatus.unauthenticated;
    errorMessage = 'Session expired';
    notifyListeners();
  }

  Future<bool> createAccount({
    required String fullName,
    required String email,
    required String password,
    required AppRole role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.createAccount(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({String? fullName, String? email}) async {
    if (currentUser == null) return false;
    try {
      if (fullName != null && fullName.trim().isNotEmpty) {
        await _authService.updateName(currentUser!.id, fullName.trim());
      }
      if (email != null && email.trim().isNotEmpty) {
        await _authService.updateEmail(currentUser!.id, email.trim());
      }
      currentUser = await _authService.restoreSession();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) return 'Invalid credentials';
    if (msg.contains('Email is required')) return 'Email is required';
    if (msg.contains('Password is required')) return 'Password is required';
    return msg.replaceFirst('Exception: ', '');
  }
}
