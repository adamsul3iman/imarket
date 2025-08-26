// lib/presentation/blocs/profile/profile_state.dart
part of 'profile_bloc.dart';

// تم حذف تعريف كلاس UserProfile من هنا

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoggedOut extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;
  const ProfileLoaded({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}
class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
}