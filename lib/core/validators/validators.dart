import '../constants/app_constants.dart';

class Validators {
  Validators._();

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Age must be a number';
    if (n < AppConstants.minAge || n > AppConstants.maxAge) {
      return 'Enter a valid age';
    }
    return null;
  }

  static String? gender(String? value) {
    if (value == null || value.trim().isEmpty) return 'Gender is required';
    return null;
  }

  static String? heightCm(String? value) {
    if (value == null || value.trim().isEmpty) return 'Height is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Height must be numeric';
    if (n <= 0) return 'Height must be greater than zero';
    if (n < AppConstants.minHeightCm || n > AppConstants.maxHeightCm) {
      return 'Enter a valid height';
    }
    return null;
  }

  static String? weightKg(String? value) {
    if (value == null || value.trim().isEmpty) return 'Weight is required';
    final n = double.tryParse(value.trim());
    if (n == null) return 'Weight must be numeric';
    if (n <= 0) return 'Weight must be greater than zero';
    if (n < AppConstants.minWeightKg || n > AppConstants.maxWeightKg) {
      return 'Enter a valid weight';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }
}
