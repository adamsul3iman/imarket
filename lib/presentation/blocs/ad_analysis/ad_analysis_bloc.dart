import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/usecases/get_market_analysis_usecase.dart';
import 'package:injectable/injectable.dart';

part 'ad_analysis_event.dart';
part 'ad_analysis_state.dart';

@injectable
class AdAnalysisBloc extends Bloc<AdAnalysisEvent, AdAnalysisState> {
  final GetMarketAnalysisUseCase _getMarketAnalysisUseCase;

  AdAnalysisBloc(this._getMarketAnalysisUseCase) : super(const AdAnalysisState()) {
    on<FetchMarketAnalysis>(_onFetch);
  }

  Future<void> _onFetch(FetchMarketAnalysis event, Emitter<AdAnalysisState> emit) async {
    emit(state.copyWith(status: AdAnalysisStatus.loading));
    final result = await _getMarketAnalysisUseCase.call(event.adId);
    result.fold(
      (failure) => emit(state.copyWith(status: AdAnalysisStatus.failure, errorMessage: failure.message)),
      (analysis) => emit(state.copyWith(status: AdAnalysisStatus.loaded, analysis: analysis)),
    );
  }
}