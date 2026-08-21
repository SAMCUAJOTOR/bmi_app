import 'package:flutter/material.dart';
import '../../core/recommendations/recommendation_engine.dart';

IconData workoutIcon(String type) {
  final t = type.toLowerCase();
  if (t.contains('walk')) return Icons.directions_walk;
  if (t.contains('jog') || t.contains('run')) return Icons.directions_run;
  if (t.contains('cycl')) return Icons.directions_bike;
  if (t.contains('swim')) return Icons.pool_outlined;
  if (t.contains('strength')) return Icons.fitness_center;
  if (t.contains('yoga') || t.contains('stretch')) return Icons.self_improvement;
  if (t.contains('chair') || t.contains('seated')) return Icons.chair_outlined;
  return Icons.sports_gymnastics_outlined;
}

Color _intensityColor(String intensity) {
  final i = intensity.toLowerCase();
  if (i.contains('light') && !i.contains('moderate')) return const Color(0xFF22A06B);
  if (i.contains('moderate')) return const Color(0xFFF59E0B);
  return const Color(0xFF3B82F6);
}

class WorkoutCard extends StatelessWidget {
  final WorkoutSuggestion workout;
  const WorkoutCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(workoutIcon(workout.type), color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workout.type,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                _Stat(label: 'Duration', value: workout.duration, icon: Icons.timer_outlined),
                _Stat(
                  label: 'Intensity',
                  value: workout.intensity,
                  icon: Icons.speed_outlined,
                  valueColor: _intensityColor(workout.intensity),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(workout.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  const _Stat({required this.label, required this.value, required this.icon, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: valueColor ?? Colors.black87),
        ),
      ],
    );
  }
}
