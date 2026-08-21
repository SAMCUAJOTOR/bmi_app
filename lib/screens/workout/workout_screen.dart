import 'package:flutter/material.dart';
import '../../core/recommendations/recommendation_engine.dart';
import '../../models/bmi_record.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/recommendations/workout_card.dart';

/// Workout Recommendations screen (paper section 11).
/// General, informational exercise type/duration/intensity guidance
/// generated from the user's BMI category.
class WorkoutScreen extends StatelessWidget {
  final BmiRecord record;
  const WorkoutScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final workouts = RecommendationEngine.workoutsFor(record.bmiCategory);
    final color = categoryColor(record.bmiCategory);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.fitness_center, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Workout suggestions for: ${record.bmiCategory} BMI category',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final w in workouts) ...[
          WorkoutCard(workout: w),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        Text(
          RecommendationEngine.medicalDisclaimer,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
