import 'package:flutter/material.dart';
import 'package:imarket/main.dart';
import 'package:imarket/models/ad_model.dart';

class AdAnalysisScreen extends StatefulWidget {
  final AdModel ad;
  const AdAnalysisScreen({super.key, required this.ad});

  @override
  State<AdAnalysisScreen> createState() => _AdAnalysisScreenState();
}

class _AdAnalysisScreenState extends State<AdAnalysisScreen> {
  late Future<Map<String, dynamic>> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _fetchMarketAnalysis();
  }

  /// Calls the Supabase RPC function to get real-time market analysis.
  Future<Map<String, dynamic>> _fetchMarketAnalysis() async {
    try {
      final result = await supabase.rpc(
        'get_market_analysis',
        params: {'p_ad_id': widget.ad.id},
      );
      return result as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching market analysis: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
              widget.ad.title,
              style:
                  textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            _buildPerformanceCard(),
            const SizedBox(height: 24),
            _buildMarketAnalysisCard(),
          ],
        ),
      ),
    );
  }

  /// Builds the card for basic ad performance (views, clicks).
  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetricItem(context, Icons.visibility_outlined,
                'عدد المشاهدات', widget.ad.viewCount.toString()),
            const Divider(),
            _buildMetricItem(context, Icons.wechat_outlined, 'نقرات واتساب',
                widget.ad.whatsappClicks.toString()),
            const Divider(),
            _buildMetricItem(context, Icons.phone_outlined, 'نقرات الاتصال',
                widget.ad.callClicks.toString()),
          ],
        ),
      ),
    );
  }

  /// Builds the card for the new, real-time market analysis.
  Widget _buildMarketAnalysisCard() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _analysisFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ في تحميل تحليل السوق.'));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('لا توجد بيانات تحليلية.'));
            }

            final analysis = snapshot.data!;
            final avgPrice = analysis['average_price'];
            final demandText = analysis['demand_text'];
            final priceComparison = analysis['price_comparison_text'];

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
                  title: Text(demandText, style: textTheme.titleMedium),
                  subtitle: Text('متوسط سعر البيع في السوق: $avgPrice دينار'),
                ),
                const SizedBox(height: 16),
                Text(
                  priceComparison,
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
