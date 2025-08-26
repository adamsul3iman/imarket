// lib/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/data/datasources/profile_remote_data_source.dart';
import 'package:imarket/domain/entities/user_profile.dart'; // ✅ FIX: تم تغيير المسار
import 'package:imarket/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final userProfile = await remoteDataSource.getUserProfile(userId);
      return Right(userProfile);
    } on Exception {
      return Left(
          const ServerFailure(message: 'فشل في تحميل بيانات الملف الشخصي.'));
    }
  }
}