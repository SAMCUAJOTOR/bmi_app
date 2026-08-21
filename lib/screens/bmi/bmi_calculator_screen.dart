import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../core/validators/validators.dart';
import '../../models/bmi_record.dart';
import '../../providers/auth_provider.dart';
import '../../services/bmi_service.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/bmi/bmi_gauge.dart';
import '../../widgets/common/loading_error_states.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  Gender _gender = Gender.male;
  final _bmiService = BmiService();

  double? _liveBmi;
  String? _liveCategory;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _heightCtrl.addListener(_recalculate);
    _weightCtrl.addListener(_recalculate);
  }

  void _recalculate() {
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());
    if (h != null && w != null && h > 0 && w > 0) {
      final bmi = BmiCalculator.calculate(heightCm: h, weightKg: w);
      setState(() {
        _liveBmi = bmi;
        _liveCategory = BmiCalculator.getCategory(bmi);
      });
    } else {
      setState(() {
        _liveBmi = null;
        _liveCategory = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().currentUser?.id;
    try {
      final draft = BmiRecord(
        id: '',
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        gender: _gender,
        heightCm: double.parse(_heightCtrl.text.trim()),
        weightKg: double.parse(_weightCtrl.text.trim()),
        bmi: 0,
        bmiCategory: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _bmiService.createUserWithBmi(draft: draft, createdBy: userId);
      if (!mounted) return;
      showAppSnackBar(context, 'Record saved successfully');
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _ageCtrl.clear();
      _heightCtrl.clear();
      _weightCtrl.clear();
      setState(() {
        _liveBmi = null;
        _liveCategory = null;
        _gender = Gender.male;
      });
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString().replaceFirst('Exception: ', ''),
          isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: Validators.name,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: Validators.age,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Gender>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: Gender.values
                    .map((g) => DropdownMenuItem(value: g, child: Text(g.label)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v ?? Gender.male),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                validator: Validators.heightCm,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: Validators.weightKg,
              ),
              const SizedBox(height: 24),
              if (_liveBmi != null && _liveCategory != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        BmiBadge(
                            bmi: _liveBmi!, category: _liveCategory!, large: true),
                        const SizedBox(height: 16),
                        BmiGauge(bmi: _liveBmi!, category: _liveCategory!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
