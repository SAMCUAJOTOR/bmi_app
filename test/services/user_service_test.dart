import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmi_management_system/core/constants/app_constants.dart';
import 'package:bmi_management_system/models/bmi_record.dart';
import 'package:bmi_management_system/repositories/user_repository.dart';
import 'package:bmi_management_system/services/user_service.dart';

class MockUserRepository extends Mock implements UserRepository {}

BmiRecord _record({
  String id = '1',
  String name = 'John',
  double bmi = 22.0,
  String category = 'Normal',
}) {
  return BmiRecord(
    id: id,
    name: name,
    age: 30,
    gender: Gender.male,
    heightCm: 170,
    weightKg: 63.6,
    bmi: bmi,
    bmiCategory: category,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockUserRepository mockRepo;
  late UserService service;

  setUp(() {
    mockRepo = MockUserRepository();
    service = UserService(repository: mockRepo);
  });

  group('UserService.list', () {
    test('passes search/filter/sort params through to repository', () async {
      when(() => mockRepo.fetchPatients(
            searchQuery: any(named: 'searchQuery'),
            genderFilter: any(named: 'genderFilter'),
            categoryFilter: any(named: 'categoryFilter'),
            sortField: any(named: 'sortField'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) async => [_record()]);

      final results = await service.list(
        searchQuery: 'Jo',
        genderFilter: 'Male',
        categoryFilter: 'Normal',
        sortField: SortField.name,
        ascending: true,
      );

      expect(results, hasLength(1));
      verify(() => mockRepo.fetchPatients(
            searchQuery: 'Jo',
            genderFilter: 'Male',
            categoryFilter: 'Normal',
            sortField: SortField.name,
            ascending: true,
          )).called(1);
    });

    test('returns empty list when no records match filters', () async {
      when(() => mockRepo.fetchPatients(
            searchQuery: any(named: 'searchQuery'),
            genderFilter: any(named: 'genderFilter'),
            categoryFilter: any(named: 'categoryFilter'),
            sortField: any(named: 'sortField'),
            ascending: any(named: 'ascending'),
          )).thenAnswer((_) async => []);

      final results = await service.list(searchQuery: 'Zzz');
      expect(results, isEmpty);
    });
  });

  group('UserService.getById', () {
    test('returns the matching record', () async {
      when(() => mockRepo.fetchById('1'))
          .thenAnswer((_) async => _record(id: '1', name: 'Jane'));

      final result = await service.getById('1');
      expect(result.name, 'Jane');
    });
  });

  group('UserService.delete', () {
    test('delegates deletion to repository', () async {
      when(() => mockRepo.deletePatient('1')).thenAnswer((_) async {});
      await service.delete('1');
      verify(() => mockRepo.deletePatient('1')).called(1);
    });

    test('propagates repository errors (e.g. RLS denial for non-admin)', () async {
      when(() => mockRepo.deletePatient('1')).thenThrow(
        Exception('new row violates row-level security policy'),
      );
      expect(() => service.delete('1'), throwsA(isA<Exception>()));
    });
  });

  group('UserService.totalCount', () {
    test('returns count from repository', () async {
      when(() => mockRepo.countAll()).thenAnswer((_) async => 7);
      final count = await service.totalCount();
      expect(count, 7);
    });
  });
}
