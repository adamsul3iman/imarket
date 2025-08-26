import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> resetPasswordForEmail(String email);

  Future<Either<Failure, User>> signUp({
    required String fullName,
    required String email,
    required String password,
  });
}
