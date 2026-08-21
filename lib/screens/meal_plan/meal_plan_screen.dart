import 'package:flutter/material.dart';
import '../../core/recommendations/recommendation_engine.dart';
import '../../models/bmi_record.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/common/loading_error_states.dart';
import '../../widgets/recommendations/meal_card.dart';

/// Meal Planning screen (paper section 10).
/// Suggested Breakfast / Lunch / Dinner (+ optional Snack) generated
/// from the user's BMI category.
class MealPlanScreen extends StatefulWidget {
  final BmiRecord record;
  const MealPlanScreen({super.key, required this.record});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final meals = RecommendationEngine.mealPlanFor(widget.record.bmiCategory);
    final color = categoryColor(widget.record.bmiCategory);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.set_meal_outlined, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Meal plan generated for: ${widget.record.bmiCategory} BMI category',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (final m in meals) ...[
          MealCard(meal: m),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: Icon(_saved ? Icons.check : Icons.bookmark_add_outlined),
          label: Text(_saved ? 'Meal Plan Saved' : 'Save Meal Plan'),
          onPressed: _saved
              ? null
              : () {
                  setState(() => _saved = true);
                  showAppSnackBar(context, 'Meal plan saved for ${widget.record.name}');
                },
        ),
      ],
    );
  }
}
