import '../core/constants/app_constants.dart';

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final AppRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isAdmin => role == AppRole.admin;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: AppRoleX.fromString(map['role'] as String? ?? 'staff'),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role.value,
    };
  }
}
