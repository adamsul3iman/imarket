part of 'ad_details_bloc.dart';

abstract class AdDetailsEvent extends Equatable {
  const AdDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadAdDetailsEvent extends AdDetailsEvent {
  final String adId;
  final String userId;
  final String model; // NEW: تم إضافة model

  const LoadAdDetailsEvent({required this.adId, required this.userId, required this.model});
}

class ReportAdEvent extends AdDetailsEvent {
  final String reason;
  final String comments;

  const ReportAdEvent({required this.reason, required this.comments});
}

class LaunchWhatsappEvent extends AdDetailsEvent {
  final String phoneNumber;
  final String adTitle;

  const LaunchWhatsappEvent({required this.phoneNumber, required this.adTitle});
}

class LaunchCallEvent extends AdDetailsEvent {
  final String phoneNumber;

  const LaunchCallEvent({required this.phoneNumber});
}

class LoadRelatedAdsEvent extends AdDetailsEvent { // NEW: تم إضافة هذا الحدث
  final String model;

  const LoadRelatedAdsEvent({required this.model});
}