import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_management_system/core/validators/validators.dart';

void main() {
  group('Validators', () {
    test('name rejects empty', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('Jo'), isNull);
    });

    test('heightCm rejects zero/negative/non-numeric', () {
      expect(Validators.heightCm('0'), isNotNull);
      expect(Validators.heightCm('-10'), isNotNull);
      expect(Validators.heightCm('abc'), isNotNull);
      expect(Validators.heightCm('170'), isNull);
    });

    test('weightKg rejects zero/negative/non-numeric', () {
      expect(Validators.weightKg('0'), isNotNull);
      expect(Validators.weightKg('-5'), isNotNull);
      expect(Validators.weightKg('xyz'), isNotNull);
      expect(Validators.weightKg('65'), isNull);
    });

    test('email validates format', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('password requires at least 8 characters', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenough1'), isNull);
    });

    test('age rejects invalid values', () {
      expect(Validators.age(''), isNotNull);
      expect(Validators.age('abc'), isNotNull);
      expect(Validators.age('0'), isNotNull);
      expect(Validators.age('25'), isNull);
    });
  });
}
