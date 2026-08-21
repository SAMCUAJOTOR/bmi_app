import 'package:flutter/material.dart';

Color categoryColor(String category) {
  switch (category) {
    case 'Underweight':
      return const Color(0xFF3B82F6); // blue
    case 'Normal':
      return const Color(0xFF22A06B); // green
    case 'Overweight':
      return const Color(0xFFF59E0B); // amber
    case 'Obese':
      return const Color(0xFFEF4444); // red
    default:
      return Colors.grey;
  }
}

/// Everywhere BMI appears: value + category, immediately understandable.
///
/// Two layouts:
/// - Default / [large]: value stacked above the category pill. Use for
///   headline placements (calculator result, detail screen header) that
///   have generous vertical room.
/// - [compact]: value and pill laid out side-by-side on one line. Use
///   this inside ListTile `trailing` slots and other tight, fixed-height
///   rows — the stacked layout does not fit there and overflows.
class BmiBadge extends StatelessWidget {
  final double bmi;
  final String category;
  final bool large;
  final bool compact;

  const BmiBadge({
    super.key,
    required this.bmi,
    required this.category,
    this.large = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);

    final valueText = Text(
      bmi.toStringAsFixed(1),
      style: TextStyle(
        fontSize: large ? 36 : (compact ? 16 : 20),
        fontWeight: FontWeight.bold,
      ),
    );

    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10 : 12,
          letterSpacing: 0.5,
        ),
      ),
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          valueText,
          const SizedBox(width: 8),
          pill,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        valueText,
        const SizedBox(height: 4),
        pill,
      ],
    );
  }
}
