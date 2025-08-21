part of 'seller_profile_bloc.dart';

abstract class SellerProfileEvent extends Equatable {
  const SellerProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadSellerProfileEvent extends SellerProfileEvent {
  final String sellerId;

  const LoadSellerProfileEvent({required this.sellerId});

  @override
  List<Object> get props => [sellerId];
}

// FIX: Added new event for toggling favorite status
class ToggleFavoriteEvent extends SellerProfileEvent {
  final String adId;

  const ToggleFavoriteEvent({required this.adId});

  @override
  List<Object> get props => [adId];
}