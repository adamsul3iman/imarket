import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:imarket/presentation/widgets/ad_card.dart';

/// A screen to display the user's favorite ads.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FavoritesBloc>()..add(LoadFavoritesEvent()),
      child: Scaffold(
        appBar: AppBar(
          // ✅ FIX: Translated title
          title: const Text('إعلاناتي المفضلة'),
          centerTitle: true,
        ),
        body: BlocConsumer<FavoritesBloc, FavoritesState>(
          listenWhen: (previous, current) => current is FavoritesActionSuccess,
          listener: (context, state) {
            context.read<FavoritesBloc>().add(LoadFavoritesEvent());
          },
          builder: (context, state) {
            if (state is FavoritesLoading || state is FavoritesInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FavoritesError) {
              // ✅ FIX: Translated error message
              return Center(child: Text('حدث خطأ: ${state.message}'));
            }
            if (state is FavoritesLoaded) {
              if (state.favoriteAds.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      // ✅ FIX: Translated empty state text
                      Text(
                        'لا توجد إعلانات مفضلة لديك بعد.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط على أيقونة القلب في الإعلانات لإضافتها هنا.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.65,
                ),
                itemCount: state.favoriteAds.length,
                itemBuilder: (context, index) {
                  final ad = state.favoriteAds[index];
                  return AdCard(
                    ad: ad,
                    heroTagPrefix: 'favorite',
                    isFavorited: true,
                    onFavoriteToggle: () {
                      context
                          .read<FavoritesBloc>()
                          .add(ToggleFavoriteEvent(adId: ad.id));
                    },
                    onTap: () {
                      context.push('/ad-details', extra: ad);
                    },
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
