import 'package:flutter/material.dart';
import 'package:imarket/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isPasswordSaving = false;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  /// Changes the user's password in Supabase Auth.
  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate() || !mounted) return;

    setState(() => _isPasswordSaving = true);

    try {
      await supabase.auth.updateUser(UserAttributes(
        password: _newPasswordController.text.trim(),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم تغيير كلمة المرور بنجاح!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back after success
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تغيير كلمة المرور: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPasswordSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير كلمة المرور'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _passwordFormKey,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور الجديدة',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isNewPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _isNewPasswordObscured = !_isNewPasswordObscured),
                      ),
                    ),
                    obscureText: _isNewPasswordObscured,
                    validator: (value) => value == null || value.length < 6
                        ? 'يجب أن تكون 6 أحرف على الأقل'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور الجديدة',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() =>
                            _isConfirmPasswordObscured =
                                !_isConfirmPasswordObscured),
                      ),
                    ),
                    obscureText: _isConfirmPasswordObscured,
                    validator: (value) => value != _newPasswordController.text
                        ? 'كلمتا المرور غير متطابقتين'
                        : null,
                  ),
                  const SizedBox(height: 32),
                  _isPasswordSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _changePassword,
                          child: const Text('تغيير كلمة المرور'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}