import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<User> signInWithPassword({
    required String email,
    required String password,
  });
  Future<void> resetPasswordForEmail(String email);

  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSourceImpl(this._supabase);

  @override
  Future<User> signInWithPassword(
      {required String email, required String password}) async {
    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (authResponse.user == null) {
        throw const AuthException('User not found');
      }
      return authResponse.user!;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  // FIX: Added missing @override annotation
  @override
  Future<User> signUp(
      {required String fullName,
      required String email,
      required String password}) async {
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName.trim()},
      );
      if (authResponse.user == null) {
        throw const AuthException('Sign up failed.');
      }
      return authResponse.user!;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }
}