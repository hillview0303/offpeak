import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class QuietActivitiesSection extends StatelessWidget {
  const QuietActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '조용한 액티비티 추천',
              style: AppTextStyles.h3,
            ),
            TextButton(
              onPressed: () {
                // 전체 액티비티 보기
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
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => SizedBox(width: AppSizes.gapM),
            itemBuilder: (context, index) {
              return _buildActivityCard(
                title: _getActivityTitle(index),
                subtitle: _getActivitySubtitle(index),
                icon: _getActivityIcon(index),
                onTap: () {
                  // 액티비티 상세 페이지로 이동
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: AppSizes.elevationS,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.gapM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSizes.gapS),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.secondary,
                    size: AppSizes.iconM,
                  ),
                ),
                SizedBox(height: AppSizes.gapM),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }

  String _getActivityTitle(int index) {
    final titles = [
      '도서관 투어',
      '미술관 관람',
      '조용한 카페',
      '산책로 걷기',
      '명상 공간',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      '조용히 책을 읽을 수 있는 공간',
      '예술 작품을 감상하며 힐링',
      '혼자만의 시간을 보내기 좋은 곳',
      '자연 속에서 여유로운 산책',
      '마음의 평화를 찾을 수 있는 곳',
    ];
    return subtitles[index % subtitles.length];
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.library_books,
      Icons.palette,
      Icons.coffee,
      Icons.nature_people,
      Icons.self_improvement,
    ];
    return icons[index % icons.length];
  }
}
