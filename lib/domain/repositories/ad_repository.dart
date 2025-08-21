// lib/domain/repositories/ad_repository.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';

abstract class AdRepository {
  // FIX: Made parameters non-nullable with default values for consistency.
  Future<Either<Failure, List<Ad>>> fetchAds({
    String searchText = '',
    Map<String, dynamic> filters = const {},
    int page = 0,
  });

  Future<Either<Failure, Set<String>>> getFavoriteAdIds();

  Future<Either<Failure, void>> toggleFavoriteStatus(String adId, bool isCurrentlyFavorited);

  Future<Either<Failure, String>> getSellerName(String userId);

  Future<Either<Failure, List<Ad>>> getUserAds(String userId);

  Future<Either<Failure, void>> updateAdStatus(String adId, String status);

  Future<Either<Failure, void>> deleteAd(String adId);

  Future<Either<Failure, List<Ad>>> getFavoriteAds();

  Future<Either<Failure, void>> deleteFavorites(Set<String> adIds);
   Future<Either<Failure, void>> incrementViewCount(String adId);
  Future<Either<Failure, void>> reportAd(ReportAdParams params);
  Future<Either<Failure, void>> incrementWhatsappClick(String adId);
  Future<Either<Failure, void>> incrementCallClick(String adId);
}