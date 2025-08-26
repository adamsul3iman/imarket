import 'dart:async';
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

/// الشاشة الرئيسية التي تعرض شبكة الإعلانات وأدوات البحث والفلترة.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const FetchAdsEvent()),
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatefulWidget {
  const _HomeScreenView();

  @override
  State<_HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<_HomeScreenView> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<HomeBloc>().add(FetchAdsEvent(
            searchText: _searchController.text,
            filters: _activeFilters,
          ));
    });
  }

  void _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(initialFilters: _activeFilters),
    );
    if (result != null) {
      setState(() {
        _activeFilters = result;
      });
      // Dispatch event with new filters
      context.read<HomeBloc>().add(FetchAdsEvent(
            searchText: _searchController.text,
            filters: _activeFilters,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // You need to create a route for '/add-ad' in GoRouter
          context.push('/add-ad');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن آيفون...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _openFilterSheet,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(color: Colors.grey.shade300),
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
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
                    context.read<HomeBloc>().add(FetchAdsEvent(
                          searchText: _searchController.text,
                          filters: _activeFilters,
                        ));
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
              context.read<HomeBloc>().add(FetchAdsEvent(
                    searchText: _searchController.text,
                    filters: _activeFilters,
                  ));
            },
            child: AnimationLimiter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double screenWidth = constraints.maxWidth;
                  int crossAxisCount = 2;
                  if (screenWidth > 800) {
                    crossAxisCount = 4;
                  } else if (screenWidth > 550) {
                    crossAxisCount = 3;
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
                                context
                                    .read<HomeBloc>()
                                    .add(ToggleFavoriteEvent(ad.id));
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
