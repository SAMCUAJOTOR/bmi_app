import 'package:flutter/material.dart';
import '../../core/recommendations/recommendation_engine.dart';

class NutritionGuidanceCard extends StatelessWidget {
  final NutritionGuidance guidance;
  const NutritionGuidanceCard({super.key, required this.guidance});

  IconData get _icon {
    switch (guidance.title) {
      case 'Prioritize':
        return Icons.check_circle_outline;
      case 'Limit':
        return Icons.block;
      case 'Portion control':
        return Icons.restaurant_outlined;
      case 'Healthy habits':
        return Icons.local_drink_outlined;
      case 'Eat more often':
        return Icons.schedule_outlined;
      case 'Maintain balance':
        return Icons.balance_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guidance.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(guidance.detail, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in guidance.examples)
                  Chip(
                    label: Text(e, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: color.withValues(alpha: 0.08),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
