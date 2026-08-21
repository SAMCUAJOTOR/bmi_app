import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bmi_history.dart';
import '../../models/bmi_record.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/common/empty_state.dart';

/// Progress Monitoring screen (paper section 12).
/// Shows the BMI trend over time, a progress summary comparing the two
/// most recent records, and the full chronological BMI history.
class ProgressScreen extends StatelessWidget {
  final BmiRecord record;
  final List<BmiHistory> history;

  const ProgressScreen({super.key, required this.record, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart,
        title: 'No BMI record yet',
        subtitle: 'Calculate a BMI to start tracking progress over time.',
      );
    }

    final sorted = [...history]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final current = sorted.last;
    final previous = sorted.length > 1 ? sorted[sorted.length - 2] : null;
    final change = previous == null ? null : current.bmi - previous.bmi;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Progress Summary', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Current BMI',
                child: BmiBadge(bmi: current.bmi, category: current.bmiCategory),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                label: previous == null ? 'Previous BMI' : 'Change',
                child: previous == null
                    ? Text('—', style: TextStyle(color: Colors.grey.shade500, fontSize: 20))
                    : _ChangeIndicator(change: change!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('BMI Trend', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (sorted.length < 2)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Only one BMI record so far — a trend will appear once '
                    'there are at least two records.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 26,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= sorted.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat('MM/dd').format(sorted[i].recordedAt),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (int i = 0; i < sorted.length; i++)
                            FlSpot(i.toDouble(), sorted[i].bmi),
                        ],
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text('BMI History', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...sorted.reversed.map(
          (h) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(DateFormat('MMM d, yyyy • HH:mm').format(h.recordedAt)),
              subtitle: Text('BMI ${h.bmi.toStringAsFixed(1)}  •  ${h.weightKg} kg'),
              trailing: BmiBadge(bmi: h.bmi, category: h.bmiCategory, compact: true),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final Widget child;
  const _SummaryTile({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChangeIndicator extends StatelessWidget {
  final double change;
  const _ChangeIndicator({required this.change});

  @override
  Widget build(BuildContext context) {
    final improving = change < 0;
    final flat = change == 0;
    final color = flat ? Colors.grey.shade600 : (improving ? const Color(0xFF22A06B) : const Color(0xFFF59E0B));
    final icon = flat
        ? Icons.horizontal_rule
        : (improving ? Icons.trending_down : Icons.trending_up);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
        ),
      ],
    );
  }
}
