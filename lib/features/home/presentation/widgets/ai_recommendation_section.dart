import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';

class AiRecommendationSection extends StatelessWidget {
  const AiRecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildAiRecommendationCard();
  }

  Widget _buildAiRecommendationCard() {
    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          NavigationService.instance.goAlgorithmRecommendation();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.gapL),
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: AppSizes.iconL,
                ),
              ),
              SizedBox(width: AppSizes.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 맞춤 추천',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      '당신만을 위한 특별한 여행지를 찾아보세요',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.white.withOpacity(0.8),
                size: AppSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}