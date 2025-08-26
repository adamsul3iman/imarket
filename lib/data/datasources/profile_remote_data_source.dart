// lib/data/datasources/profile_remote_data_source.dart
import 'package:imarket/domain/entities/user_profile.dart'; // ✅ FIX: تم تغيير المسار
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfile> getUserProfile(String userId);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _supabase;

  ProfileRemoteDataSourceImpl(this._supabase);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final responses = await Future.wait([
        _supabase.from('profiles').select().eq('id', userId).single(),
        _supabase.from('user_wallet').select().eq('user_id', userId).single(),
        _supabase.from('user_subscriptions')
            .select('*, subscription_plans(*)')
            .eq('user_id', userId)
            .maybeSingle(),
      ]);

      final profileData = responses[0] as Map<String, dynamic>;
      final walletData = responses[1] as Map<String, dynamic>;
      final subscriptionData = responses[2]; // Can be null

      final joinDate = profileData['created_at'] != null
          ? DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(profileData['created_at'] as String))
          : 'N/A';

      final planName =
          (subscriptionData?['subscription_plans']?['name_ar'] as String?) ??
              'الخطة المجانية';

      return UserProfile(
        fullName: profileData['full_name'] as String? ?? 'لا يوجد اسم',
        joinDate: joinDate,
        rating: (profileData['rating'] as num?)?.toDouble() ?? 0.0,
        featuredCredits: walletData['featured_credits'] as int? ?? 0,
        planName: planName,
      );
    } catch (e) {
      throw Exception('Failed to fetch profile data');
    }
  }
}