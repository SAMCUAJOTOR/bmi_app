import 'package:flutter/material.dart';
import '../../core/recommendations/recommendation_engine.dart';

IconData mealIcon(String mealName) {
  switch (mealName) {
    case 'Breakfast':
      return Icons.free_breakfast_outlined;
    case 'Lunch':
      return Icons.lunch_dining_outlined;
    case 'Dinner':
      return Icons.dinner_dining_outlined;
    default:
      return Icons.cookie_outlined;
  }
}

class MealCard extends StatelessWidget {
  final MealSuggestion meal;
  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(mealIcon(meal.mealName), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.mealName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.suggestion,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
