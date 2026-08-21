import 'package:flutter/material.dart';
import '../../core/utils/bmi_calculator.dart';
import 'bmi_badge.dart';

class BmiGauge extends StatelessWidget {
  final double bmi;
  final String category;

  const BmiGauge({super.key, required this.bmi, required this.category});

  @override
  Widget build(BuildContext context) {
    final fraction = BmiCalculator.gaugeFraction(bmi);
    final color = categoryColor(category);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(height: 12, color: Colors.grey.shade200),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0.02, 1.0),
            child: Container(height: 12, color: color),
          ),
        ],
      ),
    );
  }
}
