import 'package:flutter/foundation.dart'
    show kIsWeb; // استيراد للتحقق من المنصة
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// شاشة تعرض صفحة ويب (مثل بوابة دفع) وتستمع لنتائج النجاح أو الفشل.
class PaymentWebViewScreen extends StatefulWidget {
  final String initialUrl;
  const PaymentWebViewScreen({super.key, required this.initialUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();

    // ✅ FIX: يتم تطبيق هذه الإعدادات فقط على الهواتف (وليس على الويب)
    // هذا يحل مشكلة `UnimplementedError`
    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) {
              setState(() {
                _isLoading = false;
              });
              // التحقق من روابط النجاح أو الإلغاء لإغلاق الشاشة
              if (url.contains('success')) {
                Navigator.pop(context, true); // إرجاع "true" عند النجاح
              } else if (url.contains('cancel')) {
                Navigator.pop(context, false); // إرجاع "false" عند الإلغاء
              }
            },
          ),
        );
    }

    _controller.loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام عملية الدفع')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          // إظهار مؤشر التحميل حتى تنتهي الصفحة من التحميل على الهواتف
          if (_isLoading && !kIsWeb)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
