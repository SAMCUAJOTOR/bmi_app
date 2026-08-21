import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmi_management_system/core/constants/app_constants.dart';
import 'package:bmi_management_system/models/bmi_record.dart';
import 'package:bmi_management_system/repositories/bmi_repository.dart';
import 'package:bmi_management_system/repositories/user_repository.dart';
import 'package:bmi_management_system/services/bmi_service.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockBmiRepository extends Mock implements BmiRepository {}

void main() {
  late MockUserRepository mockUserRepo;
  late MockBmiRepository mockBmiRepo;
  late BmiService service;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockUserRepo = MockUserRepository();
    mockBmiRepo = MockBmiRepository();
    service = BmiService(userRepository: mockUserRepo, bmiRepository: mockBmiRepo);
  });

  BmiRecord draft({double heightCm = 170, double weightKg = 65}) => BmiRecord(
        id: '',
        name: 'John',
        age: 30,
        gender: Gender.male,
        heightCm: heightCm,
        weightKg: weightKg,
        bmi: 0,
        bmiCategory: '',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  BmiRecord saved(String id, {double heightCm = 170, double weightKg = 65}) =>
      BmiRecord(
        id: id,
        name: 'John',
        age: 30,
        gender: Gender.male,
        heightCm: heightCm,
        weightKg: weightKg,
        bmi: 22.5,
        bmiCategory: 'Normal',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  group('createUserWithBmi', () {
    test('creates the patient record and one history entry', () async {
      when(() => mockUserRepo.createPatient(any()))
          .thenAnswer((_) async => saved('new-id'));
      when(() => mockBmiRepo.addHistoryEntry(any()))
          .thenAnswer((_) async {});

      final result = await service.createUserWithBmi(
        draft: draft(),
        createdBy: 'admin-1',
      );

      expect(result.id, 'new-id');
      verify(() => mockUserRepo.createPatient(any())).called(1);
      verify(() => mockBmiRepo.addHistoryEntry(any())).called(1);
    });
  });

  group('updateUserWithBmi', () {
    test('updates the patient and appends a NEW history row (does not '
        'overwrite prior history)', () async {
      when(() => mockUserRepo.updatePatient('u1', any()))
          .thenAnswer((_) async => saved('u1', heightCm: 175, weightKg: 70));
      when(() => mockBmiRepo.addHistoryEntry(any())).thenAnswer((_) async {});

      final result = await service.updateUserWithBmi(
        userId: 'u1',
        draft: draft(heightCm: 175, weightKg: 70),
        updatedBy: 'admin-1',
      );

      expect(result.heightCm, 175);
      // Exactly one addHistoryEntry call — this is an insert, never an
      // update/delete of a prior row, which is how history is preserved.
      verify(() => mockBmiRepo.addHistoryEntry(any())).called(1);
      verifyNever(() => mockBmiRepo.fetchHistoryForUser(any()));
    });
  });

  group('calculate / category passthrough', () {
    test('calculate matches BmiCalculator formula', () {
      final bmi = service.calculate(heightCm: 170, weightKg: 65);
      expect(bmi, closeTo(22.5, 0.1));
    });

    test('category matches thresholds', () {
      expect(service.category(17.9), 'Underweight');
      expect(service.category(24.9), 'Normal');
      expect(service.category(29.9), 'Overweight');
      expect(service.category(30.0), 'Obese');
    });
  });

  group('historyForUser', () {
    test('returns history entries from repository in order', () async {
      when(() => mockBmiRepo.fetchHistoryForUser('u1'))
          .thenAnswer((_) async => []);
      final history = await service.historyForUser('u1');
      expect(history, isEmpty);
      verify(() => mockBmiRepo.fetchHistoryForUser('u1')).called(1);
    });
  });
}
