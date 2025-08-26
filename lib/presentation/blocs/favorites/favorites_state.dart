// lib/presentation/blocs/favorites/favorites_state.dart
part of 'favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}
class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Ad> favoriteAds;
  final bool isEditMode;
  final Set<String> selectedAdIds;

  const FavoritesLoaded({
    required this.favoriteAds,
    this.isEditMode = false,
    this.selectedAdIds = const {},
  });

  FavoritesLoaded copyWith({
    List<Ad>? favoriteAds,
    bool? isEditMode,
    Set<String>? selectedAdIds,
  }) {
    return FavoritesLoaded(
      favoriteAds: favoriteAds ?? this.favoriteAds,
      isEditMode: isEditMode ?? this.isEditMode,
      selectedAdIds: selectedAdIds ?? this.selectedAdIds,
    );
  }

  @override
  List<Object> get props => [favoriteAds, isEditMode, selectedAdIds];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError({required this.message});
}

class FavoritesActionSuccess extends FavoritesState {}