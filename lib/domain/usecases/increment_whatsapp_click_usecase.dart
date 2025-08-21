import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class IncrementWhatsappClicksUseCase implements UseCase<void, String> {
  final AdRepository repository;
  IncrementWhatsappClicksUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String adId) {
    return repository.incrementWhatsappClick(adId);
  }
}