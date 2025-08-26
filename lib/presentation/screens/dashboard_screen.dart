import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/blocs/dashboard/dashboard_bloc.dart';

/// شاشة لوحة تحكم التاجر، تعرض إحصائيات وإعلانات المستخدم.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<DashboardBloc>()..add(LoadDashboardDataEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة تحكم التاجر'),
          centerTitle: false,
        ),
        body: BlocListener<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardActionSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ));
            }
            if (state is DashboardError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ));
            }
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading || state is DashboardInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DashboardLoggedOut) {
                return _buildLoggedOutView(context);
              }
              if (state is DashboardError) {
                return _buildErrorView(context, state.message);
              }
              if (state is DashboardLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DashboardBloc>().add(LoadDashboardDataEvent());
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildStatsCard(
                        context,
                        state.userAds,
                        state.topDemandModel,
                        state.hasSubscription,
                      ),
                      const SizedBox(height: 24),
                      _buildMyAdsHeader(context),
                      const Divider(),
                      if (state.userAds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                              child: Text('ليس لديك أي إعلانات منشورة.')),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.userAds.length,
                          itemBuilder: (context, index) {
                            final ad = state.userAds[index];
                            return _buildAdListItem(
                                context, ad, state.hasSubscription);
                          },
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, List<Ad> ads,
      String topDemandModel, bool hasSubscription) {
    final totalViews = ads.fold<int>(0, (sum, ad) => sum + ad.viewCount);
    final totalWhatsappClicks =
        ads.fold<int>(0, (sum, ad) => sum + ad.whatsappClicks);
    final totalCallClicks = ads.fold<int>(0, (sum, ad) => sum + ad.callClicks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('نظرة عامة على الأداء',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.inventory_2_outlined,
                    ads.length.toString(), 'إعلان نشط', context),
                hasSubscription
                    ? _buildStatItem(Icons.visibility, totalViews.toString(),
                        'مشاهدة فريدة', context)
                    : _buildUpgradeStatItem('مشاهدات فريدة', context),
                _buildStatItem(Icons.wechat_outlined,
                    totalWhatsappClicks.toString(), 'نقرة واتساب', context),
                _buildStatItem(Icons.phone_outlined, totalCallClicks.toString(),
                    'نقرة اتصال', context),
              ],
            ),
            const Divider(height: 32),
            ListTile(
              leading: Icon(Icons.show_chart, color: Colors.green.shade700),
              title: const Text('مؤشر الطلب في السوق'),
              subtitle: Text('الطلب مرتفع حالياً على أجهزة: $topDemandModel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildUpgradeStatItem(String label, BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/paywall');
      },
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 30, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'تتطلب ترقية',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMyAdsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('إعلاناتي المنشورة',
            style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 28),
          tooltip: 'إضافة إعلان جديد',
          onPressed: () async {
            final result = await context.push<bool>('/add-ad');
            if (result == true && context.mounted) {
              context.read<DashboardBloc>().add(LoadDashboardDataEvent());
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdListItem(BuildContext context, Ad ad, bool hasSubscription) {
    final bool isSold = ad.status == 'sold';
    return Opacity(
      opacity: isSold ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          title: Row(
            children: [
              Expanded(child: Text(ad.title, overflow: TextOverflow.ellipsis)),
              if (isSold)
                const Chip(
                  label: Text('مباع'),
                  backgroundColor: Colors.grey,
                  labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                '${ad.price} دينار',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Icon(
                hasSubscription ? Icons.visibility : Icons.visibility_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(ad.viewCount.toString(),
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                context.push('/edit-ad', extra: ad);
              }
              if (value == 'delete') {
                context.read<DashboardBloc>().add(DeleteAdEvent(ad.id));
              }
              if (value == 'mark_sold') {
                context.read<DashboardBloc>().add(MarkAdAsSoldEvent(ad.id));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              if (!isSold)
                const PopupMenuItem<String>(
                  value: 'mark_sold',
                  child: ListTile(
                    leading: Icon(Icons.sell_outlined, color: Colors.green),
                    title: Text('تمييز كمباع',
                        style: TextStyle(color: Colors.green)),
                  ),
                ),
              if (!isSold) const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('تعديل الإعلان'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title:
                      Text('حذف الإعلان', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
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
                context.read<DashboardBloc>().add(LoadDashboardDataEvent()),
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
          const Text('يجب تسجيل الدخول لعرض هذه الصفحة.',
              style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('الذهاب إلى صفحة الدخول'),
          )
        ],
      ),
    );
  }
}
