/// Single source of truth for BMI calculation and categorization.
/// Every screen/service that needs BMI math must call into this class —
/// never re-implement the formula elsewhere.
class BmiCalculator {
  BmiCalculator._();

  /// BMI = weight (kg) / height (m)^2
  static double calculate({
    required double heightCm,
    required double weightKg,
  }) {
    if (heightCm <= 0 || weightKg <= 0) {
      throw ArgumentError('Height and weight must be positive values.');
    }
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Returns a 0.0–1.0 position on a fixed BMI gauge (15 to 40 range)
  /// for use in progress-bar / gauge widgets.
  static double gaugeFraction(double bmi) {
    const double min = 15;
    const double max = 40;
    final clamped = bmi.clamp(min, max);
    return (clamped - min) / (max - min);
  }
}
