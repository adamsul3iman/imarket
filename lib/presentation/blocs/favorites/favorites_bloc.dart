// lib/presentation/blocs/favorites/favorites_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/delete_favorites_usecase.dart';
import 'package:imarket/domain/usecases/get_favorite_ads_usecase.dart';
import 'package:injectable/injectable.dart';

part 'favorites_event.dart'; // FIX: Add part directives
part 'favorites_state.dart'; // FIX: Add part directives

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteAdsUseCase _getFavoriteAdsUseCase;
  final DeleteFavoritesUseCase _deleteFavoritesUseCase;

  FavoritesBloc(this._getFavoriteAdsUseCase, this._deleteFavoritesUseCase) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<SelectFavoriteItemEvent>(_onSelectFavoriteItem);
    on<DeleteSelectedFavoritesEvent>(_onDeleteSelectedFavorites);
  }

  Future<void> _onLoadFavorites(LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await _getFavoriteAdsUseCase.call(NoParams());
    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (ads) => emit(FavoritesLoaded(favoriteAds: ads)),
    );
  }

  void _onToggleEditMode(ToggleEditModeEvent event, Emitter<FavoritesState> emit) {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      emit(currentState.copyWith(isEditMode: !currentState.isEditMode, selectedAdIds: {}));
    }
  }

  void _onSelectFavoriteItem(SelectFavoriteItemEvent event, Emitter<FavoritesState> emit) {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      final newSelectedIds = Set<String>.from(currentState.selectedAdIds);
      if (newSelectedIds.contains(event.adId)) {
        newSelectedIds.remove(event.adId);
      } else {
        newSelectedIds.add(event.adId);
      }
      emit(currentState.copyWith(selectedAdIds: newSelectedIds));
    }
  }

  Future<void> _onDeleteSelectedFavorites(DeleteSelectedFavoritesEvent event, Emitter<FavoritesState> emit) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      if (currentState.selectedAdIds.isEmpty) return;
      
      final result = await _deleteFavoritesUseCase.call(currentState.selectedAdIds);
      result.fold(
        (failure) => emit(FavoritesError(message: failure.message)),
        (_) => add(LoadFavoritesEvent()), // Success: reload the list
      );
    }
  }
}