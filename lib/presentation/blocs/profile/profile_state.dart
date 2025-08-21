part of 'profile_bloc.dart';

// To hold all the combined data for the profile
class UserProfile extends Equatable {
  final String fullName;
  final String joinDate;
  final double rating;
  final int featuredCredits;
  final String planName;

  const UserProfile({
    required this.fullName,
    required this.joinDate,
    required this.rating,
    required this.featuredCredits,
    required this.planName,
  });

  @override
  List<Object> get props => [fullName, joinDate, rating, featuredCredits, planName];
}

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