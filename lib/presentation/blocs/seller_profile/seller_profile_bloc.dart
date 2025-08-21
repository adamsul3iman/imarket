import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';
import 'package:imarket/domain/usecases/get_favorites_usecase.dart';
import 'package:imarket/domain/usecases/get_seller_profile_data_usecase.dart';
import 'package:imarket/domain/usecases/toggle_favorite_usecase.dart';
import 'package:injectable/injectable.dart';

part 'seller_profile_event.dart';
part 'seller_profile_state.dart';

@injectable
class SellerProfileBloc extends Bloc<SellerProfileEvent, SellerProfileState> {
  final GetSellerProfileDataUseCase _getSellerProfileDataUseCase;
  // FIX: Added dependencies for favorite logic
  final GetFavoritesUseCase _getFavoritesUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;

  SellerProfileBloc(
    this._getSellerProfileDataUseCase,
    this._getFavoritesUseCase,
    this._toggleFavoriteUseCase,
  ) : super(SellerProfileInitial()) {
    on<LoadSellerProfileEvent>(_onLoadData);
    on<ToggleFavoriteEvent>(_onToggleFavorite); // FIX: Register new event handler
  }

  Future<void> _onLoadData(LoadSellerProfileEvent event, Emitter<SellerProfileState> emit) async {
    emit(SellerProfileLoading());

    // Fetch profile data and favorite ad IDs in parallel
    final results = await Future.wait([
      _getSellerProfileDataUseCase.call(event.sellerId),
      _getFavoritesUseCase.call(NoParams()),
    ]);

    final profileResult = results[0] as dynamic;
    final favoritesResult = results[1] as dynamic;

    profileResult.fold(
      (failure) => emit(SellerProfileError(message: failure.message)),
      (data) {
        favoritesResult.fold(
          (failure) => emit(SellerProfileError(message: failure.message)),
          (favoriteAdIds) => emit(SellerProfileLoaded(data: data, favoriteAdIds: favoriteAdIds)),
        );
      },
    );
  }

  // FIX: Added handler for the toggle event
  Future<void> _onToggleFavorite(ToggleFavoriteEvent event, Emitter<SellerProfileState> emit) async {
    if (state is SellerProfileLoaded) {
      final currentState = state as SellerProfileLoaded;
      final oldFavorites = currentState.favoriteAdIds;
      final newFavorites = Set<String>.from(oldFavorites);

      if (newFavorites.contains(event.adId)) {
        newFavorites.remove(event.adId);
      } else {
        newFavorites.add(event.adId);
      }
      
      // Optimistic UI update
      emit(SellerProfileLoaded(data: currentState.data, favoriteAdIds: newFavorites));

      // API call
      final result = await _toggleFavoriteUseCase.call(ToggleFavoriteParams(
        adId: event.adId,
        currentFavorites: oldFavorites,
      ));

      // Revert on failure
      result.fold(
        (failure) {
          emit(SellerProfileLoaded(data: currentState.data, favoriteAdIds: oldFavorites));
        },
        (_) {},
      );
    }
  }
}