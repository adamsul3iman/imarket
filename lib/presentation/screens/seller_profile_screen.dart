import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';
import 'package:imarket/presentation/blocs/seller_profile/seller_profile_bloc.dart';
import 'package:imarket/presentation/widgets/ad_card.dart';
import 'package:intl/intl.dart';

class SellerProfileScreen extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const SellerProfileScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SellerProfileBloc>()..add(LoadSellerProfileEvent(sellerId: sellerId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(sellerName),
          // Actions like 'block user' can be converted to BLoC events later
        ),
        body: BlocBuilder<SellerProfileBloc, SellerProfileState>(
          builder: (context, state) {
            if (state is SellerProfileLoading || state is SellerProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SellerProfileError) {
              return Center(child: Text('حدث خطأ: ${state.message}'));
            }
            if (state is SellerProfileLoaded) {
              final sellerData = state.data;
              return DefaultTabController(
                length: 2,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildProfileHeader(context, sellerName, sellerData.averageRating, sellerData.reviews.length),
                      ),
                      const SliverPersistentHeader(
                        delegate: _TabBarDelegate(
                          tabBar: TabBar(
                            tabs: [
                              Tab(icon: Icon(Icons.grid_view_outlined), text: 'الإعلانات'),
                              Tab(icon: Icon(Icons.reviews_outlined), text: 'المراجعات'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      _buildAdsTab(context, sellerData.ads, state.favoriteAdIds),
                      _buildReviewsTab(sellerData.reviews),
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

  Widget _buildProfileHeader(BuildContext context, String name, double rating, int reviewCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge, overflow: TextOverflow.ellipsis, maxLines: 1),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${rating.toStringAsFixed(1)} (${reviewCount.toString()} مراجعة)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsTab(BuildContext context, List<Ad> ads, Set<String> favoriteAdIds) {
    if (ads.isEmpty) {
      return const Center(child: Text('هذا البائع ليس لديه إعلانات حاليًا.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.65,
      ),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final adData = ads[index];
        return AdCard(
          ad: adData,
          heroTagPrefix: 'seller-$sellerId',
          isFavorited: favoriteAdIds.contains(adData.id),
          onFavoriteToggle: () {
            // Dispatch the event to the BLoC to handle the logic
            context.read<SellerProfileBloc>().add(ToggleFavoriteEvent(adId: adData.id));
          },
          onTap: () {
            // Navigate using GoRouter, passing the ad object
            context.push('/ad-details', extra: adData);
          },
        );
      },
    );
  }

  Widget _buildReviewsTab(List<ReviewEntity> reviews) {
    if (reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد مراجعات لهذا البائع بعد.'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      child: Text(review.reviewerName.isNotEmpty
                          ? review.reviewerName[0].toUpperCase()
                          : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            DateFormat.yMMMd('ar').format(review.createdAt),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 18,
                        );
                      }),
                    ),
                  ],
                ),
                if (review.comment.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(review.comment, style: const TextStyle(height: 1.4)),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate({required this.tabBar});
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}