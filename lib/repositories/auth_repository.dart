import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/app_user.dart';

class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentAuthUser => _client.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Admin-only: create a new Admin or Staff account.
  /// Uses standard signUp (anon key). The DB trigger `handle_new_user`
  /// creates the matching profiles row with the given role from metadata.
  Future<AuthResponse> createAccount({
    required String email,
    required String password,
    required String fullName,
    required AppRole role,
  }) async {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.value,
      },
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserResponse> updateEmail(String newEmail) async {
    return _client.auth.updateUser(UserAttributes(email: newEmail));
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<AppUser> fetchProfile(String userId) async {
    final data = await _client
        .from(AppConstants.tableProfiles)
        .select()
        .eq('id', userId)
        .single();
    return AppUser.fromMap(data);
  }

  Future<void> updateProfileName(String userId, String fullName) async {
    await _client
        .from(AppConstants.tableProfiles)
        .update({'full_name': fullName}).eq('id', userId);
  }

  Future<void> updateProfileEmail(String userId, String email) async {
    await _client
        .from(AppConstants.tableProfiles)
        .update({'email': email}).eq('id', userId);
  }
}
