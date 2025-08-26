// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../data/datasources/ad_local_data_source.dart' as _i1052;
import '../../data/datasources/ad_remote_data_source.dart' as _i423;
import '../../data/datasources/auth_remote_data_source.dart' as _i716;
import '../../data/datasources/profile_remote_data_source.dart' as _i966;
import '../../data/datasources/seller_profile_remote_data_source.dart' as _i865;
import '../../data/repositories/ad_repository_impl.dart' as _i996;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../data/repositories/profile_repository_impl.dart' as _i813;
import '../../data/repositories/seller_profile_repository_impl.dart' as _i378;
import '../../domain/repositories/ad_repository.dart' as _i1053;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/repositories/profile_repository.dart' as _i47;
import '../../domain/repositories/seller_profile_repository.dart' as _i805;
import '../../domain/usecases/delete_ad_usecase.dart' as _i11;
import '../../domain/usecases/delete_favorites_usecase.dart' as _i131;
import '../../domain/usecases/fetch_ads_usecase.dart' as _i264;
import '../../domain/usecases/get_favorite_ads_usecase.dart' as _i168;
import '../../domain/usecases/get_favorites_usecase.dart' as _i520;
import '../../domain/usecases/get_market_analysis_usecase.dart' as _i870;
import '../../domain/usecases/get_seller_name_usecase.dart' as _i311;
import '../../domain/usecases/get_seller_profile_data_usecase.dart' as _i644;
import '../../domain/usecases/get_user_ads_usecase.dart' as _i628;
import '../../domain/usecases/get_user_profile_usecase.dart' as _i629;
import '../../domain/usecases/increment_call_click_usecase.dart' as _i449;
import '../../domain/usecases/increment_view_count_usecase.dart' as _i187;
import '../../domain/usecases/increment_whatsapp_click_usecase.dart' as _i222;
import '../../domain/usecases/report_ad_usecase.dart' as _i900;
import '../../domain/usecases/submit_ad_usecase.dart' as _i0;
import '../../domain/usecases/toggle_favorite_usecase.dart' as _i308;
import '../../domain/usecases/update_ad_status_usecase.dart' as _i940;
import '../../presentation/blocs/account_settings/account_settings_bloc.dart'
    as _i995;
import '../../presentation/blocs/ad_analysis/ad_analysis_bloc.dart' as _i155;
import '../../presentation/blocs/ad_details/ad_details_bloc.dart' as _i850;
import '../../presentation/blocs/add_ad/add_ad_bloc.dart' as _i320;
import '../../presentation/blocs/blocked_users/blocked_users_bloc.dart'
    as _i243;
import '../../presentation/blocs/change_password/change_password_bloc.dart'
    as _i605;
import '../../presentation/blocs/dashboard/dashboard_bloc.dart' as _i286;
import '../../presentation/blocs/favorites/favorites_bloc.dart' as _i187;
import '../../presentation/blocs/home/home_bloc.dart' as _i973;
import '../../presentation/blocs/login/login_bloc.dart' as _i858;
import '../../presentation/blocs/profile/profile_bloc.dart' as _i344;
import '../../presentation/blocs/saved_searches/saved_searches_bloc.dart'
    as _i985;
import '../../presentation/blocs/seller_profile/seller_profile_bloc.dart'
    as _i630;
