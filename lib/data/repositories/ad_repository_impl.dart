import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/data/datasources/ad_local_data_source.dart';
import 'package:imarket/data/datasources/ad_remote_data_source.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:imarket/domain/usecases/get_market_analysis_usecase.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:imarket/domain/usecases/submit_ad_usecase.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AdRepository)
class AdRepositoryImpl implements AdRepository {
  final AdRemoteDataSource remoteDataSource;
  final AdLocalDataSource localDataSource;

  AdRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Ad>>> fetchAds({
    String searchText = '',
    Map<String, dynamic> filters = const {},
    int page = 0,
  }) async {
    try {
      final rawAds = await remoteDataSource.fetchAds(
        searchText: searchText,
        filters: filters,
        page: page,
      );
      final remoteAds = rawAds.map((json) => Ad.fromMap(json)).toList();
      await localDataSource.cacheAds(remoteAds);
      return Right(remoteAds);
    } on Exception {
      try {
        final localAds = await localDataSource.getLastAds();
        return Right(localAds);
      } catch (e) {
        return Left(const ServerFailure(
            message: 'فشل تحميل البيانات. يرجى التحقق من اتصالك بالإنترنت.'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Ad>>> fetchAdsByModel(String model) async {
    try {
      final rawAds = await remoteDataSource.fetchAdsByModel(model);
      final adModels = rawAds.map((json) => Ad.fromMap(json)).toList();
      return Right(adModels);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getSellerName(String userId) async {
    try {
      final name = await remoteDataSource.getSellerName(userId);
      return Right(name);
    } on Exception {
      return Left(const ServerFailure(message: 'Could not fetch seller name.'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteAd(String adId) async {
    try {
      return Right(await remoteDataSource.deleteAd(adId));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFavorites(Set<String> adIds) async {
    try {
      return Right(await remoteDataSource.deleteFavorites(adIds));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Ad>>> getFavoriteAds() async {
    try {
      final rawAds = await remoteDataSource.getFavoriteAds();
      final adModels = rawAds.map((json) => Ad.fromMap(json)).toList();
      return Right(adModels);
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Set<String>>> getFavoriteAdIds() async {
    try {
      return Right(await remoteDataSource.getFavoriteAdIds());
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Ad>>> getUserAds(String userId) async {
    try {
      final rawAds = await remoteDataSource.getUserAds(userId);
      final adModels = rawAds.map((json) => Ad.fromMap(json)).toList();
      return Right(adModels);
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> incrementCallClick(String adId) async {
    try {
      return Right(await remoteDataSource.incrementCallClick(adId));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> incrementViewCount(String adId) async {
    try {
      return Right(await remoteDataSource.incrementViewCount(adId));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> incrementWhatsappClick(String adId) async {
    try {
      return Right(await remoteDataSource.incrementWhatsappClick(adId));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> reportAd(ReportAdParams params) async {
    try {
      return Right(await remoteDataSource.reportAd(params));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavoriteStatus(
      String adId, bool isCurrentlyFavorited) async {
    try {
      return Right(await remoteDataSource.toggleFavoriteStatus(
          adId, isCurrentlyFavorited));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAdStatus(
      String adId, String status) async {
    try {
      return Right(await remoteDataSource.updateAdStatus(adId, status));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> submitAd(SubmitAdParams params) async {
    try {
      await remoteDataSource.submitAd(params);
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MarketAnalysis>> getMarketAnalysis(String adId) async {
    try {
      final result = await remoteDataSource.getMarketAnalysis(adId);
      return Right(MarketAnalysis.fromMap(result));
    } on Exception {
      return Left(const ServerFailure(message: 'Failed to get market analysis.'));
    }
  }
}