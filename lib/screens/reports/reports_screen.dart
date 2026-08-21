import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bmi_record.dart';
import '../../providers/auth_provider.dart';
import '../../services/export_service.dart';
import '../../services/report_service.dart';
import '../../widgets/charts/bmi_distribution_chart.dart';
import '../../widgets/common/loading_error_states.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _reportService = ReportService();
  final _exportService = ExportService();

  String _genderFilter = 'All';
  String _ageGroupFilter = 'All';
  DateTimeRange? _dateRange;

  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _reportService.loadReport(
        from: _dateRange?.start,
        to: _dateRange?.end,
        genderFilter: _genderFilter,
        ageGroupFilter: _ageGroupFilter,
      );
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (range != null) {
      setState(() => _dateRange = range);
      _load();
    }
  }

  Future<void> _export(String format) async {
    final records = (_data?['records'] as List<BmiRecord>?) ?? [];
    try {
      final result = format == 'csv'
          ? await _exportService.exportCsv(records)
          : await _exportService.exportPdf(records);
      if (!mounted) return;
      showAppSnackBar(context, 'Exported: ${result.fileName}');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString().replaceFirst('Exception: ', ''),
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.download_outlined),
              onSelected: _export,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'csv', child: Text('Export CSV')),
                PopupMenuItem(value: 'pdf', child: Text('Export PDF')),
              ],
            ),
        ],
      ),
      body: _loading
          ? const LoadingState()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final distribution = _data!['distribution'] as Map<String, int>;
    final ageGroups = _data!['ageGroups'] as Map<String, int>;
    final genderAvgBmi = _data!['genderAvgBmi'] as Map<String, double>;
    final hasEnoughData = _data!['hasEnoughData'] as bool;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(_dateRange == null
                    ? 'Date Range'
                    : '${_dateRange!.start.month}/${_dateRange!.start.day} - ${_dateRange!.end.month}/${_dateRange!.end.day}'),
              ),
              DropdownButton<String>(
                value: _genderFilter,
                items: ['All', 'Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _genderFilter = v ?? 'All');
                  _load();
                },
              ),
              DropdownButton<String>(
                value: _ageGroupFilter,
                items: ['All', 'Under 18', '18-29', '30-44', '45-59', '60+']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _ageGroupFilter = v ?? 'All');
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasEnoughData)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Not enough data for meaningful analysis.'),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BMI Distribution',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    BmiDistributionChart(
                      underweight: distribution['Underweight'] ?? 0,
                      normal: distribution['Normal'] ?? 0,
                      overweight: distribution['Overweight'] ?? 0,
                      obese: distribution['Obese'] ?? 0,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Age Group Breakdown',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...ageGroups.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(e.key)),
                              const SizedBox(width: 8),
                              Text('${e.value} users',
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender Comparison (Avg BMI)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...genderAvgBmi.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(e.key)),
                              const SizedBox(width: 8),
                              Text(e.value.toStringAsFixed(1),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
