import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/data/datasources/seller_profile_remote_data_source.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';
import 'package:imarket/domain/repositories/seller_profile_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SellerProfileRepository)
class SellerProfileRepositoryImpl implements SellerProfileRepository {
  final SellerProfileRemoteDataSource remoteDataSource;

  SellerProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SellerProfileData>> getSellerProfileData(String sellerId) async {
    try {
      final data = await remoteDataSource.getSellerProfileData(sellerId);
      return Right(data);
    } on Exception {
      return Left(const ServerFailure());
    }
  }
}