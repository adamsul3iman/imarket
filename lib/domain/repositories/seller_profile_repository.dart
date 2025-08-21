import 'package:dartz/dartz.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';

abstract class SellerProfileRepository {
  Future<Either<Failure, SellerProfileData>> getSellerProfileData(String sellerId);
}