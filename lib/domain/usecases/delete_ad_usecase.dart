// lib/domain/usecases/delete_ad_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteAdUseCase implements UseCase<void, String> {
  final AdRepository repository;
  DeleteAdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String adId) { // FIX: Return type updated
    return repository.deleteAd(adId);
  }
}