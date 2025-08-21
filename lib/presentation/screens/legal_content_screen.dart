import 'package:flutter/material.dart';

/// A reusable screen to display static legal content like a privacy policy or terms of service.
class LegalContentScreen extends StatelessWidget {
  /// The title to be displayed in the AppBar.
  final String title;

  /// The main body of text to be displayed.
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