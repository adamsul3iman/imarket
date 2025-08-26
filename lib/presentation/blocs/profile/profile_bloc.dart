import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/entities/user_profile.dart';
import 'package:imarket/domain/usecases/get_user_profile_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final SupabaseClient _supabaseClient;

  ProfileBloc(this._getUserProfileUseCase, this._supabaseClient) : super(ProfileInitial()) {
    on<LoadProfileDataEvent>(_onLoadData);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onLoadData(LoadProfileDataEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      emit(ProfileLoggedOut());
      return;
    }

    final failureOrProfile = await _getUserProfileUseCase.call(user.id);
    
    failureOrProfile.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (userProfile) => emit(ProfileLoaded(userProfile: userProfile)),
    );
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<ProfileState> emit) async {
    await _supabaseClient.auth.signOut();
    emit(ProfileLoggedOut());
  }
}