// lib/presentation/widgets/ad_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:imarket/domain/entities/ad.dart'; // FIX: Changed from AdModel to Ad
import 'package:intl/intl.dart';

class AdCard extends StatelessWidget {
  final Ad ad; // FIX: Changed from AdModel to Ad
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorited;
  final String heroTagPrefix;

  const AdCard({
    super.key,
    required this.ad,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorited,
    required this.heroTagPrefix,
  });
  @override
  Widget build(BuildContext context) {
    final uniqueHeroTag =
        '$heroTagPrefix-${ad.imageUrls.isNotEmpty ? ad.imageUrls[0] : ad.id}';
    final bool isCurrentlyFeatured =
        ad.isFeatured && (ad.featuredUntil?.isAfter(DateTime.now()) ?? false);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- ويدجت Hero مسؤول عن الأنيميشن ---
                  // يجب أن يكون له "tag" فريد ومتطابق بين الشاشتين.
                  // سنستخدم رابط أول صورة مع البادئة التي تم تمريرها.
                  Hero(
                    tag: uniqueHeroTag, // Tag الفريد الذي أنشأناه في الأعلى
                    child: ClipRRect(
                      // استخدام ClipRRect لمنح الصورة حواف دائرية
                      borderRadius: BorderRadius.circular(
                          0), // يمكنك تغيير هذا إذا أردت حواف دائرية للصور
                      child: CachedNetworkImage(
                        imageUrl: ad.imageUrls.isNotEmpty
                            ? ad.imageUrls[0]
                            : '', // نعرض أول صورة
                        fit: BoxFit.cover,
                        // صورة مؤقتة أثناء التحميل
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade200),
                        // أيقونة في حال حدوث خطأ في تحميل الصورة
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_outlined,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // --- زر المفضلة ---
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        onTap: onFavoriteToggle,
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                isFavorited ? Colors.redAccent : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- شريحة "إعلان مميز" ---
                  // --- شريحة "إعلان مميز" (إذا كان الإعلان مميزًا) ---
                  if (isCurrentlyFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Chip(
                        label: const Text('مميز'),
                        backgroundColor: Colors.amber.shade700,
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),

            // --- قسم التفاصيل المحدث ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- عنوان الإعلان ---
                  Text(
                    ad.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // --- صف الحالة والسعر ---
                  // --- صف الحالة والسعر ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // <<<
                      // <<< تم الإصلاح هنا
                      // <<<
                      Expanded(
                        // <-- تم إضافة هذا الـ Widget
                        child: Text(
                          ad.conditionAr ?? 'غير محدد',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow
                              .ellipsis, // لإضافة "..." في حال كان النص طويلاً
                        ),
                      ),
                      // --- سعر الإعلان ---
                      Text(
                        '${ad.price} دينار',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // --- تاريخ النشر ---
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMd('ar').format(ad.createdAt),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
