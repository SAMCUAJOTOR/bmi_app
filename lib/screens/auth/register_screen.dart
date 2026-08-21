import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/validators/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_error_states.dart';

/// Admin-only: creates a new Admin or Staff account (Use Case 12).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  AppRole _role = AppRole.staff;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.createAccount(
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passwordCtrl.text,
      role: _role,
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      showAppSnackBar(context, 'Account created successfully');
      Navigator.of(context).pop();
    } else {
      showAppSnackBar(context, auth.errorMessage ?? 'Failed to create account',
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Admin access required')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: Validators.name,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: AppRole.admin, child: Text('Admin')),
                  DropdownMenuItem(value: AppRole.staff, child: Text('Staff')),
                ],
                onChanged: (v) => setState(() => _role = v ?? AppRole.staff),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
