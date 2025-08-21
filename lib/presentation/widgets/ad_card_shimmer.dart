import 'package:flutter/material.dart';

/// A widget that displays a shimmer loading placeholder with the same layout as an AdCard.
class AdCardShimmer extends StatelessWidget {
  const AdCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Placeholder
          Expanded(
            child: Container(
              color: Colors.white, // The shimmer effect will be applied on this color
            ),
          ),
          // Text Placeholders
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3, // 30% of screen width
                  height: 12.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 8.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                  height: 12.0,
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}