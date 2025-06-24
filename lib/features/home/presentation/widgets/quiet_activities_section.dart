import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/utils/quiet_activities_utils.dart';
import '../../../../core/router/router.dart';

class QuietActivitiesSection extends StatelessWidget {
  const QuietActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(QuietActivitiesUtils.activityCount, (index) {
                final activity = QuietActivitiesUtils.getActivityData(index);

                return Container(
                  margin: EdgeInsets.only(
                    right: index < QuietActivitiesUtils.activityCount - 1 ? AppSizes.gapM : 0,
                    bottom: 16, // 그림자를 위한 하단 여백
                  ),
                  child: _buildActivityCard(
                    context: context,
                    activity: activity,
                    onTap: () {
                      // GoRouter를 사용한 상세페이지 이동
                      context.push(RoutePaths.quietActivitiesDetail, extra: {
                        'categoryTitle': activity.title,
                        'categoryType': activity.subtitle.toLowerCase(),
                        'categoryGradient': activity.gradient,
                        'categoryIcon': activity.icon,
                      });
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required QuietActivityData activity,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 180,
      height: 200,
      child: Card(
        elevation: AppSizes.elevationM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Container(
            decoration: BoxDecoration(
              gradient: activity.gradient,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Stack(
              children: [
                // 기존 이미지 자리에 아이콘
                Positioned(
                  right: -10,
                  top: 20,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Icon(
                      activity.icon,
                      size: 50, // 큰 아이콘 크기
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                ),

                // 콘텐츠
                Padding(
                  padding: EdgeInsets.all(AppSizes.gapL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 카테고리
                      Text(
                        activity.subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: AppSizes.gapXS),

                      // 제목
                      Text(
                        activity.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
