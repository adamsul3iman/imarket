import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/entities/seller_profile_data.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SellerProfileRemoteDataSource {
  Future<SellerProfileData> getSellerProfileData(String sellerId);
}

@LazySingleton(as: SellerProfileRemoteDataSource)
class SellerProfileRemoteDataSourceImpl
    implements SellerProfileRemoteDataSource {
  final SupabaseClient _supabase;

  SellerProfileRemoteDataSourceImpl(this._supabase);

  @override
  Future<SellerProfileData> getSellerProfileData(String sellerId) async {
    try {
      // ✅ FIX: Renamed 'phone_number' to 'phone_number:phone'
      // This tells Supabase: "get the column named 'phone', but send it back to the app with the key 'phone_number'".
      final response = await _supabase.from('profiles').select('''
            phone_number:phone, 
            rating,
            ads:ads!user_id(*),
            reviews:reviews!seller_id(*, reviewer:profiles!reviewer_id(full_name))
          ''').eq('id', sellerId).single();

      final adList =
          (response['ads'] as List).map((data) => Ad.fromMap(data)).toList();

      final reviewList = (response['reviews'] as List)
          .map((data) => ReviewEntity.fromMap(data))
          .toList();

      final averageRating = (response['rating'] as num?)?.toDouble() ?? 0.0;
      final phoneNumber = response['phone_number'] as String?;

      return SellerProfileData(
        ads: adList,
        reviews: reviewList,
        averageRating: averageRating,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      print("Error fetching seller profile: $e");
      throw Exception('Server Exception');
    }
  }
}
