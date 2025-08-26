part of 'add_ad_bloc.dart';

abstract class AddAdEvent extends Equatable {
  const AddAdEvent();

  @override
  List<Object?> get props => [];
}

// Events for every user interaction
class AddAdModelChanged extends AddAdEvent {
  final String? model;
  const AddAdModelChanged(this.model);
}

class AddAdStorageChanged extends AddAdEvent {
  final int? storage;
  const AddAdStorageChanged(this.storage);
}

class AddAdColorChanged extends AddAdEvent {
  final String? color;
  const AddAdColorChanged(this.color);
}

class AddAdConditionChanged extends AddAdEvent {
  final String? condition;
  const AddAdConditionChanged(this.condition);
}

class AddAdCityChanged extends AddAdEvent {
  final String? city;
  const AddAdCityChanged(this.city);
}

class AddAdPriceChanged extends AddAdEvent {
  final String price;
  const AddAdPriceChanged(this.price);
}

class AddAdPhoneNumberChanged extends AddAdEvent {
  final String phoneNumber;
  const AddAdPhoneNumberChanged(this.phoneNumber);
}

class AddAdBatteryHealthChanged extends AddAdEvent {
  final String batteryHealth;
  const AddAdBatteryHealthChanged(this.batteryHealth);
}

class AddAdIsRepairedChanged extends AddAdEvent {
  final bool isRepaired;
  const AddAdIsRepairedChanged(this.isRepaired);
}

class AddAdRepairedPartsChanged extends AddAdEvent {
  final String repairedParts;
  const AddAdRepairedPartsChanged(this.repairedParts);
}

class AddAdHasBoxChanged extends AddAdEvent {
  final bool hasBox;
  const AddAdHasBoxChanged(this.hasBox);
}

class AddAdHasChargerChanged extends AddAdEvent {
  final bool hasCharger;
  const AddAdHasChargerChanged(this.hasCharger);
}

class AddAdDescriptionChanged extends AddAdEvent {
  final String description;
  const AddAdDescriptionChanged(this.description);
}

class AddAdImagesPicked extends AddAdEvent {
  final List<XFile> images;
  const AddAdImagesPicked(this.images);
}

class AddAdSubmitted extends AddAdEvent {}