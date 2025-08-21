// test/presentation/blocs/dashboard/dashboard_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/delete_ad_usecase.dart';
import 'package:imarket/domain/usecases/get_user_ads_usecase.dart';
import 'package:imarket/domain/usecases/update_ad_status_usecase.dart';
import 'package:imarket/presentation/blocs/dashboard/dashboard_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Mocks & Fakes ---
class MockGetUserAdsUseCase extends Mock implements GetUserAdsUseCase {}
class MockUpdateAdStatusUseCase extends Mock implements UpdateAdStatusUseCase {}
class MockDeleteAdUseCase extends Mock implements DeleteAdUseCase {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class FakeUpdateAdStatusParams extends Fake implements UpdateAdStatusParams {}

void main() {
  // Register the fallback value once before any tests run
  setUpAll(() {
    registerFallbackValue(FakeUpdateAdStatusParams());
  });

  late DashboardBloc dashboardBloc;
  late MockGetUserAdsUseCase mockGetUserAdsUseCase;
  late MockUpdateAdStatusUseCase mockUpdateAdStatusUseCase;
  late MockDeleteAdUseCase mockDeleteAdUseCase;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockGetUserAdsUseCase = MockGetUserAdsUseCase();
    mockUpdateAdStatusUseCase = MockUpdateAdStatusUseCase();
    mockDeleteAdUseCase = MockDeleteAdUseCase();
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);

    dashboardBloc = DashboardBloc(
      mockSupabaseClient,
      mockGetUserAdsUseCase,
      mockUpdateAdStatusUseCase,
      mockDeleteAdUseCase,
    );
  });

  // A dummy ad list for testing
  final testAds = [
    Ad.fromMap({
      'id': '1',
      'created_at': DateTime.now().toIso8601String(),
      'title': 'Test Ad',
      'price': 100,
      'image_urls': [],
      'model': 'iPhone',
      'storage': 128,
      'user_id': 'user123',
      'view_count': 0,
      'is_featured': false,
      'whatsapp_clicks': 0,
      'call_clicks': 0,
      'status': 'active'
    })
  ];

  const testUserId = 'user123';

  group('DashboardBloc', () {
    // Test 1: Successful Data Load
    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Loaded] when user is logged in and data fetches successfully',
      setUp: () {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn(testUserId);
        when(() => mockGetUserAdsUseCase.call(any()))
            .thenAnswer((_) async => Right(testAds));
        // Mock other data fetching use cases here to return dummy data
      },
      build: () => dashboardBloc,
      act: (bloc) => bloc.add(LoadDashboardDataEvent()),
      expect: () => <DashboardState>[
        DashboardLoading(),
        DashboardLoaded(
          userAds: testAds,
          hasSubscription: false, // Dummy data
          topDemandModel: 'N/A', // Dummy data
        ),
      ],
    );

    // Test 2: User is Logged Out
    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, LoggedOut] when user is not logged in',
      setUp: () {
        when(() => mockAuth.currentUser).thenReturn(null);
      },
      build: () => dashboardBloc,
      act: (bloc) => bloc.add(LoadDashboardDataEvent()),
      expect: () => <DashboardState>[
        DashboardLoading(),
        DashboardLoggedOut(),
      ],
      verify: (_) {
        verifyNever(() => mockGetUserAdsUseCase.call(any()));
      },
    );

    // Test 3: Successful Action (Delete Ad)
    blocTest<DashboardBloc, DashboardState>(
      'emits [ActionSuccess] and reloads data when DeleteAdEvent is successful',
      setUp: () {
        when(() => mockDeleteAdUseCase.call(any()))
            .thenAnswer((_) async => const Right(null)); // Success returns Right(void) which is Right(null)
        
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn(testUserId);
        when(() => mockGetUserAdsUseCase.call(any()))
            .thenAnswer((_) async => const Right([])); // Return empty list after delete
      },
      build: () => dashboardBloc,
      act: (bloc) => bloc.add(const DeleteAdEvent('ad1')),
      expect: () => <DashboardState>[
        const DashboardActionSuccess(message: 'تم حذف الإعلان بنجاح!'),
        DashboardLoading(),
        const DashboardLoaded(
          userAds: [],
          hasSubscription: false,
          topDemandModel: 'N/A',
        ),
      ],
      verify: (_) {
        verify(() => mockDeleteAdUseCase.call('ad1')).called(1);
      },
    );

    // Test 4: Action Fails (Mark as Sold)
    blocTest<DashboardBloc, DashboardState>(
      'emits [Error] when MarkAdAsSoldEvent fails',
      setUp: () {
        when(() => mockUpdateAdStatusUseCase.call(any()))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'DB Error')));
      },
      build: () => dashboardBloc,
      act: (bloc) => bloc.add(const MarkAdAsSoldEvent('ad1')),
      expect: () => <DashboardState>[
        const DashboardError(message: 'DB Error'),
      ],
    );
  });
}