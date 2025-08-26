part of 'signup_bloc.dart';

enum SignUpStatus { initial, submitting, success, failure }

class SignUpState extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final SignUpStatus status;
  final String? errorMessage;

  const SignUpState({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = SignUpStatus.initial,
    this.errorMessage,
  });

  SignUpState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    SignUpStatus? status,
    String? errorMessage,
  }) {
    return SignUpState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [fullName, email, password, confirmPassword, status, errorMessage];
}