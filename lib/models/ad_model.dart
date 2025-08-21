/// File: lib/models/ad_model.dart
///
/// This file defines the data structure for an advertisement (Ad).
/// It includes properties for all ad details and methods for serialization
/// and deserialization to/from a Map, which is essential for interacting
/// with the Supabase backend.
library;

class AdModel {
  /// The unique identifier for the ad (UUID).
  final String id;

  /// The timestamp when the ad was created.
  final DateTime createdAt;

  /// The title of the ad.
  final String title;

  /// The price of the item.
  final int price;

  /// The seller's phone number.
  final String? phoneNumber;

  /// A detailed description of the item.
  final String? description;

  /// A list of URLs for the ad's images.
  final List<String> imageUrls;

  /// The specific iPhone model.
  final String model;

  /// The storage capacity in GB.
  final int storage;

  /// The color of the device in Arabic.
  final String? colorAr;

  /// The condition of the device in Arabic.
  final String? conditionAr;

  /// The city where the item is located.
  final String? city;

  /// A flag indicating if the device has been repaired.
  final bool? isRepaired;

  /// A description of any repaired parts.
  final String? repairedParts;

  /// The battery health percentage.
  final int? batteryHealth;

  /// A flag indicating if the original box is included.
  final bool? hasBox;

  /// A flag indicating if the original charger is included.
  final bool? hasCharger;

  /// The ID of the user who posted the ad.
  final String userId;

  /// The total number of times the ad has been viewed.
  final int viewCount;

  /// A flag indicating if the ad is currently featured.
  final bool isFeatured;

  /// The timestamp until which the ad is featured.
  final DateTime? featuredUntil;

  /// The total number of clicks on the WhatsApp button.
  final int whatsappClicks;

  /// The total number of clicks on the call button.
  final int callClicks;

  /// The last time the ad was "bumped" to the top of the list.
  final DateTime? bumpedAt;

  final String status;

  AdModel({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.price,
    this.phoneNumber,
    this.description,
    required this.imageUrls,
    required this.model,
    required this.storage,
    this.colorAr,
    this.conditionAr,
    this.city,
    this.isRepaired,
    this.repairedParts,
    this.batteryHealth,
    this.hasBox,
    this.hasCharger,
    required this.userId,
    required this.viewCount,
    required this.isFeatured,
    this.featuredUntil,
    required this.whatsappClicks,
    required this.callClicks,
    this.bumpedAt,
    required this.status,
  });

  /// Creates an [AdModel] instance from a map (e.g., from a Supabase query).
  ///
  /// This factory constructor safely handles type casting and default values
  /// for nullable fields to prevent runtime errors.
  factory AdModel.fromMap(Map<String, dynamic> map) {
    return AdModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      title: map['title'] as String? ?? 'بدون عنوان',
      price: (map['price'] as num?)?.toInt() ?? 0,
      phoneNumber: map['phone_number'] as String?,
      description: map['description'] as String?,
      imageUrls: List<String>.from(map['image_urls'] ?? []),
      model: map['model'] as String? ?? 'غير محدد',
      storage: (map['storage'] as num?)?.toInt() ?? 0,
      colorAr: map['color_ar'] as String?,
      conditionAr: map['condition_ar'] as String?,
      city: map['city'] as String?,
      isRepaired: map['is_repaired'] as bool?,
      repairedParts: map['repaired_parts'] as String?,
      batteryHealth: (map['battery_health'] as num?)?.toInt(),
      hasBox: map['has_box'] as bool?,
      hasCharger: map['has_charger'] as bool?,
      userId: map['user_id'] as String,
      viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
      isFeatured: map['is_featured'] as bool? ?? false,
      featuredUntil: map['featured_until'] != null
          ? DateTime.tryParse(map['featured_until'] as String)
          : null,
      whatsappClicks: (map['whatsapp_clicks'] as num?)?.toInt() ?? 0,
      callClicks: (map['call_clicks'] as num?)?.toInt() ?? 0,
      bumpedAt: map['bumped_at'] != null
          ? DateTime.tryParse(map['bumped_at'] as String)
          : null,
      // <<< التحسين: قراءة الحالة من قاعدة البيانات
      status: map['status'] as String? ?? 'active',
    );
  }

  /// Converts an [AdModel] instance to a map.
  /// Useful for inserting or updating data in Supabase.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'phone_number': phoneNumber,
      'description': description,
      'image_urls': imageUrls,
      'model': model,
      'storage': storage,
      'color_ar': colorAr,
      'condition_ar': conditionAr,
      'city': city,
      'is_repaired': isRepaired,
      'repaired_parts': repairedParts,
      'battery_health': batteryHealth,
      'has_box': hasBox,
      'has_charger': hasCharger,
      'user_id': userId,
      // لا نرسل الحالة هنا عادةً لأن تحديثها يتم بعملية منفصلة
    };
  }
}
