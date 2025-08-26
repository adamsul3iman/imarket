import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/fetch_ads_usecase.dart';
import 'package:imarket/domain/usecases/get_seller_name_usecase.dart';
import 'package:imarket/domain/usecases/increment_call_click_usecase.dart';
import 'package:imarket/domain/usecases/increment_view_count_usecase.dart';
import 'package:imarket/domain/usecases/increment_whatsapp_click_usecase.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:imarket/presentation/blocs/ad_details/ad_details_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mocks
class MockGetSellerNameUseCase extends Mock implements GetSellerNameUseCase {}

class MockIncrementViewCountUseCase extends Mock
    implements IncrementViewCountUseCase {}

class MockIncrementWhatsappClicksUseCase extends Mock
    implements IncrementWhatsappClicksUseCase {}

class MockIncrementCallClicksUseCase extends Mock
    implements IncrementCallClicksUseCase {}

class MockReportAdUseCase extends Mock implements ReportAdUseCase {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockFetchAdsUseCase extends Mock implements FetchAdsUseCase {}

void main() {
  late AdDetailsBloc adDetailsBloc;
  late MockGetSellerNameUseCase mockGetSellerNameUseCase;
  late MockIncrementViewCountUseCase mockIncrementViewCountUseCase;
  late MockIncrementWhatsappClicksUseCase mockIncrementWhatsappClicksUseCase;
  late MockIncrementCallClicksUseCase mockIncrementCallClicksUseCase;
  late MockReportAdUseCase mockReportAdUseCase;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockFetchAdsUseCase mockFetchAdsUseCase;

  setUpAll(() {
    registerFallbackValue(FetchAdsParams(searchText: '', filters: {}, page: 0));
  });

  setUp(() {
    mockGetSellerNameUseCase = MockGetSellerNameUseCase();
    mockIncrementViewCountUseCase = MockIncrementViewCountUseCase();
    mockIncrementWhatsappClicksUseCase = MockIncrementWhatsappClicksUseCase();
    mockIncrementCallClicksUseCase = MockIncrementCallClicksUseCase();
    mockReportAdUseCase = MockReportAdUseCase();
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockFetchAdsUseCase = MockFetchAdsUseCase();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);

    adDetailsBloc = AdDetailsBloc(
      mockGetSellerNameUseCase,
      mockIncrementViewCountUseCase,
      mockIncrementWhatsappClicksUseCase,
      mockIncrementCallClicksUseCase,
      mockReportAdUseCase,
      mockSupabaseClient,
      mockFetchAdsUseCase,
    );
  });

  const testUserId = 'user123';
  const testAdId = 'ad123';
  const testModel = 'iPhone 13';
  const testSellerName = 'John Doe';

  final testRelatedAd = Ad.fromMap({
    'id': 'ad456',
    'created_at': DateTime.now().toIso8601String(),
    'title': 'Similar Ad 1',
    'price': 450,
    'image_urls': [],
    'model': 'iPhone 13',
    'storage': 128,
    'user_id': 'seller456',
    'view_count': 0,
    'is_featured': false,
    'whatsapp_clicks': 0,
    'call_clicks': 0,
    'status': 'active',
  });

  group('AdDetailsBloc', () {
    blocTest<AdDetailsBloc, AdDetailsState>(
      'emits [Loading, Loaded] when LoadAdDetailsEvent succeeds',
      build: () {
        when(() => mockIncrementViewCountUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetSellerNameUseCase.call(any()))
            .thenAnswer((_) async => const Right(testSellerName));
        when(() => mockFetchAdsUseCase.call(any()))
            .thenAnswer((_) async => Right([testRelatedAd]));
        when(() => mockUser.id).thenReturn(testUserId);
        return adDetailsBloc;
      },
      act: (bloc) => bloc.add(const LoadAdDetailsEvent(
          adId: testAdId, userId: testUserId, model: testModel)),
      expect: () => <AdDetailsState>[
        AdDetailsLoading(),
        AdDetailsLoaded(
            sellerName: testSellerName,
            isOwnAd: true,
            relatedAds: [testRelatedAd]),
      ],
    );

    blocTest<AdDetailsBloc, AdDetailsState>(
      'emits [Loading, Error] when getting seller name fails',
      build: () {
        when(() => mockIncrementViewCountUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockFetchAdsUseCase.call(any()))
            .thenAnswer((_) async => Right([testRelatedAd]));
        when(() => mockGetSellerNameUseCase.call(any())).thenAnswer((_) async =>
            const Left(ServerFailure(message: 'Failed to fetch name')));
        return adDetailsBloc;
      },
      act: (bloc) => bloc.add(const LoadAdDetailsEvent(
          adId: testAdId, userId: testUserId, model: testModel)),
      expect: () => <AdDetailsState>[
        AdDetailsLoading(),
        const AdDetailsError(message: 'Failed to fetch name'),
      ],
    );
  });
}
