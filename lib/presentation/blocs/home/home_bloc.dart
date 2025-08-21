import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/fetch_ads_usecase.dart';
import 'package:imarket/domain/usecases/get_favorites_usecase.dart';
import 'package:imarket/domain/usecases/toggle_favorite_usecase.dart';
import 'package:injectable/injectable.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchAdsUseCase _fetchAdsUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  HomeBloc(
    this._fetchAdsUseCase,
    this._getFavoritesUseCase,
    this._toggleFavoriteUseCase,
  ) : super(HomeInitial()) {
    on<FetchAdsEvent>(_onFetchAds);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onFetchAds(FetchAdsEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    // --- FIX: A cleaner, safer way to handle multiple async calls ---

    // 1. Await the first call
    final adsResult = await _fetchAdsUseCase.call(FetchAdsParams(
      searchText: event.searchText,
      filters: event.filters,
      page: event.page,
    ));

    // 2. Handle the result. If it's a failure, emit Error and stop.
    // This is called a "guard clause" or "early exit".
    List<Ad> ads = [];
    adsResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (successAds) => ads = successAds,
    );
    if (adsResult.isLeft()) return; // Stop if there was an error

    // 3. If the first call succeeded, await the second call
    final favoritesResult = await _getFavoritesUseCase.call(NoParams());

    // 4. Handle the second result.
    favoritesResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (favoriteAdIds) => emit(HomeLoaded(ads: ads, favoriteAdIds: favoriteAdIds)),
    );
  }

  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final Set<String> oldFavorites = currentState.favoriteAdIds;
      final newFavorites = Set<String>.from(oldFavorites);

      if (newFavorites.contains(event.adId)) {
        newFavorites.remove(event.adId);
      } else {
        newFavorites.add(event.adId);
      }
      
      emit(HomeLoaded(ads: currentState.ads, favoriteAdIds: newFavorites));

      final result = await _toggleFavoriteUseCase.call(ToggleFavoriteParams(
        adId: event.adId,
        currentFavorites: oldFavorites,
      ));

      result.fold(
        (failure) {
          emit(HomeLoaded(ads: currentState.ads, favoriteAdIds: oldFavorites));
        },
        (_) => null,
      );
    }
  }
}