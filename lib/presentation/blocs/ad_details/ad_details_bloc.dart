import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/usecases/get_seller_name_usecase.dart';
import 'package:imarket/domain/usecases/increment_call_click_usecase.dart';
import 'package:imarket/domain/usecases/increment_view_count_usecase.dart';
import 'package:imarket/domain/usecases/increment_whatsapp_click_usecase.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'ad_details_event.dart';
part 'ad_details_state.dart';

@injectable
class AdDetailsBloc extends Bloc<AdDetailsEvent, AdDetailsState> {
  final GetSellerNameUseCase _getSellerNameUseCase;
  final IncrementViewCountUseCase _incrementViewCountUseCase;
  final IncrementWhatsappClicksUseCase _incrementWhatsappClicksUseCase;
  final IncrementCallClicksUseCase _incrementCallClicksUseCase;
  final ReportAdUseCase _reportAdUseCase;
  final SupabaseClient _supabaseClient;

  String _currentAdId = '';
  String _currentAdUserId = '';

  AdDetailsBloc(
    this._getSellerNameUseCase,
    this._incrementViewCountUseCase,
    this._incrementWhatsappClicksUseCase,
    this._incrementCallClicksUseCase,
    this._reportAdUseCase,
    this._supabaseClient,
  ) : super(AdDetailsInitial()) {
    on<LoadAdDetailsEvent>(_onLoadDetails);
    on<ReportAdEvent>(_onReportAd);
    on<LaunchWhatsappEvent>(_onLaunchWhatsapp);
    on<LaunchCallEvent>(_onLaunchCall);
  }

  Future<void> _onLoadDetails(LoadAdDetailsEvent event, Emitter<AdDetailsState> emit) async {
    emit(AdDetailsLoading());
    _currentAdId = event.adId;
    _currentAdUserId = event.userId;

    // FIX: Added 'await' to ensure the handler doesn't complete
    // before this asynchronous operation finishes.
    await _incrementViewCountUseCase.call(event.adId);

    final result = await _getSellerNameUseCase.call(event.userId);
    result.fold(
      (failure) => emit(AdDetailsError(message: failure.message)),
      (sellerName) {
        final isOwnAd = _supabaseClient.auth.currentUser?.id == event.userId;
        emit(AdDetailsLoaded(sellerName: sellerName, isOwnAd: isOwnAd));
      },
    );
  }

  Future<void> _onReportAd(ReportAdEvent event, Emitter<AdDetailsState> emit) async {
    final result = await _reportAdUseCase.call(ReportAdParams(
      adId: _currentAdId,
      userId: _currentAdUserId,
      reason: event.reason,
      comments: event.comments,
    ));

    result.fold(
      (failure) => emit(AdDetailsActionFailure(message: failure.message)),
      (_) => emit(AdDetailsActionSuccess(message: 'تم استلام بلاغك بنجاح.')),
    );
  }

  Future<void> _onLaunchWhatsapp(LaunchWhatsappEvent event, Emitter<AdDetailsState> emit) async {
    if (event.phoneNumber.isEmpty) {
      emit(AdDetailsActionFailure(message: 'رقم هاتف البائع غير متوفر.'));
      return;
    }
    await _incrementWhatsappClicksUseCase.call(_currentAdId);
    final url = 'https://wa.me/${event.phoneNumber}?text=أنا مهتم بإعلانك "${event.adTitle}" على تطبيق iMarket JO';
    emit(AdDetailsLaunchUrl(url: url));
  }
  
  Future<void> _onLaunchCall(LaunchCallEvent event, Emitter<AdDetailsState> emit) async {
    if (event.phoneNumber.isEmpty) {
      emit(AdDetailsActionFailure(message: 'رقم هاتف البائع غير متوفر.'));
      return;
    }
    await _incrementCallClicksUseCase.call(_currentAdId);
    final url = 'tel:${event.phoneNumber}';
    emit(AdDetailsLaunchUrl(url: url));
  }
}