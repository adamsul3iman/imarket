import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/fetch_ads_usecase.dart';
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
  final FetchAdsUseCase _fetchAdsUseCase;

  String _currentAdId = '';
  String _currentAdUserId = '';

  AdDetailsBloc(
    this._getSellerNameUseCase,
    this._incrementViewCountUseCase,
    this._incrementWhatsappClicksUseCase,
    this._incrementCallClicksUseCase,
    this._reportAdUseCase,
    this._supabaseClient,
    this._fetchAdsUseCase,
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

    // Fire-and-forget the view count increment.
    _incrementViewCountUseCase.call(event.adId);

    // Fetch seller name and related ads in parallel to be more efficient.
    final results = await Future.wait([
      _getSellerNameUseCase.call(event.userId),
      _fetchAdsUseCase.call(FetchAdsParams(
        searchText: '',
        filters: {'model': event.model},
        page: 0,
      )),
    ]);

    final sellerNameResult = results[0] as dynamic;
    final relatedAdsResult = results[1] as dynamic;

    // Process the results and emit ONE final state.
    sellerNameResult.fold(
      (failure) {
        emit(AdDetailsError(message: failure.message));
      },
      (sellerName) {
        final isOwnAd = _supabaseClient.auth.currentUser?.id == event.userId;
        
        relatedAdsResult.fold(
          (failure) {
            // If related ads fail, we still succeed but with an empty list.
            emit(AdDetailsLoaded(sellerName: sellerName, isOwnAd: isOwnAd, relatedAds: []));
          },
          (ads) {
            final filteredAds = ads.where((ad) => ad.id != _currentAdId).toList();
            // This is the single, final success state with all data.
            emit(AdDetailsLoaded(sellerName: sellerName, isOwnAd: isOwnAd, relatedAds: filteredAds));
          },
        );
      },
    );
  }

  Future<void> _onReportAd(
      ReportAdEvent event, Emitter<AdDetailsState> emit) async {
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

  Future<void> _onLoadRelatedAds(
      LoadRelatedAdsEvent event, Emitter<AdDetailsState> emit) async {
    if (state is AdDetailsLoaded) {
      final currentState = state as AdDetailsLoaded;
      final result = await _fetchAdsUseCase.call(FetchAdsParams(
        searchText: '',
        filters: {'model': event.model},
        page: 0,
      ));

      result.fold(
        (failure) {
          // يمكننا إرسال رسالة خطأ، لكننا سنكتفي بعدم تحديث القائمة
        },
        (ads) {
          final filteredAds = ads.where((ad) => ad.id != _currentAdId).toList();
          emit(currentState.copyWith(relatedAds: filteredAds));
        },
      );
    }
  }

  Future<void> _onLaunchWhatsapp(
      LaunchWhatsappEvent event, Emitter<AdDetailsState> emit) async {
    if (event.phoneNumber.isEmpty) {
      emit(AdDetailsActionFailure(message: 'رقم هاتف البائع غير متوفر.'));
      return;
    }
    await _incrementWhatsappClicksUseCase.call(_currentAdId);
    final url =
        'https://wa.me/${event.phoneNumber}?text=أنا مهتم بإعلانك "${event.adTitle}" على تطبيق iMarket JO';
    emit(AdDetailsLaunchUrl(url: url));
  }

  Future<void> _onLaunchCall(
      LaunchCallEvent event, Emitter<AdDetailsState> emit) async {
    if (event.phoneNumber.isEmpty) {
      emit(AdDetailsActionFailure(message: 'رقم هاتف البائع غير متوفر.'));
      return;
    }
    await _incrementCallClicksUseCase.call(_currentAdId);
    final url = 'tel:${event.phoneNumber}';
    emit(AdDetailsLaunchUrl(url: url));
  }
}
