import '../models/bmi_record.dart';
import '../repositories/user_repository.dart';

class UserService {
  final UserRepository _repo;

  UserService({UserRepository? repository})
      : _repo = repository ?? UserRepository();

  Future<List<BmiRecord>> list({
    String? searchQuery,
    String? genderFilter,
    String? categoryFilter,
    SortField sortField = SortField.dateAdded,
    bool ascending = false,
  }) {
    return _repo.fetchPatients(
      searchQuery: searchQuery,
      genderFilter: genderFilter,
      categoryFilter: categoryFilter,
      sortField: sortField,
      ascending: ascending,
    );
  }

  Future<BmiRecord> getById(String id) => _repo.fetchById(id);

  /// Admin-only in the UI; enforced for real by RLS on the patients table.
  Future<void> delete(String id) => _repo.deletePatient(id);

  Future<int> totalCount() => _repo.countAll();
}