import '../../presentation/blocs/signup/signup_bloc.dart' as _i274;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i183.ImagePicker>(() => registerModule.imagePicker);
    gh.lazySingleton<_i716.AuthRemoteDataSource>(
        () => _i716.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i966.ProfileRemoteDataSource>(
        () => _i966.ProfileRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i423.AdRemoteDataSource>(
        () => _i423.AdRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.factory<_i995.AccountSettingsBloc>(
        () => _i995.AccountSettingsBloc(gh<_i454.SupabaseClient>()));
    gh.factory<_i243.BlockedUsersBloc>(
        () => _i243.BlockedUsersBloc(gh<_i454.SupabaseClient>()));
    gh.factory<_i605.ChangePasswordBloc>(
        () => _i605.ChangePasswordBloc(gh<_i454.SupabaseClient>()));
    gh.factory<_i985.SavedSearchesBloc>(
        () => _i985.SavedSearchesBloc(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i1073.AuthRepository>(() => _i895.AuthRepositoryImpl(
        remoteDataSource: gh<_i716.AuthRemoteDataSource>()));
    gh.lazySingleton<_i865.SellerProfileRemoteDataSource>(() =>
        _i865.SellerProfileRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i1052.AdLocalDataSource>(
        () => _i1052.AdLocalDataSourceImpl());
    gh.lazySingleton<_i47.ProfileRepository>(() => _i813.ProfileRepositoryImpl(
        remoteDataSource: gh<_i966.ProfileRemoteDataSource>()));
    gh.factory<_i858.LoginBloc>(
        () => _i858.LoginBloc(gh<_i1073.AuthRepository>()));
    gh.factory<_i274.SignUpBloc>(
        () => _i274.SignUpBloc(gh<_i1073.AuthRepository>()));
    gh.lazySingleton<_i805.SellerProfileRepository>(() =>
        _i378.SellerProfileRepositoryImpl(
            remoteDataSource: gh<_i865.SellerProfileRemoteDataSource>()));
    gh.lazySingleton<_i1053.AdRepository>(() => _i996.AdRepositoryImpl(
          remoteDataSource: gh<_i423.AdRemoteDataSource>(),
          localDataSource: gh<_i1052.AdLocalDataSource>(),
        ));
    gh.lazySingleton<_i629.GetUserProfileUseCase>(
        () => _i629.GetUserProfileUseCase(gh<_i47.ProfileRepository>()));
    gh.lazySingleton<_i11.DeleteAdUseCase>(
        () => _i11.DeleteAdUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i131.DeleteFavoritesUseCase>(
        () => _i131.DeleteFavoritesUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i264.FetchAdsUseCase>(
        () => _i264.FetchAdsUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i520.GetFavoritesUseCase>(
        () => _i520.GetFavoritesUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i168.GetFavoriteAdsUseCase>(
        () => _i168.GetFavoriteAdsUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i870.GetMarketAnalysisUseCase>(
        () => _i870.GetMarketAnalysisUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i311.GetSellerNameUseCase>(
        () => _i311.GetSellerNameUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i628.GetUserAdsUseCase>(
        () => _i628.GetUserAdsUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i449.IncrementCallClicksUseCase>(
        () => _i449.IncrementCallClicksUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i187.IncrementViewCountUseCase>(
        () => _i187.IncrementViewCountUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i222.IncrementWhatsappClicksUseCase>(
        () => _i222.IncrementWhatsappClicksUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i900.ReportAdUseCase>(
        () => _i900.ReportAdUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i0.SubmitAdUseCase>(
        () => _i0.SubmitAdUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i308.ToggleFavoriteUseCase>(
        () => _i308.ToggleFavoriteUseCase(gh<_i1053.AdRepository>()));
    gh.lazySingleton<_i940.UpdateAdStatusUseCase>(
        () => _i940.UpdateAdStatusUseCase(gh<_i1053.AdRepository>()));
    gh.factory<_i344.ProfileBloc>(() => _i344.ProfileBloc(
          gh<_i629.GetUserProfileUseCase>(),
          gh<_i454.SupabaseClient>(),
        ));
    gh.lazySingleton<_i644.GetSellerProfileDataUseCase>(() =>
        _i644.GetSellerProfileDataUseCase(gh<_i805.SellerProfileRepository>()));
    gh.factory<_i973.HomeBloc>(() => _i973.HomeBloc(
          gh<_i264.FetchAdsUseCase>(),
          gh<_i520.GetFavoritesUseCase>(),
          gh<_i308.ToggleFavoriteUseCase>(),
        ));
    gh.factory<_i850.AdDetailsBloc>(() => _i850.AdDetailsBloc(
          gh<_i311.GetSellerNameUseCase>(),
          gh<_i187.IncrementViewCountUseCase>(),
          gh<_i222.IncrementWhatsappClicksUseCase>(),
          gh<_i449.IncrementCallClicksUseCase>(),
          gh<_i900.ReportAdUseCase>(),
          gh<_i454.SupabaseClient>(),
          gh<_i264.FetchAdsUseCase>(),
        ));
    gh.factory<_i155.AdAnalysisBloc>(
        () => _i155.AdAnalysisBloc(gh<_i870.GetMarketAnalysisUseCase>()));
    gh.factory<_i320.AddAdBloc>(() => _i320.AddAdBloc(
          gh<_i0.SubmitAdUseCase>(),
          gh<_i183.ImagePicker>(),
        ));
    gh.factory<_i187.FavoritesBloc>(() => _i187.FavoritesBloc(
          gh<_i168.GetFavoriteAdsUseCase>(),
          gh<_i308.ToggleFavoriteUseCase>(),
        ));
    gh.factory<_i630.SellerProfileBloc>(() => _i630.SellerProfileBloc(
          gh<_i644.GetSellerProfileDataUseCase>(),
          gh<_i520.GetFavoritesUseCase>(),
          gh<_i308.ToggleFavoriteUseCase>(),
        ));
    gh.factory<_i286.DashboardBloc>(() => _i286.DashboardBloc(
          gh<_i454.SupabaseClient>(),
          gh<_i628.GetUserAdsUseCase>(),
          gh<_i940.UpdateAdStatusUseCase>(),
          gh<_i11.DeleteAdUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
