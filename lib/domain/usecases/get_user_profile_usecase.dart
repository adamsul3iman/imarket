// lib/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/user_profile.dart'; // ✅ FIX: تم تغيير المسار
import 'package:imarket/domain/repositories/profile_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetUserProfileUseCase implements UseCase<UserProfile, String> {
  final ProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(String userId) {
    return repository.getUserProfile(userId);
  }
}