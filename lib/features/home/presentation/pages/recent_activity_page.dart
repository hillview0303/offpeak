import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/custom_header_bar.dart';

class RecentActivityPage extends HookConsumerWidget {
  const RecentActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          CustomHeaderBar(
            title: '최근 활동',
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(AppSizes.spacingM),
              children: [
                _buildTodaySection(),
                SizedBox(height: AppSizes.gapL),
                _buildYesterdaySection(),
                SizedBox(height: AppSizes.gapL),
                _buildThisWeekSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘',
          style: AppTextStyles.labelBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: AppSizes.gapM),
        _buildActivityCard(
          icon: Icons.search,
          title: '한옥마을 검색',
          subtitle: '여행지 검색',
          time: '2시간 전',
          color: Colors.blue,
        ),
        SizedBox(height: AppSizes.gapS),
        _buildActivityCard(
          icon: Icons.favorite,
          title: '경복궁 찜하기',
          subtitle: '찜한 장소에 추가',
          time: '3시간 전',
          color: Colors.pink,
        ),
      ],
    );
  }

  Widget _buildYesterdaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '어제',
          style: AppTextStyles.labelBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: AppSizes.gapM),
        _buildActivityCard(
          icon: Icons.auto_awesome,
          title: 'AI 추천 받기',
          subtitle: '맞춤 여행지 추천',
          time: '어제 오후 3시',
          color: AppColors.primary,
        ),
        SizedBox(height: AppSizes.gapS),
        _buildActivityCard(
          icon: Icons.location_on,
          title: '내 주변 탐색',
          subtitle: '주변 장소 검색',
          time: '어제 오전 10시',
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildThisWeekSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 주',
          style: AppTextStyles.labelBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: AppSizes.gapM),
        _buildActivityCard(
          icon: Icons.chat,
          title: 'AI 챗봇 대화',
          subtitle: '여행 상담',
          time: '3일 전',
          color: Colors.green,
        ),
        SizedBox(height: AppSizes.gapS),
        _buildActivityCard(
          icon: Icons.bookmark,
          title: '조용한 카페 저장',
          subtitle: '찜한 장소에 추가',
          time: '5일 전',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppSizes.iconM,
            ),
          ),
          SizedBox(width: AppSizes.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSizes.gapXS),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTextStyles.caption.copyWith(color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}
