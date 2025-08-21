import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'ad.g.dart'; // This line connects to the auto-generated file

@HiveType(typeId: 0) // Unique ID for this data type in Hive
class Ad extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime createdAt;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final int price;
  @HiveField(4)
  final String? phoneNumber;
  @HiveField(5)
  final String? description;
  @HiveField(6)
  final List<String> imageUrls;
  @HiveField(7)
  final String model;
  @HiveField(8)
  final int storage;
  @HiveField(9)
  final String? colorAr;
  @HiveField(10)
  final String? conditionAr;
  @HiveField(11)
  final String? city;
  @HiveField(12)
  final bool? isRepaired;
  @HiveField(13)
  final String? repairedParts;
  @HiveField(14)
  final int? batteryHealth;
  @HiveField(15)
  final bool? hasBox;
  @HiveField(16)
  final bool? hasCharger;
  @HiveField(17)
  final String userId;
  @HiveField(18)
  final int viewCount;
  @HiveField(19)
  final bool isFeatured;
  @HiveField(20)
  final DateTime? featuredUntil;
  @HiveField(21)
  final int whatsappClicks;
  @HiveField(22)
  final int callClicks;
  @HiveField(23)
  final DateTime? bumpedAt;
  @HiveField(24)
  final String status;

  const Ad({
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

  factory Ad.fromMap(Map<String, dynamic> map) {
    return Ad(
      id: map['id'] as String? ?? 'invalid_id',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      userId: map['user_id'] as String? ?? 'unknown_user',
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
      viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
      isFeatured: map['is_featured'] as bool? ?? false,
      featuredUntil: map['featured_until'] != null
          ? DateTime.tryParse(map['featured_until'].toString())
          : null,
      whatsappClicks: (map['whatsapp_clicks'] as num?)?.toInt() ?? 0,
      callClicks: (map['call_clicks'] as num?)?.toInt() ?? 0,
      bumpedAt: map['bumped_at'] != null
          ? DateTime.tryParse(map['bumped_at'].toString())
          : null,
      status: map['status'] as String? ?? 'active',
    );
  }

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
    };
  }
  
  @override
  List<Object?> get props => [id, createdAt, title, price, phoneNumber, description, imageUrls, model, storage, colorAr, conditionAr, city, isRepaired, repairedParts, batteryHealth, hasBox, hasCharger, userId, viewCount, isFeatured, featuredUntil, whatsappClicks, callClicks, bumpedAt, status];
}