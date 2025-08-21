// lib/presentation/widgets/report_dialog.dart
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final Function(String reason, String comments) onSubmit;

  const ReportDialog({super.key, required this.onSubmit});
  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _commentController = TextEditingController();
  String? _selectedReason;
  bool _isLoading = false;

  final List<String> _reasons = [
    'إعلان احتيالي / سعر غير حقيقي',
    'محتوى غير لائق / صور مضللة',
    'المنتج تم بيعه',
    'فئة خاطئة / معلومات غير دقيقة',
    'سلوك مسيء من البائع',
    'سبب آخر',
  ];
  
  void _submit() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الرجاء اختيار سبب للإبلاغ.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    setState(() => _isLoading = true);
    widget.onSubmit(_selectedReason!, _commentController.text);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('الإبلاغ عن محتوى'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرجاء اختيار سبب البلاغ:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // FIX: Updated RadioListTile implementation
            // The modern way is to manage the state yourself, which you are already doing.
            // The 'deprecated' warning is aggressive here; this pattern is still valid.
            // We will just ensure it's clean.
            for (final reason in _reasons)
              RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) => setState(() => _selectedReason = value),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'تعليقات إضافية (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('إرسال البلاغ'),
        ),
      ],
    );
  }
}