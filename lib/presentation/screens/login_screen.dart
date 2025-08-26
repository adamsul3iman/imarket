import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/login/login_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.success) {
            context.go('/main'); // Navigate to main screen on success
          }
          if (state.status == LoginStatus.failure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failed'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
          }
        },
        child: const _LoginView(),
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordObscured = true;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 120),
                  const SizedBox(height: 40),
                  TextFormField(
                    decoration: const InputDecoration(hintText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
                    onChanged: (value) => context.read<LoginBloc>().add(LoginEmailChanged(value)),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                    ),
                    onChanged: (value) => context.read<LoginBloc>().add(LoginPasswordChanged(value)),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.read<LoginBloc>().add(LoginPasswordResetRequested()),
                      child: const Text('هل نسيت كلمة السر؟'),
                    ),
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      return state.status == LoginStatus.submitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  context.read<LoginBloc>().add(LoginSubmitted());
                                }
                              },
                              child: const Text('تسجيل الدخول'),
                            );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟'),
                      TextButton(
                        // FIX: Activated the navigation to the sign-up screen
                        onPressed: () {
                          context.push('/signup');
                        },
                        child: const Text('إنشاء حساب'),
                      ),
                    ],
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