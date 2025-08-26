import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/profile/profile_bloc.dart';

/// شاشة الملف الشخصي، تعرض بيانات المستخدم واشتراكاته وتوفر روابط للإعدادات.
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
            // ...
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileLoggedOut) {
              return _buildLoggedOutView(context);
            }
            if (state is ProfileError) {
              return _buildErrorView(context, state.message);
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
                      _buildProfileHeader(context, profile.fullName,
                          profile.joinDate, profile.rating),
                      const SizedBox(height: 24),
                      _buildSubscriptionCard(context, profile.planName),
                      const SizedBox(height: 24),
                      _buildWalletSection(context, profile.featuredCredits),
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

  Widget _buildProfileHeader(
      BuildContext context, String name, String joinDate, num rating) {
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
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
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
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  Text(
                    planName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // context.push('/paywall'); // Assuming a paywall route exists
              },
              child: const Text('ترقية'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context, int featuredCredits) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildWalletItem(context, 'نقاط التمييز',
                featuredCredits.toString(), Icons.star_outline),
            _buildWalletItem(
                context, 'رصيد الإعلانات', '0', Icons.inventory_2_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(
      BuildContext context, String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.amber),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildMenuItem('لوحة تحكم التاجر', Icons.dashboard_outlined, () {
            // This is handled by the main screen's BottomNavBar, no navigation needed here.
          }),
          _buildMenuItem('عمليات البحث المحفوظة', Icons.saved_search,
              () => context.push('/saved-searches')),
          _buildMenuItem('الإعدادات', Icons.settings_outlined,
              () => context.push('/settings')),
          _buildMenuItem(
            'شروط الخدمة',
            Icons.description_outlined,
            // FIX: Use GoRouter to navigate
            () => context.push('/legal/terms'),
          ),
          _buildMenuItem(
            'سياسة الخصوصية',
            Icons.privacy_tip_outlined,
            // FIX: Use GoRouter to navigate
            () => context.push('/legal/privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return Builder(builder: (context) {
      return ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      );
    });
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

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('حدث خطأ ما'),
          Text(message, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<ProfileBloc>().add(LoadProfileDataEvent()),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('الرجاء تسجيل الدخول لعرض ملفك الشخصي.',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('الذهاب إلى صفحة الدخول'),
          )
        ],
      ),
    );
  }
}
