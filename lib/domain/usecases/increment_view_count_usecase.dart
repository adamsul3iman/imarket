import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class IncrementViewCountUseCase implements UseCase<void, String> {
  final AdRepository repository;
  IncrementViewCountUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String adId) {
    // This is often a "fire and forget" call, so we might not need to handle failure explicitly
    // but the pattern requires it.
    return repository.incrementViewCount(adId);
  }
}