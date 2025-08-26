part of 'account_settings_bloc.dart';

abstract class AccountSettingsEvent extends Equatable {
  const AccountSettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadAccountData extends AccountSettingsEvent {}

class FullNameChanged extends AccountSettingsEvent {
  final String fullName;
  const FullNameChanged(this.fullName);
}

class PhoneNumberChanged extends AccountSettingsEvent {
  final String phoneNumber;
  const PhoneNumberChanged(this.phoneNumber);
}

class SubmitAccountChanges extends AccountSettingsEvent {}