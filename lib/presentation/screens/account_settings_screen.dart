import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imarket/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otp_verification_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isProfileSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null && mounted) {
      setState(() {
        _fullNameController.text =
            user.userMetadata?['full_name'] as String? ?? '';
        _phoneNumberController.text =
            user.phone?.replaceFirst('+962', '') ?? '';
      });
    }
  }

  /// Updates the user's profile information and handles phone verification.
  Future<void> _updateProfile() async {
    if (!_profileFormKey.currentState!.validate() || !mounted) return;
    setState(() => _isProfileSaving = true);

    final newPhoneNumber = '+962${_phoneNumberController.text.trim()}';
    final user = supabase.auth.currentUser;
    final isPhoneChanged = newPhoneNumber != user?.phone;

    try {
      await supabase.auth.updateUser(UserAttributes(
        phone: newPhoneNumber,
        data: {'full_name': _fullNameController.text.trim()},
      ));

      if (mounted) {
        // *** THE FIX IS HERE ***
        // Check if the phone number was changed to decide the next step.
        if (isPhoneChanged) {
          // If the phone number changed, navigate to the OTP screen for verification.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: newPhoneNumber,
                otpType: OtpType.phoneChange,
              ),
            ),
          );
        } else {
          // If only the name was changed, just show a success message and go back.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                // <<< التحسين: رسالة أكثر دقة.
                content: Text('تم تحديث بياناتك بنجاح!'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التحديث: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProfileSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الحساب'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _profileFormKey,
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
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline)),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'الاسم مطلوب' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixText: '+962 ',
                        prefixIcon: Icon(Icons.phone_outlined)),
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
                  _isProfileSaving
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('حفظ التغييرات'),
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
