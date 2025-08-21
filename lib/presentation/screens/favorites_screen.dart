import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/presentation/blocs/favorites/favorites_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback onNavigateToHome;

  const FavoritesScreen({super.key, required this.onNavigateToHome});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FavoritesBloc>()..add(LoadFavoritesEvent()),
      child: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context, state),
            body: Column(
              children: [
                Expanded(child: _buildContent(context, state)),
                if (state is FavoritesLoaded &&
                    state.isEditMode &&
                    state.selectedAdIds.isNotEmpty)
                  _buildDeleteActionBar(context),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, FavoritesState state) {
    bool showEditButton =
        state is FavoritesLoaded && state.favoriteAds.isNotEmpty;
    bool isEditMode = state is FavoritesLoaded && state.isEditMode;

    return AppBar(
      title: const Text('إعلاناتي المفضلة'),
      actions: [
        if (isEditMode)
          TextButton(
            onPressed: () =>
                context.read<FavoritesBloc>().add(ToggleEditModeEvent()),
            child: const Text('إلغاء'),
          )
        else if (showEditButton)
          TextButton(
            onPressed: () =>
                context.read<FavoritesBloc>().add(ToggleEditModeEvent()),
            child: const Text('تعديل'),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, FavoritesState state) {
    if (state is FavoritesLoading || state is FavoritesInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is FavoritesError) {
      return Center(child: Text('خطأ: ${state.message}'));
    }
    if (state is FavoritesLoaded) {
      if (state.favoriteAds.isEmpty) {
        return _buildEmptyView();
      }
      return RefreshIndicator(
        onRefresh: () async =>
            context.read<FavoritesBloc>().add(LoadFavoritesEvent()),
        child: ListView.builder(
          itemCount: state.favoriteAds.length,
          itemBuilder: (context, index) {
            final ad = state.favoriteAds[index];
            final isSelected = state.selectedAdIds.contains(ad.id);
            return _buildFavoriteListItem(
                context, ad, state.isEditMode, isSelected);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFavoriteListItem(
      BuildContext context, Ad ad, bool isEditMode, bool isSelected) {
    return ListTile(
      title: Text(ad.title),
      trailing: isEditMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => context
                  .read<FavoritesBloc>()
                  .add(SelectFavoriteItemEvent(ad.id)),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        if (isEditMode) {
          context
              .read<FavoritesBloc>()
              .add(SelectFavoriteItemEvent(ad.id));
        } else {
          context.push('/ad-details', extra: ad);
        }
      },
    );
  }

  Widget _buildDeleteActionBar(BuildContext context) {
    final selectedCount =
        (context.read<FavoritesBloc>().state as FavoritesLoaded)
            .selectedAdIds
            .length;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$selectedCount عنصر محدد'),
          ElevatedButton.icon(
            onPressed: () => context
                .read<FavoritesBloc>()
                .add(DeleteSelectedFavoritesEvent()),
            icon: const Icon(Icons.delete_outline),
            label: const Text('حذف المحدد'),
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('قائمة مفضلتك فارغة',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const Text('اضغط على القلب ❤️ لإضافة إعلان هنا',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onNavigateToHome,
            icon: const Icon(Icons.search),
            label: const Text('تصفح الإعلانات'),
          )
        ],
      ),
    );
  }
}
