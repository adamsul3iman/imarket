// lib/presentation/screens/paywall_screen.dart

import 'package:flutter/material.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ FIX: Add this import

/// شاشة تتيح للمستخدم شراء نقاط أو ترقية اشتراكه.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = false;
  final _supabase = getIt<SupabaseClient>();

  // ✅ FIX: Replace the entire _handlePayment function with this new version
  Future<void> _handlePayment(String itemDescription, double price) async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final user = _supabase.auth.currentUser;

    if (user == null) {
      messenger.showSnackBar(
          const SnackBar(content: Text('يجب تسجيل الدخول أولاً.')));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _supabase.functions.invoke(
        'create-checkout-session',
        body: {
          'amount': price,
          'currency': "JOD",
          'description': itemDescription,
          'name': user.userMetadata?['full_name'] ?? 'iMarket User',
          'email': user.email ?? 'no-email@example.com',
          'userId': user.id
        },
      );

      if (!mounted) return;
      if (response.data == null || response.data['url'] == null) {
        throw Exception('فشل إنشاء رابط الدفع.');
      }
      final redirectUrl = response.data['url'];

      // Use url_launcher to open the Stripe page in the same tab
      final uri = Uri.parse(redirectUrl);
      if (await canLaunchUrl(uri)) {
        // '_self' tells the browser to open in the current tab, which is required by Stripe
        await launchUrl(uri, webOnlyWindowName: '_self');
      } else {
        throw 'لا يمكن فتح الرابط: $redirectUrl';
      }
    } catch (e) {
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
      appBar: AppBar(title: const Text('المتجر والاشتراكات')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSectionHeader(
                      context, 'شراء نقاط التمييز', Icons.star_outline),
                  const SizedBox(height: 16),
                  _buildPurchaseOption(
                    context: context,
                    title: '5 نقاط تمييز',
                    price: 3.00,
                    icon: Icons.star,
                    isBestValue: false,
                    onTap: () => _handlePayment('5 Feature Points', 3.00),
                  ),
                  _buildPurchaseOption(
                    context: context,
                    title: '10 نقاط تمييز',
                    price: 5.00,
                    icon: Icons.star,
                    isBestValue: true,
                    onTap: () => _handlePayment('10 Feature Points', 5.00),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'ترقية الاشتراك',
                      Icons.workspace_premium_outlined),
                  const SizedBox(height: 16),
                  _buildPurchaseOption(
                    context: context,
                    title: 'الخطة الاحترافية (شهري)',
                    price: 10.00,
                    icon: Icons.workspace_premium,
                    isBestValue: false,
                    onTap: () => _handlePayment('Pro Plan (Monthly)', 10.00),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPurchaseOption({
    required BuildContext context,
    required String title,
    required double price,
    required IconData icon,
    required bool isBestValue,
    required VoidCallback onTap,
  }) {
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
              child: Icon(icon, color: Colors.amber.shade700, size: 30),
            ),
            title: Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('${price.toStringAsFixed(2)} دينار أردني'),
            trailing: ElevatedButton(
              onPressed: onTap,
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
