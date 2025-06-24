import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';

class TransportationRecommendationsSection extends StatelessWidget {
  const TransportationRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: GestureDetector(
        onTap: () => NavigationService.instance.navigateTo('/home/transportation-recommendation'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.gapL, vertical: AppSizes.spacingXL),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.1),
                blurRadius: AppSizes.elevationM * 2,
                offset: Offset(0, AppSizes.elevationS),
              ),
            ],
          ),
          child: Row(
            children: [
              // 좌측 텍스트 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '교통편별 여행지',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      '걷고, 타고, 달리며 즐기는 여행',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: AppSizes.gapM),

              // 우측 이미지 영역
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: Image.asset(
                    'assets/images/todaytravel.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportationRecommendationItem({
    required BuildContext context,
    required String transportType,
    required String title,
    required String subtitle,
    required IconData icon,
    required String category,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: AppSizes.elevationM,
        margin: EdgeInsets.zero,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.gapL),
            child: Row(
              children: [
                // 교통수단 표시
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Center(
                    child: Text(
                      transportType,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.gapM),

                // 여행지 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSizes.gapXS),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppSizes.gapS),

                // 카테고리 아이콘
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
