import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/home/home_bloc.dart';
import 'package:imarket/presentation/widgets/ad_card.dart';
import 'package:imarket/presentation/widgets/ad_card_shimmer.dart';
import 'package:imarket/presentation/widgets/filter_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const FetchAdsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/logo.png', height: 32),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildSearchAndFilterBar(),
            Expanded(child: _buildContent()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/add-ad'); // Assuming '/add-ad' route exists for AddAdScreen
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Builder(builder: (context) {
      // Use a Builder to get the context that has the HomeBloc
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (query) {
                  // This can be connected to a search event in the BLoC later
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن آيفون...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.filter_list_outlined),
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FilterBottomSheet(initialFilters: const {}), // Pass current filters from state
                );
                if (result != null) {
                  // Dispatch event with new filters
                  context.read<HomeBloc>().add(FetchAdsEvent(filters: result));
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContent() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading || state is HomeInitial) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const AdCardShimmer(),
            ),
          );
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const FetchAdsEvent());
                  },
                  child: const Text('إعادة المحاولة'),
                )
              ],
            ),
          );
        }

        if (state is HomeLoaded) {
          if (state.ads.isEmpty) {
            return const Center(child: Text('لا توجد إعلانات تطابق بحثك.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const FetchAdsEvent());
            },
            child: AnimationLimiter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;
                  int crossAxisCount = 2; // Default for phones
                  if (screenWidth > 800) {
                    crossAxisCount = 4; // Large tablets
                  } else if (screenWidth > 550) {
                    crossAxisCount = 3; // Small tablets / large phones
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: state.ads.length,
                    itemBuilder: (context, index) {
                      final ad = state.ads[index];
                      final isFavorited = state.favoriteAdIds.contains(ad.id);
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: crossAxisCount,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: AdCard(
                              ad: ad,
                              heroTagPrefix: 'home',
                              isFavorited: isFavorited,
                              onFavoriteToggle: () {
                                context.read<HomeBloc>().add(ToggleFavoriteEvent(ad.id));
                              },
                              onTap: () {
                                context.push('/ad-details', extra: ad);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}