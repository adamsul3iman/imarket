// lib/presentation/blocs/favorites/favorites_event.dart
part of 'favorites_bloc.dart'; // FIX: Add part of directive

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {}
class ToggleEditModeEvent extends FavoritesEvent {}
class SelectFavoriteItemEvent extends FavoritesEvent {
  final String adId;
  const SelectFavoriteItemEvent(this.adId);
}
class DeleteSelectedFavoritesEvent extends FavoritesEvent {}