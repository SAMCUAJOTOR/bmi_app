import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_management_system/core/utils/bmi_calculator.dart';

void main() {
  group('BmiCalculator.calculate', () {
    test('computes correct BMI for a normal case', () {
      final bmi = BmiCalculator.calculate(heightCm: 170, weightKg: 65);
      expect(bmi, closeTo(22.5, 0.1));
    });

    test('throws on zero height', () {
      expect(
        () => BmiCalculator.calculate(heightCm: 0, weightKg: 60),
        throwsArgumentError,
      );
    });

    test('throws on negative weight', () {
      expect(
        () => BmiCalculator.calculate(heightCm: 170, weightKg: -5),
        throwsArgumentError,
      );
    });

    test('throws on negative height', () {
      expect(
        () => BmiCalculator.calculate(heightCm: -170, weightKg: 60),
        throwsArgumentError,
      );
    });
  });

  group('BmiCalculator.getCategory', () {
    test('Underweight below 18.5', () {
      expect(BmiCalculator.getCategory(17.9), 'Underweight');
    });

    test('Normal between 18.5 and 24.9', () {
      expect(BmiCalculator.getCategory(18.5), 'Normal');
      expect(BmiCalculator.getCategory(24.9), 'Normal');
    });

    test('Overweight between 25 and 29.9', () {
      expect(BmiCalculator.getCategory(25.0), 'Overweight');
      expect(BmiCalculator.getCategory(29.9), 'Overweight');
    });

    test('Obese at 30 and above', () {
      expect(BmiCalculator.getCategory(30.0), 'Obese');
      expect(BmiCalculator.getCategory(45.0), 'Obese');
    });
  });
}
