part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

// A specific state for when the user is not logged in
class DashboardLoggedOut extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Ad> userAds;
  final bool hasSubscription;
  final String topDemandModel;

  const DashboardLoaded({
    required this.userAds,
    required this.hasSubscription,
    required this.topDemandModel,
  });

  @override
  List<Object> get props => [userAds, hasSubscription, topDemandModel];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError({required this.message});
}

// Optional: A state to show temporary success messages
class DashboardActionSuccess extends DashboardState {
    final String message;
    const DashboardActionSuccess({required this.message});
}