import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/charts/bmi_distribution_chart.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_error_states.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<DashboardProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () => context.read<DashboardProvider>().load(),
        child: Builder(builder: (context) {
          if (dash.isLoading && dash.stats == null) return const LoadingState();
          if (dash.errorMessage != null) {
            return ErrorState(
                message: dash.errorMessage!,
                onRetry: () => context.read<DashboardProvider>().load());
          }
          final stats = dash.stats!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _StatCard(label: 'Total Users', value: '${stats.totalUsers}'),
                  _StatCard(
                      label: 'Average BMI',
                      value: stats.averageBmi.toStringAsFixed(1)),
                  _StatCard(
                      label: 'Underweight',
                      value: '${stats.underweight}',
                      color: categoryColor('Underweight')),
                  _StatCard(
                      label: 'Normal',
                      value: '${stats.normal}',
                      color: categoryColor('Normal')),
                  _StatCard(
                      label: 'Overweight',
                      value: '${stats.overweight}',
                      color: categoryColor('Overweight')),
                  _StatCard(
                      label: 'Obese',
                      value: '${stats.obese}',
                      color: categoryColor('Obese')),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BMI Category Distribution',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      BmiDistributionChart(
                        underweight: stats.underweight,
                        normal: stats.normal,
                        overweight: stats.overweight,
                        obese: stats.obese,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent BMI Records',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (stats.recent.isEmpty)
                        const EmptyState(
                          title: 'No BMI records yet.',
                          subtitle: 'Add your first user to get started.',
                          icon: Icons.monitor_weight_outlined,
                        )
                      else
                        ...stats.recent.map((r) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(r.name),
                              subtitle: Text(
                                  DateFormat('MMM d, yyyy').format(r.createdAt)),
                              trailing: BmiBadge(
                                  bmi: r.bmi, category: r.bmiCategory, compact: true),
                            )),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatCard({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
