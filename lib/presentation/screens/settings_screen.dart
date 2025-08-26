import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// شاشة الإعدادات الرئيسية للتطبيق.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final supabase = getIt<SupabaseClient>();
    await supabase.auth.signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              _buildSettingsSection(
                context: context,
                items: [
                  _buildPickerItem(
                    context: context,
                    icon: Icons.public,
                    title: 'الدولة',
                    value: 'الأردن 🇯🇴',
                    onTap: () {},
                  ),
                  _buildSwitchItem(
                    context: context,
                    icon: Icons.nightlight_round,
                    title: 'الوضع الليلي',
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                context: context,
                items: [
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.block,
                    title: 'المستخدمين المحظورين',
                    onTap: () => context.push('/blocked-users'),
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'إعدادات الحساب',
                    onTap: () => context.push('/account-settings'),
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'تعديل كلمة المرور',
                    onTap: () => context.push('/change-password'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                context: context,
                items: [
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.description_outlined,
                    title: 'إتفاقية الاستخدام',
                    onTap: () => context.push('/legal/terms'),
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    onTap: () => context.push('/legal/privacy'),
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.help_outline,
                    title: 'المساعدة',
                    onTap: () =>
                        context.push('/coming-soon', extra: 'المساعدة'),
                  ),
                  _buildNavigationItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'عن التطبيق',
                    onTap: () =>
                        context.push('/coming-soon', extra: 'عن التطبيق'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      {required BuildContext context, required List<Widget> items}) {
    return Card(
      child: Column(children: items),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildPickerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('تسجيل الخروج'),
        onPressed: () => _signOut(context),
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
