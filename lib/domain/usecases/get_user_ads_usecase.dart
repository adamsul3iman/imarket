// lib/domain/usecases/get_user_ads_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetUserAdsUseCase implements UseCase<List<Ad>, String> {
  final AdRepository repository;
  GetUserAdsUseCase(this.repository);
  @override
  Future<Either<Failure, List<Ad>>> call(String userId) => repository.getUserAds(userId); // FIX: Return type updated
}