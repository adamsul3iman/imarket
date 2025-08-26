import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:imarket/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

part 'signup_event.dart';
part 'signup_state.dart';

@injectable
class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository _authRepository;

  // لم نعد بحاجة لـ SupabaseClient هنا
  SignUpBloc(this._authRepository) : super(const SignUpState()) {
    on<SignUpFullNameChanged>((event, emit) => emit(state.copyWith(fullName: event.fullName)));
    on<SignUpEmailChanged>((event, emit) => emit(state.copyWith(email: event.email)));
    on<SignUpPasswordChanged>((event, emit) => emit(state.copyWith(password: event.password)));
    on<SignUpConfirmPasswordChanged>((event, emit) => emit(state.copyWith(confirmPassword: event.password)));
    on<SignUpSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(SignUpSubmitted event, Emitter<SignUpState> emit) async {
    if (state.password != state.confirmPassword) {
      emit(state.copyWith(status: SignUpStatus.failure, errorMessage: 'كلمتا المرور غير متطابقتين'));
      return;
    }
    
    emit(state.copyWith(status: SignUpStatus.submitting));
    
    // الآن، كل ما نقوم به هو إنشاء الحساب. قاعدة البيانات ستهتم بالباقي.
    final result = await _authRepository.signUp(
      fullName: state.fullName,
      email: state.email,
      password: state.password,
    );
    
    result.fold(
      (failure) => emit(state.copyWith(status: SignUpStatus.failure, errorMessage: failure.message)),
      (user) => emit(state.copyWith(status: SignUpStatus.success)),
    );
  }
}