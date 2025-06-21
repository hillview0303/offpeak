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
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.secondary,
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
                      style: AppTextStyles.h3,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      '당신만을 위한 특별한 여행지를 찾아보세요',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: AppSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
