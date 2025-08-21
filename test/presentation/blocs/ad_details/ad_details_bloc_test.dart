import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/usecases/get_seller_name_usecase.dart';
import 'package:imarket/domain/usecases/increment_call_click_usecase.dart';
import 'package:imarket/domain/usecases/increment_view_count_usecase.dart';
import 'package:imarket/domain/usecases/increment_whatsapp_click_usecase.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:imarket/presentation/blocs/ad_details/ad_details_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Mocks for ALL dependencies ---
class MockGetSellerNameUseCase extends Mock implements GetSellerNameUseCase {}
class MockIncrementViewCountUseCase extends Mock implements IncrementViewCountUseCase {}
class MockIncrementWhatsappClicksUseCase extends Mock implements IncrementWhatsappClicksUseCase {}
class MockIncrementCallClicksUseCase extends Mock implements IncrementCallClicksUseCase {}
class MockReportAdUseCase extends Mock implements ReportAdUseCase {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

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

  setUp(() {
    // Initialize all mocks
    mockGetSellerNameUseCase = MockGetSellerNameUseCase();
    mockIncrementViewCountUseCase = MockIncrementViewCountUseCase();
    mockIncrementWhatsappClicksUseCase = MockIncrementWhatsappClicksUseCase();
    mockIncrementCallClicksUseCase = MockIncrementCallClicksUseCase();
    mockReportAdUseCase = MockReportAdUseCase();
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);

    // FIX: Provide ALL required mocks to the BLoC constructor
    adDetailsBloc = AdDetailsBloc(
      mockGetSellerNameUseCase,
      mockIncrementViewCountUseCase,
      mockIncrementWhatsappClicksUseCase,
      mockIncrementCallClicksUseCase,
      mockReportAdUseCase,
      mockSupabaseClient,
    );
  });
  
  const testUserId = 'user123';
  const testAdId = 'ad123';
  const testSellerName = 'John Doe';

  group('AdDetailsBloc', () {
    blocTest<AdDetailsBloc, AdDetailsState>(
      'emits [Loading, Loaded] when LoadAdDetailsEvent is added and succeeds',
      build: () {
        when(() => mockGetSellerNameUseCase.call(any())).thenAnswer((_) async => const Right(testSellerName));
        when(() => mockIncrementViewCountUseCase.call(any())).thenAnswer((_) async => const Right(null));
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn(testUserId);
        return adDetailsBloc;
      },
      act: (bloc) => bloc.add(const LoadAdDetailsEvent(adId: testAdId, userId: testUserId)),
      expect: () => <AdDetailsState>[
        AdDetailsLoading(),
        // FIX: Provide the required 'isOwnAd' parameter
        const AdDetailsLoaded(sellerName: testSellerName, isOwnAd: true),
      ],
      verify: (_) {
        verify(() => mockGetSellerNameUseCase.call(testUserId)).called(1);
        verify(() => mockIncrementViewCountUseCase.call(testAdId)).called(1);
      },
    );

    blocTest<AdDetailsBloc, AdDetailsState>(
      'emits [Loading, Error] when LoadAdDetailsEvent fails',
      build: () {
        when(() => mockIncrementViewCountUseCase.call(any())).thenAnswer((_) async => const Right(null));
        when(() => mockGetSellerNameUseCase.call(any())).thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to fetch')));
        return adDetailsBloc;
      },
      act: (bloc) => bloc.add(const LoadAdDetailsEvent(adId: testAdId, userId: testUserId)),
      expect: () => <AdDetailsState>[
        AdDetailsLoading(),
        const AdDetailsError(message: 'Failed to fetch'),
      ],
    );
  });
}