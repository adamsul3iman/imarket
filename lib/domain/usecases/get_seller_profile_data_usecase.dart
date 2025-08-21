import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';
import 'package:imarket/domain/repositories/seller_profile_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetSellerProfileDataUseCase implements UseCase<SellerProfileData, String> {
  final SellerProfileRepository repository;

  GetSellerProfileDataUseCase(this.repository);

  @override
  Future<Either<Failure, SellerProfileData>> call(String sellerId) {
    return repository.getSellerProfileData(sellerId);
  }
}