import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

@injectable
class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final SupabaseClient _supabase;

  ChangePasswordBloc(this._supabase) : super(const ChangePasswordState()) {
    on<NewPasswordChanged>((event, emit) => emit(state.copyWith(newPassword: event.password)));
    on<ConfirmPasswordChanged>((event, emit) => emit(state.copyWith(confirmPassword: event.password)));
    on<ChangePasswordSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(ChangePasswordSubmitted event, Emitter<ChangePasswordState> emit) async {
    if (state.newPassword != state.confirmPassword) {
      emit(state.copyWith(status: ChangePasswordStatus.failure, errorMessage: 'كلمتا المرور غير متطابقتين'));
      return;
    }
    
    emit(state.copyWith(status: ChangePasswordStatus.submitting));
    try {
      await _supabase.auth.updateUser(UserAttributes(
        password: state.newPassword.trim(),
      ));
      emit(state.copyWith(status: ChangePasswordStatus.success));
    } on AuthException catch (e) {
      emit(state.copyWith(status: ChangePasswordStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: ChangePasswordStatus.failure, errorMessage: 'حدث خطأ غير متوقع'));
    }
  }
}