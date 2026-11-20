import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/validators.dart';
import 'widgets/auth_decoration.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/password_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _genders = ['Female', 'Male', 'Other', 'Prefer not to say'];
  static const _gap = SizedBox(height: 16);

  final _formKey = GlobalKey<FormState>();
  final _confirmKey = GlobalKey<FormFieldState<String>>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = PasswordEditingController();
  final _confirmCtrl = PasswordEditingController();

  String? _gender;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // Clean values, ready to send to Supabase later.
    final name = _nameCtrl.text.trim();
    final age = int.parse(_ageCtrl.text.trim());
    final gender = _gender!;
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text; // the real password, not the dots
    debugPrint('Sign up: $name, $age, $gender, $email'); // never log password

    setState(() => _loading = true);
    // TODO(Supabase): create the account here using the values above.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/account-created');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create an account',
      subtitle: 'Tell us a little about you to get started.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameCtrl,
              validator: Validators.name,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
                FilteringTextInputFormatter.allow(
                  RegExp(r"[\p{L} '\-]", unicode: true),
                ),
              ],
              decoration: authInputDecoration(
                context,
                label: 'Name',
                icon: Icons.person_outline,
              ),
            ),
            _gap,
            TextFormField(
              controller: _ageCtrl,
              validator: Validators.age,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: authInputDecoration(
                context,
                label: 'Age',
                icon: Icons.cake_outlined,
              ),
            ),
            _gap,
            DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              validator: Validators.gender,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              items: [
                for (final g in _genders)
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (value) => setState(() => _gender = value),
              decoration: authInputDecoration(
                context,
                label: 'Gender',
                icon: Icons.people_outline,
              ),
            ),
            _gap,
            TextFormField(
              controller: _emailCtrl,
              validator: Validators.email,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              autofillHints: const [AutofillHints.email],
              inputFormatters: [
                LengthLimitingTextInputFormatter(254),
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: authInputDecoration(
                context,
                label: 'Email',
                icon: Icons.mail_outline,
              ),
            ),
            _gap,
            PasswordField(
              controller: _passwordCtrl,
              label: 'Create password',
              validator: (v) => Validators.password(
                v,
                name: _nameCtrl.text,
                email: _emailCtrl.text,
              ),
              // Re-check "confirm" whenever the password changes.
              onChanged: (_) {
                if (_confirmCtrl.text.isNotEmpty) {
                  _confirmKey.currentState?.validate();
                }
              },
            ),
            const SizedBox(height: 8),
            PasswordChecklist(controller: _passwordCtrl),
            _gap,
            PasswordField(
              controller: _confirmCtrl,
              fieldKey: _confirmKey,
              label: 'Confirm password',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordCtrl.text),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
                  : const Text('Sign Up'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => context.pushReplacement('/login'),
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
