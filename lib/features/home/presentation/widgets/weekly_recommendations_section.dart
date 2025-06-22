import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class WeeklyRecommendationsSection extends StatelessWidget {
  const WeeklyRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 추천 여행지',
            style: AppTextStyles.h3.copyWith(
                fontSize: 15
            ),
          ),
          SizedBox(height: AppSizes.gapM),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                return Container(
                  margin: EdgeInsets.only(
                    right: index < 6 ? AppSizes.gapM : 0,
                    bottom: 12, // 그림자를 위한 하단 여백
                  ),
                  child: _buildWeeklyRecommendationItem(
                    day: _getDayName(index),
                    title: _getLocationTitle(index),
                    subtitle: _getLocationSubtitle(index),
                    icon: _getLocationIcon(index),
                    onTap: () {
                      // 여행지 상세 페이지로 이동
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

  Widget _buildWeeklyRecommendationItem({
    required String day,
    required String title,
    required String subtitle,
    required IconData icon,
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
                // 요일 표시
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Center(
                    child: Text(
                      day,
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
      '부산 해동용궁사',
      '전주 한옥마을',
      '담양 죽녹원',
    ];
    return titles[index % titles.length];
  }

  String _getLocationSubtitle(int index) {
    final subtitles = [
      '고요한 사찰에서 마음의 평화를 찾아보세요',
      '신비로운 용암동굴 탐험으로 특별한 경험을',
      '율곡 이이의 생가에서 역사와 문화를 느껴보세요',
      '전통 한옥마을에서 조용한 시간을 보내세요',
      '바다와 어우러진 아름다운 사찰을 만나보세요',
      '전통 한옥의 아름다움을 느낄 수 있는 곳',
      '푸른 대나무 숲길에서 힐링하는 시간을',
    ];
    return subtitles[index % subtitles.length];
  }

  // 카테고리별 아이콘 매핑 (AI 데이터 연동 시 사용)
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '사찰':
      case 'temple':
        return Icons.temple_buddhist;
      case '자연':
      case '동굴':
      case 'nature':
      case 'cave':
        return Icons.landscape;
      case '역사':
      case '문화재':
      case 'historical':
      case 'heritage':
        return Icons.account_balance;
      case '전통마을':
      case '한옥':
      case 'traditional':
      case 'hanok':
        return Icons.home_work_outlined;
      case '공원':
      case '숲':
      case 'park':
      case 'forest':
        return Icons.park_outlined;
      case '박물관':
      case 'museum':
        return Icons.museum;
      case '궁궐':
      case 'palace':
        return Icons.castle;
      case '해변':
      case '바다':
      case 'beach':
      case 'sea':
        return Icons.beach_access;
      case '산':
      case 'mountain':
        return Icons.terrain;
      case '쇼핑':
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.place;
    }
  }

  IconData _getLocationIcon(int index) {
    // 현재는 하드코딩, 추후 AI 데이터에서 category 필드를 받아서 _getCategoryIcon(category) 사용
    final categories = [
      '사찰',      // 불국사
      '자연',      // 만장굴
      '역사',      // 오죽헌
      '전통마을',   // 하회마을
      '사찰',      // 해동용궁사
      '한옥',      // 한옥마을
      '공원',      // 죽녹원
    ];
    return _getCategoryIcon(categories[index % categories.length]);
  }
}
