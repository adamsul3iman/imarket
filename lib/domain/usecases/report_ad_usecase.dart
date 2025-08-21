import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ReportAdUseCase implements UseCase<void, ReportAdParams> {
  final AdRepository repository;
  ReportAdUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ReportAdParams params) {
    return repository.reportAd(params);
  }
}

class ReportAdParams extends Equatable {
  final String adId;
  final String userId;
  final String reason;
  final String comments;

  const ReportAdParams({
    required this.adId,
    required this.userId,
    required this.reason,
    required this.comments,
  });

  @override
  List<Object?> get props => [adId, userId, reason, comments];
}