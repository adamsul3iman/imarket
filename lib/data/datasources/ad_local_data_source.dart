import 'package:hive/hive.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:injectable/injectable.dart';

// An abstract contract for our local data source
abstract class AdLocalDataSource {
  /// Caches a list of [Ad]s to local storage.
  Future<void> cacheAds(List<Ad> adsToCache);

  /// Gets the last cached list of [Ad]s from local storage.
  Future<List<Ad>> getLastAds();
}

// FIX: Renamed to follow Dart's constant naming conventions (k for constants).
const kCachedAdsBox = 'CACHED_ADS';

@LazySingleton(as: AdLocalDataSource)
class AdLocalDataSourceImpl implements AdLocalDataSource {
  @override
  Future<void> cacheAds(List<Ad> adsToCache) async {
    if (!Hive.isAdapterRegistered(AdAdapter().typeId)) {
      Hive.registerAdapter(AdAdapter());
    }

    final box = await Hive.openBox<Ad>(kCachedAdsBox);
    await box.clear();
    await box.addAll(adsToCache);
  }

  @override
  Future<List<Ad>> getLastAds() async {
    if (!Hive.isAdapterRegistered(AdAdapter().typeId)) {
      Hive.registerAdapter(AdAdapter());
    }

    final box = await Hive.openBox<Ad>(kCachedAdsBox);
    final ads = box.values.toList();
    if (ads.isNotEmpty) {
      return ads;
    } else {
      throw Exception('Cache Error');
    }
  }
}
