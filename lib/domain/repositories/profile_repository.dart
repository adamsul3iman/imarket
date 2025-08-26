// lib/domain/repositories/profile_repository.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/entities/user_profile.dart'; // ✅ FIX: تم تغيير المسار

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);
}