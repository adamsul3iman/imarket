part of 'change_password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class NewPasswordChanged extends ChangePasswordEvent {
  final String password;
  const NewPasswordChanged(this.password);
}

class ConfirmPasswordChanged extends ChangePasswordEvent {
  final String password;
  const ConfirmPasswordChanged(this.password);
}

class ChangePasswordSubmitted extends ChangePasswordEvent {}