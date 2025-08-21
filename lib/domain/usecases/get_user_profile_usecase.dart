import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/profile_repository.dart';
import 'package:imarket/presentation/blocs/profile/profile_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetUserProfileUseCase implements UseCase<UserProfile, String> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  // FIX: The return type is now correctly Future<Either<Failure, UserProfile>>
  Future<Either<Failure, UserProfile>> call(String userId) {
    return repository.getUserProfile(userId);
  }
}