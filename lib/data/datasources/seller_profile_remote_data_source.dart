import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SellerProfileRemoteDataSource {
  Future<SellerProfileData> getSellerProfileData(String sellerId);
}

@LazySingleton(as: SellerProfileRemoteDataSource)
class SellerProfileRemoteDataSourceImpl implements SellerProfileRemoteDataSource {
  final SupabaseClient _supabase;

  SellerProfileRemoteDataSourceImpl(this._supabase);

  @override
  Future<SellerProfileData> getSellerProfileData(String sellerId) async {
    try {
      final responses = await Future.wait([
        _supabase.from('ads').select().eq('user_id', sellerId).order('created_at', ascending: false),
        _supabase.from('reviews').select('*, profiles!reviewer_id(full_name)').eq('seller_id', sellerId).order('created_at', ascending: false),
        _supabase.from('profiles').select('rating').eq('id', sellerId).single(),
      ]);

      final adList = (responses[0] as List).map((data) => Ad.fromMap(data)).toList();
      final reviewList = (responses[1] as List).map((data) => ReviewEntity.fromMap(data)).toList();
      final ratingData = responses[2] as Map<String, dynamic>;
      final averageRating = (ratingData['rating'] as num?)?.toDouble() ?? 0.0;
      
      return SellerProfileData(
        ads: adList,
        reviews: reviewList,
        averageRating: averageRating,
      );
    } catch (e) {
      throw Exception('Server Exception');
    }
  }
}