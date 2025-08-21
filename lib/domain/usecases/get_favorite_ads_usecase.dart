// lib/domain/usecases/get_favorite_ads_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetFavoriteAdsUseCase implements UseCase<List<Ad>, NoParams> {
  final AdRepository repository;
  GetFavoriteAdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(NoParams params) { // FIX: Return type updated
    return repository.getFavoriteAds();
  }
}