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
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Stack(
            children: [
              // 배경 이미지
              Positioned(
                right: -20,
                bottom: -10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: Image.asset(
                    'assets/images/tour.png',
                    height: 140,
                    width: 140,
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.8),
                  ),
                ),
              ),

              // 콘텐츠
              Padding(
                padding: EdgeInsets.all(AppSizes.gapL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 제목
                    Text(
                      'AI 맞춤 추천',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: AppSizes.gapS),

                    // 설명
                    SizedBox(
                      width: 180,
                      child: Text(
                        '당신만을 위한 특별한\n여행지를 찾아보세요',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.95),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
