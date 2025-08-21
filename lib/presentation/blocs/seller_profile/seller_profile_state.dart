part of 'seller_profile_bloc.dart';

abstract class SellerProfileState extends Equatable {
  const SellerProfileState();

  @override
  List<Object> get props => [];
}

class SellerProfileInitial extends SellerProfileState {}

class SellerProfileLoading extends SellerProfileState {}

class SellerProfileLoaded extends SellerProfileState {
  final SellerProfileData data;
  // We can add favorite status here later for the ads
  final Set<String> favoriteAdIds;

  const SellerProfileLoaded({required this.data, this.favoriteAdIds = const {}});

  @override
  List<Object> get props => [data, favoriteAdIds];
}

class SellerProfileError extends SellerProfileState {
  final String message;

  const SellerProfileError({required this.message});

  @override
  List<Object> get props => [message];
}