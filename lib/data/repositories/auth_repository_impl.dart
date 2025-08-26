import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/data/datasources/auth_remote_data_source.dart';
import 'package:imarket/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> signInWithPassword(
      {required String email, required String password}) async {
    try {
      final user = await remoteDataSource.signInWithPassword(
          email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPasswordForEmail(String email) async {
    try {
      await remoteDataSource.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
          fullName: fullName, email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(const ServerFailure());
    }
  }
}
