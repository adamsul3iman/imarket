import 'package:hive/hive.dart';
import 'package:imarket/domain/entities/ad.dart';
import 'package:injectable/injectable.dart';

// An abstract contract for our local data source
abstract class AdLocalDataSource {
  /// Caches a list of [Ad]s to local storage.
  ///
  /// Throws a [CacheException] if saving fails.
  Future<void> cacheAds(List<Ad> adsToCache);

  /// Gets the last cached list of [Ad]s from local storage.
  ///
  /// Throws a [CacheException] if no data is found.
  Future<List<Ad>> getLastAds();
}

// A constant for our Hive box name to avoid magic strings
const CACHED_ADS = 'CACHED_ADS';

@LazySingleton(as: AdLocalDataSource)
class AdLocalDataSourceImpl implements AdLocalDataSource {
  @override
  Future<void> cacheAds(List<Ad> adsToCache) async {
    // Hive needs to know about the adapter we generated
    if (!Hive.isAdapterRegistered(AdAdapter().typeId)) {
      Hive.registerAdapter(AdAdapter());
    }
    
    final box = await Hive.openBox<Ad>(CACHED_ADS);
    await box.clear(); // Clear old data first
    await box.addAll(adsToCache); // Add the new list
  }

  @override
  Future<List<Ad>> getLastAds() async {
    if (!Hive.isAdapterRegistered(AdAdapter().typeId)) {
      Hive.registerAdapter(AdAdapter());
    }
    
    final box = await Hive.openBox<Ad>(CACHED_ADS);
    final ads = box.values.toList();
    if (ads.isNotEmpty) {
      return ads;
    } else {
      // Throw an exception if the cache is empty
      throw Exception('Cache Error');
    }
  }
}