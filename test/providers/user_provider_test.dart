import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmi_management_system/core/constants/app_constants.dart';
import 'package:bmi_management_system/models/bmi_record.dart';
import 'package:bmi_management_system/providers/user_provider.dart';
import 'package:bmi_management_system/repositories/user_repository.dart';
import 'package:bmi_management_system/services/user_service.dart';

class MockUserService extends Mock implements UserService {}

BmiRecord _record(String id, String name, {String category = 'Normal'}) {
  return BmiRecord(
    id: id,
    name: name,
    age: 25,
    gender: Gender.female,
    heightCm: 165,
    weightKg: 60,
    bmi: 22.0,
    bmiCategory: category,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late MockUserService mockService;
  late UserProvider provider;

  setUpAll(() {
    registerFallbackValue(SortField.name);
  });

  setUp(() {
    mockService = MockUserService();
    provider = UserProvider(userService: mockService);
  });

  test('load() populates records on success', () async {
    when(() => mockService.list(
          searchQuery: any(named: 'searchQuery'),
          genderFilter: any(named: 'genderFilter'),
          categoryFilter: any(named: 'categoryFilter'),
          sortField: any(named: 'sortField'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) async => [_record('1', 'Alice')]);

    await provider.load();

    expect(provider.records, hasLength(1));
    expect(provider.errorMessage, isNull);
    expect(provider.isLoading, isFalse);
  });

  test('load() surfaces a friendly error message on failure', () async {
    when(() => mockService.list(
          searchQuery: any(named: 'searchQuery'),
          genderFilter: any(named: 'genderFilter'),
          categoryFilter: any(named: 'categoryFilter'),
          sortField: any(named: 'sortField'),
          ascending: any(named: 'ascending'),
        )).thenThrow(Exception('network error'));

    await provider.load();

    expect(provider.records, isEmpty);
    expect(provider.errorMessage, 'network error');
  });

  test('setSearch updates query and reloads', () async {
    when(() => mockService.list(
          searchQuery: any(named: 'searchQuery'),
          genderFilter: any(named: 'genderFilter'),
          categoryFilter: any(named: 'categoryFilter'),
          sortField: any(named: 'sortField'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) async => []);

    provider.setSearch('Jo');
    expect(provider.searchQuery, 'Jo');
  });

  test('setSort toggles ascending when the same field is tapped twice', () async {
    when(() => mockService.list(
          searchQuery: any(named: 'searchQuery'),
          genderFilter: any(named: 'genderFilter'),
          categoryFilter: any(named: 'categoryFilter'),
          sortField: any(named: 'sortField'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) async => []);

    expect(provider.sortField, SortField.dateAdded);
    expect(provider.ascending, isFalse);

    provider.setSort(SortField.name);
    expect(provider.sortField, SortField.name);
    expect(provider.ascending, isFalse);

    provider.setSort(SortField.name);
    expect(provider.ascending, isTrue);
  });

  test('deleteUser removes the record locally on success', () async {
    when(() => mockService.list(
          searchQuery: any(named: 'searchQuery'),
          genderFilter: any(named: 'genderFilter'),
          categoryFilter: any(named: 'categoryFilter'),
          sortField: any(named: 'sortField'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) async => [_record('1', 'Alice'), _record('2', 'Bob')]);
    await provider.load();

    when(() => mockService.delete('1')).thenAnswer((_) async {});
    final ok = await provider.deleteUser('1');

    expect(ok, isTrue);
    expect(provider.records.map((r) => r.id), ['2']);
  });

  test('deleteUser returns false and keeps records when RLS denies it (Staff)',
      () async {
    when(() => mockService.list(
          searchQuery: any(named: 'searchQuery'),
          genderFilter: any(named: 'genderFilter'),
          categoryFilter: any(named: 'categoryFilter'),
          sortField: any(named: 'sortField'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) async => [_record('1', 'Alice')]);
    await provider.load();

    when(() => mockService.delete('1'))
        .thenThrow(Exception('row-level security policy violation'));
    final ok = await provider.deleteUser('1');

    expect(ok, isFalse);
    expect(provider.records, hasLength(1));
    expect(provider.errorMessage, contains('row-level security'));
  });
}
