import 'package:equatable/equatable.dart';
import 'package:imarket/domain/entities/ad.dart';


// We are moving the Review model to the domain layer as an entity
class ReviewEntity extends Equatable {
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewEntity.fromMap(Map<String, dynamic> map) {
    return ReviewEntity(
      reviewerName: map['profiles']?['full_name'] as String? ?? 'مستخدم',
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
  
  @override
  List<Object?> get props => [reviewerName, rating, comment, createdAt];
}


class SellerProfileData extends Equatable {
  final List<Ad> ads;
  final List<ReviewEntity> reviews;
  final double averageRating;

  const SellerProfileData({
    required this.ads,
    required this.reviews,
    required this.averageRating,
  });

  @override
  List<Object?> get props => [ads, reviews, averageRating];
}