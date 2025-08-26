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
    // We only show the full-page loading shimmer on the initial fetch
    if (state is! HomeLoaded) {
      emit(HomeLoading());
    }

    // FIX: Use the searchText and filters from the event when calling the UseCase
    final adsResult = await _fetchAdsUseCase.call(FetchAdsParams(
      searchText: event.searchText,
      filters: event.filters,
      page: event.page,
    ));

    List<Ad> ads = [];
    adsResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (successAds) => ads = successAds,
    );
    if (adsResult.isLeft()) return;

    final favoritesResult = await _getFavoritesUseCase.call(NoParams());

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
        (_) {},
      );
    }
  }
}