import 'package:flutter/material.dart';
import 'package:imarket/main.dart';
import 'package:imarket/presentation/screens/payment_webview_screen.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _handlePayment(int credits, double price) async {
    setState(() => _isLoading = true);

    // تخزين المتغيرات التي تعتمد على context قبل أي await
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final user = supabase.auth.currentUser;
    if (user == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً.')));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // --- await #1 ---
      final response = await supabase.functions.invoke(
        'create-checkout-session',
        body: {
          'amount': price,
          'currency': "JOD",
          'description': "$credits Feature Points",
          'name': user.userMetadata?['full_name'] ?? 'iMarket User',
          'email': user.email ?? 'no-email@example.com',
          'userId': user.id
        },
      );

      // <<< التحسين: التحقق من أن الواجهة لا تزال موجودة بعد أول await
      if (!mounted) return;

      if (response.data == null || response.data['url'] == null) {
        throw Exception('فشل إنشاء رابط الدفع.');
      }
      final redirectUrl = response.data['url'];

      // --- await #2 ---
      final paymentResult = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(initialUrl: redirectUrl),
        ),
      );

      // <<< التحسين: التحقق مرة أخرى بعد العودة من شاشة الدفع
      if (!mounted) return;

      if (paymentResult == true) {
        // --- await #3 ---
        await supabase.rpc('purchase_feature_credits',
            params: {'p_credits_to_add': credits});

        // <<< التحسين: التحقق مرة ثالثة قبل إظهار الرسالة والعودة
        if (!mounted) return;

        messenger.showSnackBar(
          SnackBar(
            content: Text('تمت إضافة $credits نقطة إلى محفظتك بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop(true);
      }
    } catch (e) {
      // نستخدم المتغير المخزن messenger هنا أيضًا للأمان
      messenger.showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شراء نقاط')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionHeader(context, 'شراء نقاط التمييز',
                      Icons.shopping_cart_outlined),
                  const SizedBox(height: 16),
                  _buildCreditPurchaseOption(context, 5, 3.00),
                  _buildCreditPurchaseOption(context, 10, 5.00),
                ],
              ),
            ),
    );
  }

  Widget _buildCreditPurchaseOption(
      BuildContext context, int credits, double price) {
    bool isBestValue = credits == 10;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isBestValue ? Colors.amber.shade700 : Colors.transparent,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withAlpha(25),
              child: Icon(Icons.star, color: Colors.amber.shade700, size: 30),
            ),
            title: Text('$credits نقاط تمييز',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('${price.toStringAsFixed(2)} دينار أردني'),
            trailing: ElevatedButton(
              onPressed: () => _handlePayment(credits, price),
              child: const Text('شراء'),
            ),
          ),
          if (isBestValue)
            Positioned(
              top: 0,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )),
                child: const Text(
                  'الأفضل قيمة',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
