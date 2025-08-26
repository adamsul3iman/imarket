part of 'ad_details_bloc.dart';

abstract class AdDetailsState extends Equatable {
  const AdDetailsState();

  @override
  List<Object?> get props => [];
}

class AdDetailsInitial extends AdDetailsState {}

class AdDetailsLoading extends AdDetailsState {}

class AdDetailsLoaded extends AdDetailsState {
  final String sellerName;
  final bool isOwnAd;
  final List<Ad> relatedAds; // NEW: تم إضافة relatedAds

  const AdDetailsLoaded({
    required this.sellerName,
    required this.isOwnAd,
    this.relatedAds = const [],
  });

  AdDetailsLoaded copyWith({
    String? sellerName,
    bool? isOwnAd,
    List<Ad>? relatedAds,
  }) {
    return AdDetailsLoaded(
      sellerName: sellerName ?? this.sellerName,
      isOwnAd: isOwnAd ?? this.isOwnAd,
      relatedAds: relatedAds ?? this.relatedAds,
    );
  }

  @override
  List<Object?> get props => [sellerName, isOwnAd, relatedAds];
}

class AdDetailsError extends AdDetailsState {
  final String message;

  const AdDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Action states for side-effects
abstract class AdDetailsActionState extends AdDetailsState {}

class AdDetailsActionSuccess extends AdDetailsActionState {
  final String message;
  AdDetailsActionSuccess({required this.message});
}

class AdDetailsActionFailure extends AdDetailsActionState {
  final String message;
  AdDetailsActionFailure({required this.message});
}

class AdDetailsLaunchUrl extends AdDetailsActionState {
  final String url;
  AdDetailsLaunchUrl({required this.url});
}