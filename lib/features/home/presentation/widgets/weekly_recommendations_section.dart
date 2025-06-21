import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class WeeklyRecommendationsSection extends StatelessWidget {
  const WeeklyRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '요일별 조용한 여행지',
              style: AppTextStyles.h3,
            ),
            TextButton(
              onPressed: () {
                // 전체 요일별 추천 보기
              },
              child: Text(
                '전체보기',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.gapM),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapS),
          itemBuilder: (context, index) {
            return _buildWeeklyRecommendationItem(
              day: _getDayName(index),
              title: _getLocationTitle(index),
              subtitle: _getLocationSubtitle(index),
              imageUrl: _getLocationImage(index),
              onTap: () {
                // 여행지 상세 페이지로 이동
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyRecommendationItem({
    required String day,
    required String title,
    required String subtitle,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: AppSizes.elevationS,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.gapM),
          child: Row(
            children: [
              // 요일 표시
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSizes.gapM),

              // 여행지 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 이미지 플레이스홀더
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.image,
                  color: AppColors.textSecondary.withOpacity(0.5),
                  size: AppSizes.iconM,
                ),
              ),

              SizedBox(width: AppSizes.gapS),
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

  String _getDayName(int index) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[index % days.length];
  }

  String _getLocationTitle(int index) {
    final titles = [
      '경주 불국사',
      '제주 만장굴',
      '강릉 오죽헌',
      '안동 하회마을',
    ];
    return titles[index % titles.length];
  }

  String _getLocationSubtitle(int index) {
    final subtitles = [
      '고요한 사찰에서 마음의 평화를 찾아보세요',
      '신비로운 용암동굴 탐험으로 특별한 경험을',
      '율곡 이이의 생가에서 역사와 문화를 느껴보세요',
      '전통 한옥마을에서 조용한 시간을 보내세요',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getLocationImage(int index) {
    // 실제 구현에서는 이미지 URL을 반환
    return 'placeholder_image_$index.jpg';
  }
}
