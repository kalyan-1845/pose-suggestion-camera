import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/place_constants.dart';

/// Card widget for place/scene selection
class PlaceCard extends StatelessWidget {
  final PlaceScene place;
  final int poseCount;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.poseCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              place.gradient.colors.first.withOpacity(0.2),
              place.gradient.colors.last.withOpacity(0.08),
            ],
          ),
          border: Border.all(
            color: place.gradient.colors.first.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: place.gradient,
                ),
                child: Icon(
                  place.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              // Name + count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$poseCount poses',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
