// lib/presentation/blocs/dashboard/dashboard_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/delete_ad_usecase.dart';
import 'package:imarket/domain/usecases/get_user_ads_usecase.dart';
import 'package:imarket/domain/usecases/update_ad_status_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SupabaseClient _supabaseClient;
  final GetUserAdsUseCase _getUserAdsUseCase;
  final UpdateAdStatusUseCase _updateAdStatusUseCase;
  final DeleteAdUseCase _deleteAdUseCase;

  DashboardBloc(
    this._supabaseClient,
    this._getUserAdsUseCase,
    this._updateAdStatusUseCase,
    this._deleteAdUseCase,
  ) : super(DashboardInitial()) {
    on<LoadDashboardDataEvent>(_onLoadData);
    on<MarkAdAsSoldEvent>(_onMarkAsSold);
    on<DeleteAdEvent>(_onDeleteAd);
  }

  Future<void> _onLoadData(LoadDashboardDataEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      emit(DashboardLoggedOut());
      return;
    }

    // For simplicity, we'll fetch user ads first.
    // We can combine them with Future.wait and Either later if needed.
    final adsResult = await _getUserAdsUseCase.call(user.id);
    
    adsResult.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (ads) {
        // Here you would also fetch subscription and top demand model
        emit(DashboardLoaded(
          userAds: ads,
          hasSubscription: false, // Placeholder
          topDemandModel: 'N/A', // Placeholder
        ));
      },
    );
  }

  Future<void> _onMarkAsSold(MarkAdAsSoldEvent event, Emitter<DashboardState> emit) async {
    // FIX: Use .fold for error handling instead of try/catch
    final result = await _updateAdStatusUseCase.call(
      UpdateAdStatusParams(adId: event.adId, status: 'sold'),
    );

    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (_) {
        emit(const DashboardActionSuccess(message: 'تم تمييز الإعلان كمباع بنجاح!'));
        add(LoadDashboardDataEvent());
      },
    );
  }

  Future<void> _onDeleteAd(DeleteAdEvent event, Emitter<DashboardState> emit) async {
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