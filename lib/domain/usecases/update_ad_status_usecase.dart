// lib/domain/usecases/update_ad_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateAdStatusUseCase implements UseCase<void, UpdateAdStatusParams> {
  final AdRepository repository;
  UpdateAdStatusUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(UpdateAdStatusParams params) => // FIX: Return type updated
      repository.updateAdStatus(params.adId, params.status);
}

class UpdateAdStatusParams {
  final String adId;
  final String status;
  UpdateAdStatusParams({required this.adId, required this.status});
}