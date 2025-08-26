import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/delete_ad_usecase.dart';
import 'package:imarket/domain/usecases/get_user_ads_usecase.dart';
import 'package:imarket/domain/usecases/update_ad_status_usecase.dart';
// You will need to create these UseCases and their repository methods
// import 'package:imarket/domain/usecases/get_subscription_status_usecase.dart';
// import 'package:imarket/domain/usecases/get_top_demand_model_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// FIX: Removed unused imports for dartz and failures

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SupabaseClient _supabaseClient;
  final GetUserAdsUseCase _getUserAdsUseCase;
  final UpdateAdStatusUseCase _updateAdStatusUseCase;
  final DeleteAdUseCase _deleteAdUseCase;
  // Inject the new UseCases here
  // final GetSubscriptionStatusUseCase _getSubscriptionStatusUseCase;
  // final GetTopDemandModelUseCase _getTopDemandModelUseCase;

  DashboardBloc(
    this._supabaseClient,
    this._getUserAdsUseCase,
    this._updateAdStatusUseCase,
    this._deleteAdUseCase,
    // Add the new UseCases to the constructor
  ) : super(DashboardInitial()) {
    on<LoadDashboardDataEvent>(_onLoadData);
    on<MarkAdAsSoldEvent>(_onMarkAsSold);
    on<DeleteAdEvent>(_onDeleteAd);
  }

  Future<void> _onLoadData(
      LoadDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      emit(DashboardLoggedOut());
      return;
    }

    // Fetch all required data in parallel
    final results = await Future.wait([
      _getUserAdsUseCase.call(user.id),
      // _getSubscriptionStatusUseCase.call(NoParams()),
      // _getTopDemandModelUseCase.call(NoParams()),
    ]);

    final adsResult = results[0] as dynamic;

    adsResult.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (ads) {
        // Here, you would check the results of the other calls as well
        emit(DashboardLoaded(
          userAds: ads,
          hasSubscription: false, // Replace with actual data from subResult
          topDemandModel: 'N/A', // Replace with actual data from topModelResult
        ));
      },
    );
  }

  Future<void> _onMarkAsSold(
      MarkAdAsSoldEvent event, Emitter<DashboardState> emit) async {
    // FIX: Use .fold for error handling instead of try/catch
    final result = await _updateAdStatusUseCase.call(
      UpdateAdStatusParams(adId: event.adId, status: 'sold'),
    );

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (_) {
        emit(const DashboardActionSuccess(
            message: 'تم تمييز الإعلان كمباع بنجاح!'));
        add(LoadDashboardDataEvent());
      },
    );
  }

  Future<void> _onDeleteAd(
      DeleteAdEvent event, Emitter<DashboardState> emit) async {
    // FIX: Use .fold for error handling instead of try/catch
    final result = await _deleteAdUseCase.call(event.adId);

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (_) {
        emit(const DashboardActionSuccess(message: 'تم حذف الإعلان بنجاح!'));
        add(LoadDashboardDataEvent());
      },
    );
  }
}
