// lib/domain/usecases/delete_favorites_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeleteFavoritesUseCase implements UseCase<void, Set<String>> {
  final AdRepository repository;
  DeleteFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Set<String> adIds) { // FIX: Return type updated
    return repository.deleteFavorites(adIds);
  }
}