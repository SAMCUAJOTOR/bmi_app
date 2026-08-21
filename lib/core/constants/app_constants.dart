class AppConstants {
  AppConstants._();

  static const String appName = 'BMI Management System';

  // Supabase table names
  static const String tableProfiles = 'profiles';
  static const String tablePatients = 'patients';
  static const String tableBmiHistory = 'bmi_history';

  // Shared preferences keys
  static const String prefThemeMode = 'theme_mode';

  // Validation
  static const int minPasswordLength = 8;
  static const double minHeightCm = 30;
  static const double maxHeightCm = 300;
  static const double minWeightKg = 1;
  static const double maxWeightKg = 500;
  static const int minAge = 1;
  static const int maxAge = 130;
}

enum AppRole { admin, staff }

extension AppRoleX on AppRole {
  String get value => name; // 'admin' | 'staff'

  static AppRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return AppRole.admin;
      case 'staff':
        return AppRole.staff;
      default:
        return AppRole.staff;
    }
  }
}

enum Gender { male, female, other }

extension GenderX on Gender {
  String get label {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  static Gender fromString(String value) {
    switch (value.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
}
