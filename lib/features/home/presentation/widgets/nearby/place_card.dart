import 'package:flutter/material.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/utils/category_utils.dart';

class PlaceCard extends StatelessWidget {
  final String name;
  final String address;
  final String distance;
  final String category;
  final bool isOpen;
  final String? description;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.name,
    required this.address,
    required this.distance,
    required this.category,
    required this.isOpen,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSizes.gapL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildPlaceInfo(),
      ),
    );
  }

  Widget _buildPlaceInfo() {
    final categoryColors = CategoryUtils.getCategoryColors(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 태그
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.gapS,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: categoryColors['tag'],
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CategoryUtils.getCategoryEmoji(category),
                style: TextStyle(fontSize: 10),
              ),
              SizedBox(width: 3),
              Text(
                CategoryUtils.getCategoryDisplayText(category),
                style: AppTextStyles.caption.copyWith(
                  color: categoryColors['tagText'],
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.gapXS),

        // 장소명
        Text(
          name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          softWrap: true,
        ),
        SizedBox(height: AppSizes.gapM),

        // 주소
        if (address.isNotEmpty && address != '주소 정보 없음') ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, 1), // y축으로 1px 아래로 이동
                  child: Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.gapXS),
        ],

        // 거리
        if (distance.isNotEmpty && distance != '거리 정보 없음') ...[
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4),
              Text(
                distance,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
