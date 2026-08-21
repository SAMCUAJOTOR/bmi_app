class BmiHistory {
  final String id;
  final String userId;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final String bmiCategory;
  final DateTime recordedAt;
  final String? recordedBy;

  BmiHistory({
    required this.id,
    required this.userId,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    required this.bmiCategory,
    required this.recordedAt,
    this.recordedBy,
  });

  factory BmiHistory.fromMap(Map<String, dynamic> map) {
    return BmiHistory(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      heightCm: (map['height_cm'] as num).toDouble(),
      weightKg: (map['weight_kg'] as num).toDouble(),
      bmi: (map['bmi'] as num).toDouble(),
      bmiCategory: map['bmi_category'] as String? ?? '',
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      recordedBy: map['recorded_by'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap({
    required String userId,
    required String? recordedBy,
  }) {
    return {
      'user_id': userId,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi': bmi,
      'bmi_category': bmiCategory,
      'recorded_by': recordedBy,
    };
  }
}
