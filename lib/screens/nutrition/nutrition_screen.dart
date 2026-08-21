import 'package:flutter/material.dart';
import '../../core/recommendations/recommendation_engine.dart';
import '../../models/bmi_record.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/recommendations/nutrition_guidance_card.dart';

/// Nutrition Recommendations screen (paper section 9).
/// General, informational guidance generated from the BMI category —
/// explicitly not a medical prescription.
class NutritionScreen extends StatelessWidget {
  final BmiRecord record;
  const NutritionScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final guidance = RecommendationEngine.nutritionFor(record.bmiCategory);
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
                Icon(Icons.restaurant_menu, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your current category: ${record.bmiCategory}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nutrition guidance below is tailored to this category.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final g in guidance) ...[
          NutritionGuidanceCard(guidance: g),
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
