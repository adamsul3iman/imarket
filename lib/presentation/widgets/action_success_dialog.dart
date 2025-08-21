import 'package:flutter/material.dart';

/// A reusable dialog to show a success message with a large icon and actions.
class ActionSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const ActionSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'حسنًا',
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      iconPadding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
      icon: Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
      title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onButtonPressed,
            child: Text(buttonText),
          ),
        )
      ],
    );
  }
}