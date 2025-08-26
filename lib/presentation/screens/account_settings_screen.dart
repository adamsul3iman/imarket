import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/account_settings/account_settings_bloc.dart';

/// شاشة تسمح للمستخدم بتعديل بيانات حسابه الشخصي مثل الاسم ورقم الهاتف.
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AccountSettingsBloc>()..add(LoadAccountData()),
      child: BlocListener<AccountSettingsBloc, AccountSettingsState>(
        listener: (context, state) {
          if (state.status == AccountSettingsStatus.success) {
            if (state.navigateToOtp) {
              // في حال تغيير رقم الهاتف، يتم الانتقال إلى شاشة تفعيل الرمز
              // context.push('/otp-verification', extra: {'phone': '+962${state.phoneNumber}'});
            } else {
              // في حال نجاح التحديث (بدون تغيير الرقم)
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text('تم تحديث بياناتك بنجاح!'),
                  backgroundColor: Colors.green,
                ));
              context.pop();
            }
          } else if (state.status == AccountSettingsStatus.failure) {
            // في حال فشل التحديث
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ'),
                backgroundColor: Colors.red,
              ));
          }
        },
        child: const _AccountSettingsView(),
      ),
    );
  }
}

/// الواجهة الفعلية للشاشة، تستخدم StatefulWidget لإدارة الـ Controllers.
class _AccountSettingsView extends StatefulWidget {
  const _AccountSettingsView();

  @override
  State<_AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<_AccountSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الحساب')),
      body: BlocConsumer<AccountSettingsBloc, AccountSettingsState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          // مزامنة الـ Controllers مع بيانات الحالة عند تحميلها
          if (state.status == AccountSettingsStatus.loaded) {
            _fullNameController.text = state.fullName;
            _phoneNumberController.text = state.phoneNumber;
          }
        },
        builder: (context, state) {
          if (state.status == AccountSettingsStatus.loading ||
              state.status == AccountSettingsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكامل',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: (value) => context
                            .read<AccountSettingsBloc>()
                            .add(FullNameChanged(value)),
                        validator: (value) => value == null || value.isEmpty
                            ? 'الاسم مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixText: '+962 ',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        onChanged: (value) => context
                            .read<AccountSettingsBloc>()
                            .add(PhoneNumberChanged(value)),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'رقم الهاتف مطلوب';
                          }
                          if (!value.startsWith('7')) {
                            return 'يجب أن يبدأ الرقم بالرقم 7';
                          }
                          if (value.length != 9) {
                            return 'يجب أن يتكون الرقم من 9 أرقام';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      state.status == AccountSettingsStatus.submitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() == true) {
                                  context
                                      .read<AccountSettingsBloc>()
                                      .add(SubmitAccountChanges());
                                }
                              },
                              child: const Text('حفظ التغييرات'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
