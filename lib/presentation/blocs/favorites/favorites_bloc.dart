// lib/presentation/blocs/favorites/favorites_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/get_favorite_ads_usecase.dart';
import 'package:imarket/domain/usecases/toggle_favorite_usecase.dart';
import 'package:injectable/injectable.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteAdsUseCase _getFavoriteAdsUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  FavoritesBloc(
    this._getFavoriteAdsUseCase,
    this._toggleFavoriteUseCase,
  ) : super(FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
      LoadFavoritesEvent event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    final result = await _getFavoriteAdsUseCase.call(NoParams());
    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      // ✅ FIX: Changed 'ads:' to the correct name 'favoriteAds:'
      (ads) => emit(FavoritesLoaded(favoriteAds: ads)),
    );
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent event, Emitter<FavoritesState> emit) async {
    // A robust implementation would get the current full list of favorites first
    final result = await _toggleFavoriteUseCase.call(ToggleFavoriteParams(
      adId: event.adId,
      currentFavorites: {event.adId}, // Assumes we are removing it
    ));

    result.fold(
      (failure) => emit(FavoritesError(message: failure.message)),
      (_) => add(LoadFavoritesEvent()), // On success, just reload the list
    );
  }
}