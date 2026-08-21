import '../core/constants/app_constants.dart';
import '../models/bmi_record.dart';
import '../repositories/user_repository.dart';

class DashboardStats {
  final int totalUsers;
  final double averageBmi;
  final int underweight;
  final int normal;
  final int overweight;
  final int obese;
  final List<BmiRecord> recent;

  DashboardStats({
    required this.totalUsers,
    required this.averageBmi,
    required this.underweight,
    required this.normal,
    required this.overweight,
    required this.obese,
    required this.recent,
  });
}

class ReportService {
  final UserRepository _repo = UserRepository();

  Future<DashboardStats> loadDashboard() async {
    final all = await _repo.fetchPatients(
      sortField: SortField.dateAdded,
      ascending: false,
    );

    final total = all.length;
    final avgBmi = total == 0
        ? 0.0
        : all.map((e) => e.bmi).reduce((a, b) => a + b) / total;

    int count(String cat) => all.where((e) => e.bmiCategory == cat).length;

    return DashboardStats(
      totalUsers: total,
      averageBmi: double.parse(avgBmi.toStringAsFixed(1)),
      underweight: count('Underweight'),
      normal: count('Normal'),
      overweight: count('Overweight'),
      obese: count('Obese'),
      recent: all.take(5).toList(),
    );
  }

  /// Reports screen: filterable BMI distribution, age-group breakdown,
  /// and gender comparison. Read-only aggregation over live data.
  Future<Map<String, dynamic>> loadReport({
    DateTime? from,
    DateTime? to,
    String? genderFilter,
    String? ageGroupFilter,
  }) async {
    var records = await _repo.fetchPatients(
      genderFilter: genderFilter,
      sortField: SortField.dateAdded,
      ascending: false,
    );

    if (from != null) {
      records = records.where((r) => !r.createdAt.isBefore(from)).toList();
    }
    if (to != null) {
      records = records.where((r) => !r.createdAt.isAfter(to)).toList();
    }
    if (ageGroupFilter != null && ageGroupFilter != 'All') {
      records =
          records.where((r) => ageGroupOf(r.age) == ageGroupFilter).toList();
    }

    final distribution = <String, int>{
      'Underweight': records.where((r) => r.bmiCategory == 'Underweight').length,
      'Normal': records.where((r) => r.bmiCategory == 'Normal').length,
      'Overweight': records.where((r) => r.bmiCategory == 'Overweight').length,
      'Obese': records.where((r) => r.bmiCategory == 'Obese').length,
    };

    final ageGroups = <String, int>{};
    for (final r in records) {
      final g = ageGroupOf(r.age);
      ageGroups[g] = (ageGroups[g] ?? 0) + 1;
    }

    final genders = <String, double>{};
    for (final gender in ['Male', 'Female', 'Other']) {
      final subset = records.where((r) => r.gender.label == gender).toList();
      if (subset.isEmpty) continue;
      genders[gender] = double.parse(
        (subset.map((e) => e.bmi).reduce((a, b) => a + b) / subset.length)
            .toStringAsFixed(1),
      );
    }

    return {
      'records': records,
      'distribution': distribution,
      'ageGroups': ageGroups,
      'genderAvgBmi': genders,
      'hasEnoughData': records.length >= 3,
    };
  }

  static String ageGroupOf(int age) {
    if (age < 18) return 'Under 18';
    if (age < 30) return '18-29';
    if (age < 45) return '30-44';
    if (age < 60) return '45-59';
    return '60+';
  }
}
