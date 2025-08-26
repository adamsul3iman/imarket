part of 'signup_bloc.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpFullNameChanged extends SignUpEvent {
  final String fullName;
  const SignUpFullNameChanged(this.fullName);
}

class SignUpEmailChanged extends SignUpEvent {
  final String email;
  const SignUpEmailChanged(this.email);
}

class SignUpPasswordChanged extends SignUpEvent {
  final String password;
  const SignUpPasswordChanged(this.password);
}

class SignUpConfirmPasswordChanged extends SignUpEvent {
  final String password;
  const SignUpConfirmPasswordChanged(this.password);
}

class SignUpSubmitted extends SignUpEvent {}