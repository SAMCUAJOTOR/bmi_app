import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../bmi/bmi_badge.dart';

/// BMI category distribution donut chart.
///
/// Laid out as chart-on-top, legend-below (a Column), rather than
/// side-by-side, so the donut always has a fixed, generous square area
/// to render into regardless of screen width — it can never be squeezed
/// by a legend column fighting it for horizontal space. The legend below
/// wraps freely so category labels always have room to breathe.
class BmiDistributionChart extends StatelessWidget {
  final int underweight;
  final int normal;
  final int overweight;
  final int obese;

  const BmiDistributionChart({
    super.key,
    required this.underweight,
    required this.normal,
    required this.overweight,
    required this.obese,
  });

  @override
  Widget build(BuildContext context) {
    final total = underweight + normal + overweight + obese;
    if (total == 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No data to display yet.')),
      );
    }

    final data = <String, int>{
      'Underweight': underweight,
      'Normal': normal,
      'Overweight': overweight,
      'Obese': obese,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            height: 180,
            width: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 42,
                sections: [
                  for (final entry in data.entries)
                    if (entry.value > 0)
                      PieChartSectionData(
                        value: entry.value.toDouble(),
                        color: categoryColor(entry.key),
                        title: '${((entry.value / total) * 100).round()}%',
                        radius: 40,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            for (final entry in data.entries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: categoryColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
