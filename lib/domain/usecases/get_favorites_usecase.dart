// lib/domain/usecases/get_favorites_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetFavoritesUseCase implements UseCase<Set<String>, NoParams> {
  final AdRepository repository;

  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, Set<String>>> call(NoParams params) { // FIX: Return type updated
    return repository.getFavoriteAdIds();
  }
}