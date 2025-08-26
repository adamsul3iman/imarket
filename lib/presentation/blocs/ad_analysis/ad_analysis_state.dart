part of 'ad_analysis_bloc.dart';

enum AdAnalysisStatus { initial, loading, loaded, failure }

class AdAnalysisState extends Equatable {
  final AdAnalysisStatus status;
  final MarketAnalysis? analysis;
  final String? errorMessage;

  const AdAnalysisState({
    this.status = AdAnalysisStatus.initial,
    this.analysis,
    this.errorMessage,
  });

  AdAnalysisState copyWith({
    AdAnalysisStatus? status,
    MarketAnalysis? analysis,
    String? errorMessage,
  }) {
    return AdAnalysisState(
      status: status ?? this.status,
      analysis: analysis ?? this.analysis,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, analysis, errorMessage];
}