// lib/models/review_model.dart

/// Represents a single review left by a user for a seller.
class Review {
  final String reviewerName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  /// Factory constructor to create a Review instance from a map (e.g., from Supabase).
  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      // Safely access nested profile data for the reviewer's name
      reviewerName: map['profiles']?['full_name'] as String? ?? 'مستخدم',
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}