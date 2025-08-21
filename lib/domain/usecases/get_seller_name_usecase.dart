// lib/domain/usecases/get_seller_name_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetSellerNameUseCase implements UseCase<String, String> {
  final AdRepository repository;

  GetSellerNameUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(String userId) { // FIX: Return type updated
    return repository.getSellerName(userId);
  }
}