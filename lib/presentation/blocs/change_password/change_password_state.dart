part of 'change_password_bloc.dart';

enum ChangePasswordStatus { initial, submitting, success, failure }

class ChangePasswordState extends Equatable {
  final String newPassword;
  final String confirmPassword;
  final ChangePasswordStatus status;
  final String? errorMessage;

  const ChangePasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.status = ChangePasswordStatus.initial,
    this.errorMessage,
  });

  ChangePasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    ChangePasswordStatus? status,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [newPassword, confirmPassword, status, errorMessage];
}