import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/data/datasources/ad_local_data_source.dart';
import 'package:imarket/data/datasources/ad_remote_data_source.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AdRepository)
class AdRepositoryImpl implements AdRepository {
  final AdRemoteDataSource remoteDataSource;
  final AdLocalDataSource localDataSource; // 1. Add the local data source

  AdRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource, // 2. Inject it via the constructor
  });

  @override
  Future<Either<Failure, List<Ad>>> fetchAds({
    String searchText = '',
    Map<String, dynamic> filters = const {},
    int page = 0,
  }) async {
    // We can add a network connectivity check here in the future
    try {
      // 3. Always try to fetch from the remote source first
      final remoteAds = await remoteDataSource.fetchAds(
        searchText: searchText,
        filters: filters,
        page: page,
      );
      // 4. If successful, cache the new data
      await localDataSource.cacheAds(remoteAds);
      return Right(remoteAds);
    } on Exception {
      // 5. If remote fetching fails (e.g., no internet)...
      try {
        // ...try to get the data from the local cache instead.
        final localAds = await localDataSource.getLastAds();
        return Right(localAds);
      } catch (e) {
        // 6. If both remote and local fail, return a failure.
        return Left(const ServerFailure(message: 'فشل تحميل البيانات. يرجى التحقق من اتصالك بالإنترنت.'));
      }
    }
  }

  // --- Other methods remain unchanged for now ---
  // We can add caching for them later if needed.

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
      return Right(await remoteDataSource.getFavoriteAds());
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
      return Right(await remoteDataSource.getUserAds(userId));
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
  Future<Either<Failure, void>> toggleFavoriteStatus(String adId, bool isCurrentlyFavorited) async {
    try {
      return Right(await remoteDataSource.toggleFavoriteStatus(adId, isCurrentlyFavorited));
    } on Exception {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAdStatus(String adId, String status) async {
    try {
      return Right(await remoteDataSource.updateAdStatus(adId, status));
    } on Exception {
      return Left(const ServerFailure());
    }
  }
}