import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

part 'login_event.dart';
part 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginState()) {
    on<LoginEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
    on<LoginPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<LoginSubmitted>(_onSubmit);
    on<LoginPasswordResetRequested>(_onPasswordReset);
  }

  Future<void> _onSubmit(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.submitting));
    final result = await _authRepository.signInWithPassword(
      email: state.email,
      password: state.password,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: LoginStatus.failure, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: LoginStatus.success)),
    );
  }

  Future<void> _onPasswordReset(LoginPasswordResetRequested event, Emitter<LoginState> emit) async {
    // This can be enhanced with a submitting status if needed
    final result = await _authRepository.resetPasswordForEmail(state.email);
    // We don't change the main status, just show a message via the listener in the UI
    result.fold(
      (failure) => emit(state.copyWith(status: LoginStatus.failure, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: LoginStatus.initial)), // Reset status after success
    );
  }
}