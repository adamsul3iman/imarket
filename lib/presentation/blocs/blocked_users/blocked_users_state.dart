part of 'blocked_users_bloc.dart';

// We can move the BlockedUser model to be a domain entity later
class BlockedUser extends Equatable {
  final String id;
  final String fullName;

  const BlockedUser({required this.id, required this.fullName});

  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    return BlockedUser(
      id: map['profiles']['id'] as String,
      fullName: map['profiles']['full_name'] as String? ?? 'مستخدم محظور',
    );
  }
  
  @override
  List<Object?> get props => [id, fullName];
}


enum BlockedUsersStatus { initial, loading, loaded, failure }

class BlockedUsersState extends Equatable {
  final BlockedUsersStatus status;
  final List<BlockedUser> users;
  final String? errorMessage;
  
  const BlockedUsersState({
    this.status = BlockedUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  BlockedUsersState copyWith({
    BlockedUsersStatus? status,
    List<BlockedUser>? users,
    String? errorMessage,
  }) {
    return BlockedUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  List<Object?> get props => [status, users, errorMessage];
}