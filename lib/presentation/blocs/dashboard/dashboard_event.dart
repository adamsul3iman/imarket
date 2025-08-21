part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardDataEvent extends DashboardEvent {}

class MarkAdAsSoldEvent extends DashboardEvent {
  final String adId;
  const MarkAdAsSoldEvent(this.adId);
}

class DeleteAdEvent extends DashboardEvent {
  final String adId;
  const DeleteAdEvent(this.adId);
}