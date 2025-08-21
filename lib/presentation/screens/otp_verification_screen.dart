import 'package:flutter/material.dart';
import 'package:imarket/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final OtpType otpType; // <<<--- إضافة متغير جديد لتحديد نوع التحقق

  const OtpVerificationScreen({
    super.key, 
    required this.phoneNumber,
    required this.otpType, // جعله مطلوبًا
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء إدخال الرمز.'), backgroundColor: Colors.red),
        );
        return;
    }
    setState(() => _isLoading = true);
    try {
      await supabase.auth.verifyOTP(
        phone: widget.phoneNumber,
        token: _otpController.text.trim(),
        type: widget.otpType, // <<<--- استخدام النوع الصحيح هنا
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تأكيد رقم الهاتف بنجاح!'), backgroundColor: Colors.green),
        );
        // العودة إلى شاشة حسابي
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز خاطئ أو حدث خطأ'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أدخل رمز التأكيد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('تم إرسال رمز مكون من 6 أرقام إلى الرقم: ${widget.phoneNumber}', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextFormField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'رمز التأكيد (OTP)'),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
            ),
            const SizedBox(height: 24),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(onPressed: _verifyOtp, child: const Text('تأكيد')),
          ],
        ),
      ),
    );
  }
}