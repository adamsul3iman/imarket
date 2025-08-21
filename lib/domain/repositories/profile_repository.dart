import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/presentation/blocs/profile/profile_bloc.dart';

abstract class ProfileRepository {
  // FIX: Updated the return type to match our error handling pattern
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
}