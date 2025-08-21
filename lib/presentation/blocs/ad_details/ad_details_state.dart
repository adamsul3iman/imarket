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

  const AdDetailsLoaded({
    required this.sellerName,
    required this.isOwnAd,
  });

  @override
  List<Object?> get props => [sellerName, isOwnAd];
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
  // FIX: Removed 'const' because super constructor is not const
  AdDetailsActionSuccess({required this.message});
}

class AdDetailsActionFailure extends AdDetailsActionState {
  final String message;
  // FIX: Removed 'const'
  AdDetailsActionFailure({required this.message});
}

class AdDetailsLaunchUrl extends AdDetailsActionState {
  final String url;
  // FIX: Removed 'const'
  AdDetailsLaunchUrl({required this.url});
}