// lib/domain/usecases/toggle_favorite_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ToggleFavoriteUseCase implements UseCase<void, ToggleFavoriteParams> {
  final AdRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) { // FIX: Return type updated
    final isFavorited = params.currentFavorites.contains(params.adId);
    return repository.toggleFavoriteStatus(params.adId, isFavorited);
  }
}

class ToggleFavoriteParams {
  final String adId;
  final Set<String> currentFavorites;

  ToggleFavoriteParams({required this.adId, required this.currentFavorites});
}