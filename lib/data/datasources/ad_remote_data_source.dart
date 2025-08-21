// lib/data/datasources/ad_remote_data_source.dart
import 'package:flutter/foundation.dart'; // FIX: Added missing import
import 'package:imarket/domain/entities/ad.dart';
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🔹 Exceptions خاصة بالـ DataSource
class ServerException implements Exception {}
class NetworkException implements Exception {}

abstract class AdRemoteDataSource {
  Future<List<Ad>> fetchAds({
    String searchText,
    Map<String, dynamic> filters,
    int page,
  });

  Future<Set<String>> getFavoriteAdIds();
  Future<void> toggleFavoriteStatus(String adId, bool isCurrentlyFavorited);
  Future<String> getSellerName(String userId);
  Future<List<Ad>> getFavoriteAds();
  Future<void> deleteFavorites(Set<String> adIds);

  Future<List<Ad>> getUserAds(String userId);
  Future<void> updateAdStatus(String adId, String newStatus);
  Future<void> deleteAd(String adId);
  Future<void> createAd(Ad ad);
  Future<void> updateAd(Ad ad);
  Future<Ad> getAdById(String adId);
  Future<void> incrementViewCount(String adId);
  Future<void> reportAd(ReportAdParams params);
  Future<void> incrementWhatsappClick(String adId);
  Future<void> incrementCallClick(String adId);
}

@LazySingleton(as: AdRemoteDataSource)
class AdRemoteDataSourceImpl implements AdRemoteDataSource {
  final SupabaseClient _supabase;

  AdRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<Ad>> fetchAds({
    String searchText = '',
    Map<String, dynamic> filters = const {},
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      var query = _supabase.from('ads').select().eq('status', 'active');

      if (searchText.isNotEmpty) {
        query = query.ilike('title', '%$searchText%');
      }

      filters.forEach((key, value) {
        if (value != null) query = query.eq(key, value);
      });

      final data = await query
          .range(from, to)
          .order('is_featured', ascending: false)
          .order('created_at', ascending: false);

      return (data as List).map((item) => Ad.fromMap(item)).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<Set<String>> getFavoriteAdIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};
    try {
      final response = await _supabase
          .from('favorites')
          .select('ad_id')
          .eq('user_id', user.id);
      return (response as List).map((fav) => fav['ad_id'].toString()).toSet();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> toggleFavoriteStatus(String adId, bool isCurrentlyFavorited) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw ServerException();

    try {
      if (isCurrentlyFavorited) {
        await _supabase.from('favorites').delete().match({
          'user_id': user.id,
          'ad_id': adId,
        });
      } else {
        await _supabase.from('favorites').insert({
          'user_id': user.id,
          'ad_id': adId,
        });
      }
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<String> getSellerName(String userId) async {
    try {
      final data =
          await _supabase.from('profiles').select('full_name').eq('id', userId).single();
      return data['full_name'] as String? ?? 'بائع';
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<List<Ad>> getFavoriteAds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final favResponse =
          await _supabase.from('favorites').select('ad_id').eq('user_id', userId);
      final adIds = (favResponse as List).map((f) => f['ad_id'] as String).toList();
      if (adIds.isEmpty) return [];

      final adsResponse = await _supabase.from('ads').select().filter('id', 'in', adIds);
      return (adsResponse as List).map((ad) => Ad.fromMap(ad)).toList();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteFavorites(Set<String> adIds) async {
    try {
      await _supabase.from('favorites').delete().filter('ad_id', 'in', adIds.toList());
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<List<Ad>> getUserAds(String userId) async {
    try {
      final data = await _supabase.from('ads').select().eq('user_id', userId);
      return (data as List).map((ad) => Ad.fromMap(ad)).toList();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateAdStatus(String adId, String newStatus) async {
    try {
      await _supabase.from('ads').update({'status': newStatus}).eq('id', adId);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAd(String adId) async {
    try {
      await _supabase.from('ads').delete().eq('id', adId);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> createAd(Ad ad) async {
    try {
      await _supabase.from('ads').insert(ad.toMap());
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateAd(Ad ad) async {
    try {
      await _supabase.from('ads').update(ad.toMap()).eq('id', ad.id);
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<Ad> getAdById(String adId) async {
    try {
      final data = await _supabase.from('ads').select().eq('id', adId).single();
      return Ad.fromMap(data);
    } catch (_) {
      throw ServerException();
    }
  }

@override
  Future<void> incrementViewCount(String adId) async {
    try {
      await _supabase.rpc('increment_view_count', params: {'ad_id_input': adId});
    } catch (e) {
      // Don't throw an exception for this, as it's not critical if it fails
      debugPrint('Error incrementing view count: $e');
    }
  }

  @override
  Future<void> incrementWhatsappClick(String adId) async {
    try {
      await _supabase.rpc('increment_whatsapp_clicks', params: {'ad_id_input': adId});
    } catch (e) {
      debugPrint('Error incrementing whatsapp clicks: $e');
    }
  }
  
  @override
  Future<void> incrementCallClick(String adId) async {
     try {
      await _supabase.rpc('increment_call_clicks', params: {'ad_id_input': adId});
    } catch (e) {
      debugPrint('Error incrementing call clicks: $e');
    }
  }

@override
  Future<void> reportAd(ReportAdParams params) async {
    final reporterId = _supabase.auth.currentUser?.id;
    if (reporterId == null) {
      throw ServerException(); // Or a more specific AuthException
    }
    try {
      await _supabase.from('reports').insert({
        'reporter_id': reporterId,
        'reported_ad_id': params.adId,
        'reported_user_id': params.userId,
        'reason': params.reason,
        'comments': params.comments,
      });
    } catch (e) {
      throw ServerException();
    }
  }
}
