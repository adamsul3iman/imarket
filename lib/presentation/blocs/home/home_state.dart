// lib/presentation/blocs/home/home_state.dart
part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Ad> ads;
  final Set<String> favoriteAdIds;

  const HomeLoaded({required this.ads, required this.favoriteAdIds});

  @override
  List<Object> get props => [ads, favoriteAdIds];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}