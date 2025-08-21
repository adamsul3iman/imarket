// lib/presentation/screens/ad_details_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/blocs/ad_details/ad_details_bloc.dart';
import 'package:imarket/presentation/screens/full_screen_image_viewer.dart';
import 'package:imarket/presentation/widgets/report_dialog.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailsScreen extends StatefulWidget {
  final Ad ad;
  final String heroTagPrefix;

  const AdDetailsScreen({
    super.key,
    required this.ad,
    required this.heroTagPrefix,
  });

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends State<AdDetailsScreen> {
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar');
  }

  Future<void> _shareAd(BuildContext context) async {
    final adLink = "https://your-app-website.com/ad/${widget.ad.id}";
    final shareText = '''
شاهد هذا الإعلان على iMarket JO!

${widget.ad.title}
السعر: ${widget.ad.price} دينار

شاهد المزيد هنا: $adLink
''';
    final box = context.findRenderObject() as RenderBox?;

    if (box != null) {
      Share.share(
        shareText,
        subject: widget.ad.title,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  Future<void> _launchUrlHelper(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن فتح الرابط: $url')),
        );
      }
    }
  }

  void _showReportDialog(BuildContext context, AdDetailsBloc bloc) {
    showDialog(
      context: context,
      builder: (_) => ReportDialog(
        onSubmit: (reason, comments) {
          bloc.add(ReportAdEvent(reason: reason, comments: comments));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => getIt<AdDetailsBloc>()
        ..add(LoadAdDetailsEvent(adId: widget.ad.id, userId: widget.ad.userId)),
      child: BlocListener<AdDetailsBloc, AdDetailsState>(
        listener: (context, state) {
          if (state is AdDetailsActionSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ));
          } else if (state is AdDetailsActionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ));
          } else if (state is AdDetailsLaunchUrl) {
            _launchUrlHelper(state.url);
          }
        },
        child: Scaffold(
          bottomNavigationBar: _buildContactBar(context, widget.ad),
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBarWithCarousel(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(textTheme, colorScheme),
                      const SizedBox(height: 8),
                      _buildTimestampAndLocation(textTheme),
                      const Divider(height: 32),
                      _buildSectionTitle('معلومات البائع', textTheme),
                      _buildSellerInfoCard(),
                      const Divider(height: 32),
                      _buildSectionTitle('المواصفات', textTheme),
                      _buildSpecsGrid(),
                      const Divider(height: 32),
                      if (widget.ad.description != null &&
                          widget.ad.description!.isNotEmpty) ...[
                        _buildSectionTitle('الوصف', textTheme),
                        Text(widget.ad.description!,
                            style: textTheme.bodyLarge?.copyWith(height: 1.5)),
                        const Divider(height: 32),
                      ],
                      _buildSectionTitle('الملحقات المرفقة', textTheme),
                      _buildAccessoryItem('العلبة الأصلية', widget.ad.hasBox ?? false),
                      _buildAccessoryItem('الشاحن الأصلي', widget.ad.hasCharger ?? false),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBarWithCarousel(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white),
          onPressed: () => _shareAd(context),
          tooltip: 'مشاركة الإعلان',
        ),
        BlocBuilder<AdDetailsBloc, AdDetailsState>(
          builder: (context, state) {
            final bloc = context.read<AdDetailsBloc>();
            if (state is AdDetailsLoaded && state.isOwnAd) {
              return const SizedBox.shrink();
            }
            return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog(context, bloc);
                }
              },
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'report',
                  child: ListTile(
                    leading: Icon(Icons.flag_outlined, color: Colors.red),
                    title: Text('الإبلاغ عن هذا الإعلان', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: const Color.fromARGB(128, 0, 0, 0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageViewer(
                  imageUrls: widget.ad.imageUrls,
                  initialIndex: _currentPageIndex,
                ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                itemCount: widget.ad.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _currentPageIndex = index);
                },
                itemBuilder: (context, index) {
                  final imageUrl = widget.ad.imageUrls[index];
                  // Assuming hero tags are unique from where you navigate
                  return Hero(
                    tag: '${widget.heroTagPrefix}-$imageUrl',
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, u) => Container(color: Colors.grey.shade200),
                      errorWidget: (context, u, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
              if (widget.ad.imageUrls.length > 1)
                Positioned(
                  bottom: 16.0,
                  left: 0,
                  right: 0,
                  child: _buildPageIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.ad.imageUrls.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPageIndex == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: _currentPageIndex == index
                ? Colors.white
                : Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildContactBar(BuildContext context, Ad ad) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AdDetailsBloc>().add(LaunchCallEvent(phoneNumber: ad.phoneNumber ?? ''));
                },
                icon: const Icon(Icons.phone_outlined),
                label: const Text('اتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AdDetailsBloc>().add(LaunchWhatsappEvent(
                    phoneNumber: ad.phoneNumber ?? '',
                    adTitle: ad.title,
                  ));
                },
                icon: const Icon(Icons.wechat_outlined),
                label: const Text('واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.ad.title,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Chip(
          label: Text(
            '${widget.ad.price} دينار',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        )
      ],
    );
  }

  Widget _buildTimestampAndLocation(TextTheme textTheme) {
    return Text(
      'تم النشر في: ${DateFormat.yMMMd('ar').format(widget.ad.createdAt)} - ${widget.ad.city ?? 'غير محدد'}',
      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSellerInfoCard() {
    return BlocBuilder<AdDetailsBloc, AdDetailsState>(
      builder: (context, state) {
        if (state is AdDetailsLoaded) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(state.sellerName),
              subtitle: const Text('عضو في iMarket'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to seller profile screen
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSpecsGrid() {
    final specs = {
      if (widget.ad.conditionAr != null)
        'الحالة': {'icon': Icons.bookmark_border, 'value': widget.ad.conditionAr},
      'السعة': {'icon': Icons.storage_outlined, 'value': '${widget.ad.storage} GB'},
      if (widget.ad.colorAr != null)
        'اللون': {'icon': Icons.color_lens_outlined, 'value': widget.ad.colorAr},
      if (widget.ad.batteryHealth != null)
        'البطارية': {'icon': Icons.battery_charging_full, 'value': '${widget.ad.batteryHealth}%'},
    };
    specs.removeWhere((key, value) => value['value'] == null);

    return GridView.builder(
      itemCount: specs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final key = specs.keys.elementAt(index);
        final data = specs[key]!;
        return _buildSpecItem(
          data['icon'] as IconData,
          key,
          data['value'] as String? ?? 'N/A',
        );
      },
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAccessoryItem(String title, bool isAvailable) {
    return ListTile(
      leading: Icon(
        isAvailable ? Icons.check_box_outlined : Icons.check_box_outline_blank,
        color: isAvailable ? Colors.green : Colors.grey,
      ),
      title: Text(title),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}