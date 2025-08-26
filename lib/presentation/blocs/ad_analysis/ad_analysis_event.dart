part of 'ad_analysis_bloc.dart';

abstract class AdAnalysisEvent extends Equatable {
  const AdAnalysisEvent();

  @override
  List<Object> get props => [];
}

class FetchMarketAnalysis extends AdAnalysisEvent {
  final String adId;
  const FetchMarketAnalysis(this.adId);
}