import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/data/datasources/profile_remote_data_source.dart';
import 'package:imarket/domain/repositories/profile_repository.dart';
import 'package:imarket/presentation/blocs/profile/profile_bloc.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  // FIX: The implementation now correctly returns Future<Either<...>>
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final userProfile = await remoteDataSource.getUserProfile(userId);
      return Right(userProfile);
    } on Exception catch (e) {
      // You can add more specific exception handling here later
      return Left(ServerFailure(message: e.toString()));
    }
  }
}