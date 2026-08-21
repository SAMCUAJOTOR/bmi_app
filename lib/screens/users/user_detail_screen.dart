import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../models/bmi_history.dart';
import '../../models/bmi_record.dart';
import '../../services/bmi_service.dart';
import '../../services/user_service.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/common/loading_error_states.dart';
import '../meal_plan/meal_plan_screen.dart';
import '../nutrition/nutrition_screen.dart';
import '../progress/progress_screen.dart';
import '../workout/workout_screen.dart';

/// User (patient) detail screen.
/// Tabs follow the paper's central flow: Overview (BMI classification) →
/// Nutrition → Meal Plan → Workout → Progress, all driven by this
/// record's current BMI category.
class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final _userService = UserService();
  final _bmiService = BmiService();
  BmiRecord? _user;
  List<BmiHistory> _history = [];
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
      final user = await _userService.getById(widget.userId);
      final history = await _bmiService.historyForUser(widget.userId);
      setState(() {
        _user = user;
        _history = history;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Detail')),
        body: const LoadingState(),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Detail')),
        body: ErrorState(message: _error!, onRetry: _load),
      );
    }

    final u = _user!;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(u.name),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.info_outline, size: 20)),
              Tab(text: 'Nutrition', icon: Icon(Icons.restaurant_menu, size: 20)),
              Tab(text: 'Meal Plan', icon: Icon(Icons.set_meal_outlined, size: 20)),
              Tab(text: 'Workout', icon: Icon(Icons.fitness_center, size: 20)),
              Tab(text: 'Progress', icon: Icon(Icons.show_chart, size: 20)),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: TabBarView(
            children: [
              _OverviewTab(user: u),
              NutritionScreen(record: u),
              MealPlanScreen(record: u),
              WorkoutScreen(record: u),
              ProgressScreen(record: u, history: _history),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final BmiRecord user;
  const _OverviewTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = user;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Personal Information',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoRow('Name', u.name),
                _InfoRow('Age', '${u.age}'),
                _InfoRow('Gender', u.gender.label),
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
                const Text('Current Measurement',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoRow('Height', '${u.heightCm} cm'),
                _InfoRow('Weight', '${u.weightKg} kg'),
                const SizedBox(height: 8),
                BmiBadge(bmi: u.bmi, category: u.bmiCategory, large: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Nutrition, meal plan, workout, and progress are all generated '
          'from this BMI category — see the tabs above.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
