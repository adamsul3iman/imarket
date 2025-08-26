part of 'blocked_users_bloc.dart';

abstract class BlockedUsersEvent extends Equatable {
  const BlockedUsersEvent();

  @override
  List<Object> get props => [];
}

class FetchBlockedUsers extends BlockedUsersEvent {}

class UnblockUser extends BlockedUsersEvent {
  final String userId;
  const UnblockUser(this.userId);
}