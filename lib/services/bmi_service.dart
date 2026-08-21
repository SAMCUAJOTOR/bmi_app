import '../core/utils/bmi_calculator.dart';
import '../models/bmi_history.dart';
import '../models/bmi_record.dart';
import '../repositories/bmi_repository.dart';
import '../repositories/user_repository.dart';

class BmiService {
  final UserRepository _userRepo;
  final BmiRepository _bmiRepo;

  BmiService({UserRepository? userRepository, BmiRepository? bmiRepository})
      : _userRepo = userRepository ?? UserRepository(),
        _bmiRepo = bmiRepository ?? BmiRepository();

  double calculate({required double heightCm, required double weightKg}) =>
      BmiCalculator.calculate(heightCm: heightCm, weightKg: weightKg);

  String category(double bmi) => BmiCalculator.getCategory(bmi);

  /// Add User / Calculate BMI use case: creates the patient record AND
  /// the first bmi_history entry in one flow.
  Future<BmiRecord> createUserWithBmi({
    required BmiRecord draft,
    required String? createdBy,
  }) async {
    final created =
        await _userRepo.createPatient(draft.toInsertMap(createdBy: createdBy));
    await _bmiRepo.addHistoryEntry(
      BmiHistory(
        id: '',
        userId: created.id,
        heightCm: created.heightCm,
        weightKg: created.weightKg,
        bmi: created.bmi,
        bmiCategory: created.bmiCategory,
        recordedAt: DateTime.now(),
      ).toInsertMap(userId: created.id, recordedBy: createdBy),
    );
    return created;
  }

  /// Edit User use case: recalculates BMI, updates the patient record,
  /// and preserves history by inserting a NEW history row rather than
  /// overwriting the previous one.
  Future<BmiRecord> updateUserWithBmi({
    required String userId,
    required BmiRecord draft,
    required String? updatedBy,
  }) async {
    final updated =
        await _userRepo.updatePatient(userId, draft.toUpdateMap());
    await _bmiRepo.addHistoryEntry(
      BmiHistory(
        id: '',
        userId: updated.id,
        heightCm: updated.heightCm,
        weightKg: updated.weightKg,
        bmi: updated.bmi,
        bmiCategory: updated.bmiCategory,
        recordedAt: DateTime.now(),
      ).toInsertMap(userId: updated.id, recordedBy: updatedBy),
    );
    return updated;
  }

  Future<List<BmiHistory>> historyForUser(String userId) =>
      _bmiRepo.fetchHistoryForUser(userId);
}
