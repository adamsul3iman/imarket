import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'account_settings_event.dart';
part 'account_settings_state.dart';

@injectable
class AccountSettingsBloc extends Bloc<AccountSettingsEvent, AccountSettingsState> {
  final SupabaseClient _supabase;

  AccountSettingsBloc(this._supabase) : super(const AccountSettingsState()) {
    on<LoadAccountData>(_onLoadData);
    on<FullNameChanged>(_onFullNameChanged);
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<SubmitAccountChanges>(_onSubmit);
  }

  void _onLoadData(LoadAccountData event, Emitter<AccountSettingsState> emit) {
    emit(state.copyWith(status: AccountSettingsStatus.loading));
    final user = _supabase.auth.currentUser;
    if (user != null) {
      emit(state.copyWith(
        status: AccountSettingsStatus.loaded,
        fullName: user.userMetadata?['full_name'] as String? ?? '',
        phoneNumber: user.phone?.replaceFirst('+962', '') ?? '',
      ));
    } else {
      emit(state.copyWith(status: AccountSettingsStatus.failure, errorMessage: 'User not found'));
    }
  }
  
  void _onFullNameChanged(FullNameChanged event, Emitter<AccountSettingsState> emit) {
    emit(state.copyWith(fullName: event.fullName));
  }

  void _onPhoneNumberChanged(PhoneNumberChanged event, Emitter<AccountSettingsState> emit) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  Future<void> _onSubmit(SubmitAccountChanges event, Emitter<AccountSettingsState> emit) async {
    emit(state.copyWith(status: AccountSettingsStatus.submitting));

    final user = _supabase.auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: AccountSettingsStatus.failure, errorMessage: 'User not authenticated'));
      return;
    }

    final newPhoneNumber = '+962${state.phoneNumber.trim()}';
    final isPhoneChanged = newPhoneNumber != user.phone;

    try {
      await _supabase.auth.updateUser(UserAttributes(
        phone: newPhoneNumber,
        data: {'full_name': state.fullName.trim()},
      ));
      
      emit(state.copyWith(
        status: AccountSettingsStatus.success,
        navigateToOtp: isPhoneChanged, // Navigate to OTP only if phone changed
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AccountSettingsStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: AccountSettingsStatus.failure, errorMessage: 'An unexpected error occurred'));
    }
  }
}