import '../core/constants/app_constants.dart';
import '../core/utils/bmi_calculator.dart';

class BmiRecord {
  final String id;
  final String name;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String bmiCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  BmiRecord({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.bmiCategory,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory BmiRecord.fromMap(Map<String, dynamic> map) {
    return BmiRecord(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      age: map['age'] as int? ?? 0,
      gender: GenderX.fromString(map['gender'] as String? ?? 'other'),
      heightCm: (map['height_cm'] as num).toDouble(),
      weightKg: (map['weight_kg'] as num).toDouble(),
      bmi: (map['bmi'] as num).toDouble(),
      bmiCategory: map['bmi_category'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      createdBy: map['created_by'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap({required String? createdBy}) {
    final calculatedBmi =
        BmiCalculator.calculate(heightCm: heightCm, weightKg: weightKg);
    return {
      'name': name,
      'age': age,
      'gender': gender.label,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': calculatedBmi,
      'bmi_category': BmiCalculator.getCategory(calculatedBmi),
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final calculatedBmi =
        BmiCalculator.calculate(heightCm: heightCm, weightKg: weightKg);
    return {
      'name': name,
      'age': age,
      'gender': gender.label,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': calculatedBmi,
      'bmi_category': BmiCalculator.getCategory(calculatedBmi),
    };
  }
}
