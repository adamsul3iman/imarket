// lib/core/constants/app_constants.dart

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String adDetails = '/ad-details';
  // ... أضف بقية المسارات هنا
}

class SupabaseTables {
  static const String ads = 'ads';
  static const String profiles = 'profiles';
  static const String favorites = 'favorites';
  static const String reports = 'reports';
  // ... أضف بقية الجداول هنا
}

class HiveBoxes {
  static const String cachedAds = 'CACHED_ADS';
}