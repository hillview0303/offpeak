import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class QuietActivitiesSection extends StatelessWidget {
  const QuietActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '조용히 즐기는 여행',
            style: AppTextStyles.h3.copyWith(
                fontSize: 15
            ),
          ),
          SizedBox(height: AppSizes.gapM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < 4 ? AppSizes.gapM : 0,
                    bottom: 16, // 그림자를 위한 하단 여백
                  ),
                  child: _buildActivityCard(
                    index: index,
                    title: _getActivityTitle(index),
                    subtitle: _getActivitySubtitle(index),
                    gradient: _getActivityGradient(index),
                    onTap: () {
                      // 액티비티 상세 페이지로 이동
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
    required int index,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
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
              gradient: gradient,
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
                      _getActivityIcon(index),
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
                        subtitle,
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
                        title,
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
      'Indoor',
      'Indoor',
      'Indoor',
      'Outdoor',
      'Indoor',
    ];
    return subtitles[index % subtitles.length];
  }

  LinearGradient _getActivityGradient(int index) {
    final gradients = [
      // 차분한 올리브 그린
      LinearGradient(
        colors: [Color(0xFF8FA68E), Color(0xFFA4BAA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // 부드러운 베이지
      LinearGradient(
        colors: [Color(0xFFB8A082), Color(0xFFC8B299)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // 차분한 라벤더 그레이
      LinearGradient(
        colors: [Color(0xFF9B96A6), Color(0xFFAFA9B8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // 따뜻한 더스티 로즈
      LinearGradient(
        colors: [Color(0xFFA08A8A), Color(0xFFB39C9C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      // 은은한 세이지 그린
      LinearGradient(
        colors: [Color(0xFF8B9A8B), Color(0xFF9FAD9F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[index % gradients.length];
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
