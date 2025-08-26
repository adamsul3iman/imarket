import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/core/usecase/usecase.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:injectable/injectable.dart';

/// An entity class to hold the structured data returned from the market analysis.
class MarketAnalysis extends Equatable {
  final int averagePrice;
  final String demandText;
  final String priceComparisonText;

  const MarketAnalysis({
    required this.averagePrice,
    required this.demandText,
    required this.priceComparisonText,
  });

  /// A factory constructor to create a [MarketAnalysis] instance from a map.
  factory MarketAnalysis.fromMap(Map<String, dynamic> map) {
    return MarketAnalysis(
      averagePrice: (map['average_price'] as num?)?.toInt() ?? 0,
      demandText: map['demand_text'] as String? ?? 'N/A',
      priceComparisonText: map['price_comparison_text'] as String? ?? 'N/A',
    );
  }

  @override
  List<Object?> get props => [averagePrice, demandText, priceComparisonText];
}

/// A use case responsible for fetching the market analysis for a specific ad.
@lazySingleton
class GetMarketAnalysisUseCase implements UseCase<MarketAnalysis, String> {
  final AdRepository repository;

  GetMarketAnalysisUseCase(this.repository);

  /// Executes the use case.
  ///
  /// Takes an ad ID as a parameter and returns either a [Failure] or a [MarketAnalysis] object.
  @override
  Future<Either<Failure, MarketAnalysis>> call(String adId) {
    return repository.getMarketAnalysis(adId);
  }
}
