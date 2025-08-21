// lib/presentation/blocs/home/home_event.dart
part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

// FIX: Added members to the event to carry search/filter data
class FetchAdsEvent extends HomeEvent {
  final String searchText;
  final Map<String, dynamic> filters;
  final int page;

  const FetchAdsEvent({
    this.searchText = '',
    this.filters = const {},
    this.page = 0,
  });
}

class ToggleFavoriteEvent extends HomeEvent {
  final String adId;
  const ToggleFavoriteEvent(this.adId);
}