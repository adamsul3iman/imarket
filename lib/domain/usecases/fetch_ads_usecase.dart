// lib/domain/usecases/fetch_ads_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FetchAdsUseCase implements UseCase<List<Ad>, FetchAdsParams> {
  final AdRepository repository;

  FetchAdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(FetchAdsParams params) async { // FIX: Return type updated
    return await repository.fetchAds(
      searchText: params.searchText,
      filters: params.filters,
      page: params.page,
    );
  }
}

class FetchAdsParams {
  final String searchText;
  final Map<String, dynamic> filters;
  final int page;

  FetchAdsParams({
    required this.searchText,
    required this.filters,
    required this.page,
  });
}