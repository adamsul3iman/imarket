import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/blocs/ad_analysis/ad_analysis_bloc.dart';

class AdAnalysisScreen extends StatelessWidget {
  final Ad ad;
  const AdAnalysisScreen({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) =>
          getIt<AdAnalysisBloc>()..add(FetchMarketAnalysis(ad.id)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تحليلات الإعلان'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تحليلات أداء إعلانك',
                style: textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                ad.title,
                style: textTheme.titleMedium
                    ?.copyWith(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 24),
              _buildPerformanceCard(context),
              const SizedBox(height: 24),
              _buildMarketAnalysisCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetricItem(context, Icons.visibility_outlined,
                'عدد المشاهدات', ad.viewCount.toString()),
            const Divider(),
            _buildMetricItem(context, Icons.wechat_outlined, 'نقرات واتساب',
                ad.whatsappClicks.toString()),
            const Divider(),
            _buildMetricItem(context, Icons.phone_outlined, 'نقرات الاتصال',
                ad.callClicks.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketAnalysisCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AdAnalysisBloc, AdAnalysisState>(
          builder: (context, state) {
            if (state.status == AdAnalysisStatus.loading ||
                state.status == AdAnalysisStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == AdAnalysisStatus.failure) {
              return Center(
                  child: Text(
                      state.errorMessage ?? 'حدث خطأ في تحميل تحليل السوق.'));
            }
            if (state.analysis == null) {
              return const Center(child: Text('لا توجد بيانات تحليلية.'));
            }

            final analysis = state.analysis!;
            final textTheme = Theme.of(context).textTheme;
            final colorScheme = Theme.of(context).colorScheme;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مؤشر العرض والطلب',
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.trending_up,
                      color: colorScheme.primary, size: 40),
                  title:
                      Text(analysis.demandText, style: textTheme.titleMedium),
                  subtitle: Text(
                      'متوسط سعر البيع في السوق: ${analysis.averagePrice} دينار'),
                ),
                const SizedBox(height: 16),
                Text(
                  analysis.priceComparisonText,
                  style: textTheme.bodyLarge,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricItem(
      BuildContext context, IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 30),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Text(value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
