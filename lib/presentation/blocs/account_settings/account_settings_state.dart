part of 'account_settings_bloc.dart';

enum AccountSettingsStatus { initial, loading, loaded, submitting, success, failure }

class AccountSettingsState extends Equatable {
  final AccountSettingsStatus status;
  final String fullName;
  final String phoneNumber;
  final bool navigateToOtp;
  final String? errorMessage;
  
  const AccountSettingsState({
    this.status = AccountSettingsStatus.initial,
    this.fullName = '',
    this.phoneNumber = '',
    this.navigateToOtp = false,
    this.errorMessage,
  });

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    String? fullName,
    String? phoneNumber,
    bool? navigateToOtp,
    String? errorMessage,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      navigateToOtp: navigateToOtp ?? this.navigateToOtp,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, fullName, phoneNumber, navigateToOtp, errorMessage];
}