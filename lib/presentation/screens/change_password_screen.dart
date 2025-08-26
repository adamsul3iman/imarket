import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/change_password/change_password_bloc.dart';

/// شاشة تسمح للمستخدم بتغيير كلمة المرور الخاصة بحسابه.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChangePasswordBloc>(),
      child: BlocListener<ChangePasswordBloc, ChangePasswordState>(
        listener: (context, state) {
          if (state.status == ChangePasswordStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('تم تغيير كلمة المرور بنجاح!'),
                backgroundColor: Colors.green,
              ));
            context.pop();
          } else if (state.status == ChangePasswordStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ));
          }
        },
        child: const _ChangePasswordView(),
      ),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        obscureText: _isNewPasswordObscured,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور الجديدة',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isNewPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                _isNewPasswordObscured =
                                    !_isNewPasswordObscured),
                          ),
                        ),
                        onChanged: (value) => context
                            .read<ChangePasswordBloc>()
                            .add(NewPasswordChanged(value)),
                        validator: (value) => value == null || value.length < 6
                            ? 'يجب أن تكون 6 أحرف على الأقل'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        obscureText: _isConfirmPasswordObscured,
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
                        onChanged: (value) => context
                            .read<ChangePasswordBloc>()
                            .add(ConfirmPasswordChanged(value)),
                        validator: (value) => value != state.newPassword
                            ? 'كلمتا المرور غير متطابقتين'
                            : null,
                      ),
                      const SizedBox(height: 32),
                      state.status == ChangePasswordStatus.submitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  context
                                      .read<ChangePasswordBloc>()
                                      .add(ChangePasswordSubmitted());
                                }
                              },
                              child: const Text('تغيير كلمة المرور'),
                            ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
