// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/profile/profile_bloc.dart';
import 'paywall_screen.dart';
import 'legal_content_screen.dart';
import 'saved_searches_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(LoadProfileDataEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حسابي'),
          centerTitle: false,
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoggedOut &&
                ModalRoute.of(context)?.isCurrent == true) {
              context.go('/login');
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoggedOut) {
              return _buildLoggedOutView(context);
            }

            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }

            if (state is ProfileLoaded) {
              final profile = state.userProfile;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(LoadProfileDataEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHeader(
                          profile.fullName, profile.joinDate, profile.rating),
                      const SizedBox(height: 24),
                      _buildSubscriptionCard(context, profile.planName),
                      const SizedBox(height: 24),
                      _buildWalletSection(profile.featuredCredits),
                      const SizedBox(height: 24),
                      _buildMenuSection(context),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // =================== Build Widgets ===================

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => context.go('/login'),
        child: const Text('الذهاب إلى صفحة الدخول'),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.read<ProfileBloc>().add(SignOutEvent()),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String joinDate, num rating) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 30, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('عضو منذ $joinDate',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text('التقييم: ${rating.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, String planName) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .primaryContainer
          .withAlpha((255 * 0.4).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خطة الاشتراك الحالية',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  Text(
                    planName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => context.go('/paywall'),
              child: const Text('ترقية'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSection(int featuredCredits) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWalletItem(
                'نقاط التمييز', featuredCredits.toString(), Icons.star_outline),
            _buildWalletItem('رصيد الإعلانات', '0', Icons.inventory_2_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.amber),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildMenuItem('لوحة تحكم التاجر', Icons.dashboard_outlined,
              () => context.go('/dashboard')),
          _buildMenuItem('عمليات البحث المحفوظة', Icons.saved_search,
              () => context.go('/saved_searches')),
          _buildMenuItem('الإعدادات', Icons.settings_outlined,
              () => context.go('/settings')),
          _buildMenuItem(
            'شروط الخدمة',
            Icons.description_outlined,
            () => context.go('/legal_content', extra: {
              'title': 'شروط الخدمة',
              'content':
                  '1. القبول بالشروط\nباستخدامك لتطبيق iMarket JO، فإنك توافق على الالتزام بهذه الشروط والأحكام...',
            }),
          ),
          _buildMenuItem(
            'سياسة الخصوصية',
            Icons.privacy_tip_outlined,
            () => context.go('/legal_content', extra: {
              'title': 'سياسة الخصوصية',
              'content':
                  '1. جمع المعلومات\nنقوم بجمع المعلومات التي تقدمها مباشرة عند إنشاء حساب...',
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
