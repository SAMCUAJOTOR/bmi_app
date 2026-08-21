import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../core/validators/validators.dart';
import '../../models/bmi_record.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/bmi_service.dart';
import '../../widgets/bmi/bmi_badge.dart';
import '../../widgets/common/loading_error_states.dart';

class EditUserScreen extends StatefulWidget {
  final BmiRecord user;
  const EditUserScreen({super.key, required this.user});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late Gender _gender;
  double? _liveBmi;
  String? _liveCategory;
  bool _saving = false;
  final _bmiService = BmiService();

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameCtrl = TextEditingController(text: u.name);
    _ageCtrl = TextEditingController(text: u.age.toString());
    _heightCtrl = TextEditingController(text: u.heightCm.toString());
    _weightCtrl = TextEditingController(text: u.weightKg.toString());
    _gender = u.gender;
    _liveBmi = u.bmi;
    _liveCategory = u.bmiCategory;
  }

  void _recalc() {
    final h = double.tryParse(_heightCtrl.text.trim());
    final w = double.tryParse(_weightCtrl.text.trim());
    if (h != null && w != null && h > 0 && w > 0) {
      final bmi = BmiCalculator.calculate(heightCm: h, weightKg: w);
      setState(() {
        _liveBmi = bmi;
        _liveCategory = BmiCalculator.getCategory(bmi);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().currentUser?.id;
    try {
      final draft = BmiRecord(
        id: widget.user.id,
        name: _nameCtrl.text.trim(),
        age: int.parse(_ageCtrl.text.trim()),
        gender: _gender,
        heightCm: double.parse(_heightCtrl.text.trim()),
        weightKg: double.parse(_weightCtrl.text.trim()),
        bmi: 0,
        bmiCategory: '',
        createdAt: widget.user.createdAt,
        updatedAt: DateTime.now(),
      );
      await _bmiService.updateUserWithBmi(
        userId: widget.user.id,
        draft: draft,
        updatedBy: userId,
      );
      if (!mounted) return;
      await context.read<UserProvider>().load();
      if (!mounted) return;
      showAppSnackBar(context, 'User updated successfully');
      Navigator.of(context).pop();
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
      appBar: AppBar(title: const Text('Edit User')),
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
                onChanged: (_) => _recalc(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator: Validators.weightKg,
                onChanged: (_) => _recalc(),
              ),
              if (_liveBmi != null) ...[
                const SizedBox(height: 16),
                BmiBadge(bmi: _liveBmi!, category: _liveCategory!),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
