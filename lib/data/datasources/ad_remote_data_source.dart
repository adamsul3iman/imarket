// lib/data/datasources/ad_remote_data_source.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
// NEW: تم إزالة استيراد Ad
import 'package:imarket/domain/usecases/report_ad_usecase.dart';
import 'package:imarket/domain/usecases/submit_ad_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Custom exceptions for the data layer
class ServerException implements Exception {}

class NetworkException implements Exception {}

abstract class AdRemoteDataSource {
  Future<Map<String, dynamic>> getMarketAnalysis(String adId);
  Future<List<Map<String, dynamic>>> fetchAds({
    required String searchText,
    required Map<String, dynamic> filters,
    required int page,
  });

  Future<Set<String>> getFavoriteAdIds();
  Future<void> toggleFavoriteStatus(String adId, bool isCurrentlyFavorited);
  Future<String> getSellerName(String userId);
  Future<List<Map<String, dynamic>>> getUserAds(String userId);
  Future<void> updateAdStatus(String adId, String status);
  Future<void> deleteAd(String adId);
  Future<List<Map<String, dynamic>>> getFavoriteAds();
  Future<void> deleteFavorites(Set<String> adIds);
  Future<void> incrementViewCount(String adId);
  Future<void> reportAd(ReportAdParams params);
  Future<void> incrementWhatsappClick(String adId);
  Future<void> incrementCallClick(String adId);
  Future<void> submitAd(SubmitAdParams params);
  Future<List<Map<String, dynamic>>> fetchAdsByModel(String model);
}

@LazySingleton(as: AdRemoteDataSource)
class AdRemoteDataSourceImpl implements AdRemoteDataSource {
  final SupabaseClient _supabase;

  AdRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<Map<String, dynamic>>> fetchAds({
    required String searchText,
    required Map<String, dynamic> filters,
    required int page,
    int pageSize = 20,
  }) async {
    try {
      final from = page * pageSize;

      // NOTE: For now, we are ignoring search and filters to solve the main loading error.
      // We are calling the database function directly.
      if (searchText.isEmpty && filters.isEmpty) {
        final result = await _supabase.rpc(
          'get_active_ads',
          params: {
            'page_size': pageSize,
            'page_offset': from,
          },
        );
        // The result of an RPC call might not need casting, but if it does:
        return (result as List<dynamic>).cast<Map<String, dynamic>>();
      }

      // This part handles searching and filtering, we leave it as is for now.
      else {
        var query = _supabase.from('ads').select().eq('status', 'active');

        if (searchText.isNotEmpty) {
          query = query.textSearch('title', searchText, config: 'english');
        }

        filters.forEach((key, value) {
          if (value != null) {
            switch (key) {
              case 'minPrice':
                query = query.gte('price', value);
                break;
              case 'maxPrice':
                query = query.lte('price', value);
                break;
              case 'model':
              case 'city':
              case 'storage':
                query = query.eq(key, value);
                break;
              case 'condition':
                query = query.eq('condition_ar', value);
                break;
              case 'color':
                query = query.eq('color_ar', value);
                break;
              case 'minBattery':
                query = query.gte('battery_health', value);
                break;
              case 'hasBox':
              case 'hasCharger':
                if (value == true) {
                  query = query.eq(key, true);
                }
                break;
            }
          }
        });

        final data = await query
            .range(from, from + pageSize - 1)
            .order('is_featured', ascending: false)
            .order('created_at', ascending: false);

        return data;
      }
    } catch (e) {
      // It's helpful to print the error to see more details in the console
      print('Error fetching ads: $e');
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
      return response.map((fav) => fav['ad_id'].toString()).toSet();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> toggleFavoriteStatus(
      String adId, bool isCurrentlyFavorited) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw ServerException();
    }
    try {
      if (isCurrentlyFavorited) {
        await _supabase
            .from('favorites')
            .delete()
            .match({'user_id': user.id, 'ad_id': adId});
      } else {
        await _supabase
            .from('favorites')
            .insert({'user_id': user.id, 'ad_id': adId});
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<String> getSellerName(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .single();
      return data['full_name'] as String? ?? 'بائع';
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserAds(String userId) async {
    try {
      final data = await _supabase
          .from('ads')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return data;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> updateAdStatus(String adId, String newStatus) async {
    try {
      await _supabase.from('ads').update({'status': newStatus}).eq('id', adId);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAd(String adId) async {
    try {
      await _supabase.from('ads').delete().eq('id', adId);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFavoriteAds() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final favoritesResponse = await _supabase
          .from('favorites')
          .select('ad_id')
          .eq('user_id', userId);
      final adIds = favoritesResponse.map((f) => f['ad_id'] as String).toList();
      if (adIds.isEmpty) return [];

      final adsResponse =
          await _supabase.from('ads').select().filter('id', 'in', adIds);
      return adsResponse; // FIX: تم إزالة 'as List<Map<String, dynamic>>'
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteFavorites(Set<String> adIds) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw ServerException();
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .filter('ad_id', 'in', adIds.toList());
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> incrementViewCount(String adId) async {
    try {
      await _supabase
          .rpc('increment_view_count', params: {'ad_id_input': adId});
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  @override
  Future<void> incrementWhatsappClick(String adId) async {
    try {
      await _supabase
          .rpc('increment_whatsapp_clicks', params: {'ad_id_input': adId});
    } catch (e) {
      debugPrint('Error incrementing whatsapp clicks: $e');
    }
  }

  @override
  Future<void> incrementCallClick(String adId) async {
    try {
      await _supabase
          .rpc('increment_call_clicks', params: {'ad_id_input': adId});
    } catch (e) {
      debugPrint('Error incrementing call clicks: $e');
    }
  }

  @override
  Future<void> reportAd(ReportAdParams params) async {
    final reporterId = _supabase.auth.currentUser?.id;
    if (reporterId == null) {
      throw ServerException();
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

  @override
  Future<void> submitAd(SubmitAdParams params) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final List<String> imageUrls = [];

      for (final imageFile in params.images) {
        final imageId = const Uuid().v4();
        final imagePath = '$userId/$imageId.jpg';

        if (kIsWeb) {
          await _supabase.storage.from('ad_images').uploadBinary(
                imagePath,
                await imageFile.readAsBytes(),
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        } else {
          await _supabase.storage.from('ad_images').upload(
                imagePath,
                File(imageFile.path),
                fileOptions: const FileOptions(contentType: 'image/jpeg'),
              );
        }
        imageUrls
            .add(_supabase.storage.from('ad_images').getPublicUrl(imagePath));
      }

      final adData = {
        'user_id': userId,
        'title': '${params.model} - ${params.storage} GB',
        'price': int.parse(params.price),
        'phone_number': '+962${params.phoneNumber}',
        'description': params.description,
        'image_urls': imageUrls,
        'model': params.model,
        'storage': params.storage,
        'color_ar': params.color,
        'condition_ar': params.condition,
        'city': params.city,
        'is_repaired': params.isRepaired,
        'repaired_parts': params.isRepaired ? params.repairedParts : null,
        'battery_health':
            params.batteryHealth != null && params.batteryHealth!.isNotEmpty
                ? int.parse(params.batteryHealth!)
                : null,
        'has_box': params.hasBox,
        'has_charger': params.hasCharger,
      };

      await _supabase.from('ads').insert(adData);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAdsByModel(String model) async {
    try {
      final response = await _supabase.from('ads').select().eq('model', model);
      return response;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> getMarketAnalysis(String adId) async {
    try {
      final result = await _supabase.rpc(
        'get_market_analysis',
        params: {'p_ad_id': adId},
      );
      return result as Map<String, dynamic>;
    } catch (e) {
      throw ServerException();
    }
  }
}
