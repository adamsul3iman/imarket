import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/signup/signup_bloc.dart';

/// شاشة لإنشاء حساب مستخدم جديد.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SignUpBloc>(),
      child: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == SignUpStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('تم إرسال رابط التأكيد إلى بريدك الإلكتروني.'),
                backgroundColor: Colors.green,
              ));
            context.pop();
          }
          if (state.status == SignUpStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'Sign Up Failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
          }
        },
        child: const _SignUpView(),
      ),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: BlocBuilder<SignUpBloc, SignUpState>(
                builder: (context, state) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logo.png', height: 120),
                      const SizedBox(height: 40),
                      TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'الاسم الكامل',
                            prefixIcon: Icon(Icons.person_outline)),
                        onChanged: (value) => context
                            .read<SignUpBloc>()
                            .add(SignUpFullNameChanged(value)),
                        validator: (value) => value == null || value.isEmpty
                            ? 'الاسم الكامل مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email_outlined)),
                        onChanged: (value) => context
                            .read<SignUpBloc>()
                            .add(SignUpEmailChanged(value)),
                        validator: (value) => value == null || value.isEmpty
                            ? 'البريد الإلكتروني مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: _isPasswordObscured,
                        decoration: InputDecoration(
                          hintText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordObscured
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                _isPasswordObscured = !_isPasswordObscured),
                          ),
                        ),
                        onChanged: (value) => context
                            .read<SignUpBloc>()
                            .add(SignUpPasswordChanged(value)),
                        validator: (value) => value == null || value.length < 8
                            ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: _isConfirmPasswordObscured,
                        decoration: InputDecoration(
                          hintText: 'تأكيد كلمة المرور',
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
                            .read<SignUpBloc>()
                            .add(SignUpConfirmPasswordChanged(value)),
                        validator: (value) => value != state.password
                            ? 'كلمتا المرور غير متطابقتين'
                            : null,
                      ),
                      const SizedBox(height: 30),
                      state.status == SignUpStatus.submitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  context
                                      .read<SignUpBloc>()
                                      .add(SignUpSubmitted());
                                }
                              },
                              child: const Text('إنشاء الحساب'),
                            ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('لديك حساب بالفعل؟'),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('سجل الدخول'),
                          ),
                        ],
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
