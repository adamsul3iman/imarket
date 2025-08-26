import 'package:flutter/material.dart';

/// شاشة قابلة لإعادة الاستخدام لعرض محتوى نصي ثابت مثل سياسة الخصوصية أو شروط الخدمة.
class LegalContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
