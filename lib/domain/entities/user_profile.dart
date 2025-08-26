// lib/domain/entities/user_profile.dart
import 'package:equatable/equatable.dart';

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