import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';
import '../../../core/router/navigation_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'OffPeak',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // 알림 페이지로 이동
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: AppSizes.iconM,
            ),
          ),
          IconButton(
            onPressed: () {
              // 설정 페이지로 이동
            },
            icon: Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
              size: AppSizes.iconM,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.gapM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지
              _buildWelcomeSection(),
              SizedBox(height: AppSizes.gapL),

              // 알고리즘 추천 카드
              _buildAlgorithmRecommendationCard(),
              SizedBox(height: AppSizes.gapL),

              // 빠른 액션들
              _buildQuickActions(),
              SizedBox(height: AppSizes.gapL),

              // 최근 활동
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.gapL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요! 👋',
            style: AppTextStyles.h2.copyWith(color: AppColors.white),
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '오늘도 새로운 여행을 계획해보세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmRecommendationCard() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: AppTextStyles.h3,
        ),
        SizedBox(height: AppSizes.gapM),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionItem(
                icon: Icons.search,
                title: '여행지 검색',
                onTap: () {
                  // 검색 페이지로 이동
                },
              ),
            ),
            SizedBox(width: AppSizes.gapM),
            Expanded(
              child: _buildQuickActionItem(
                icon: Icons.bookmark_outline,
                title: '찜한 장소',
                onTap: () {
                  // 찜한 장소 페이지로 이동
                },
              ),
            ),
            SizedBox(width: AppSizes.gapM),
            Expanded(
              child: _buildQuickActionItem(
                icon: Icons.location_on_outlined,
                title: '내 주변',
                onTap: () {
                  // 내 주변 페이지로 이동
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
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
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: AppSizes.iconL,
              ),
              SizedBox(height: AppSizes.gapS),
              Text(
                title,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 활동',
              style: AppTextStyles.h3,
            ),
            TextButton(
              onPressed: () {
                // 전체 활동 보기
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
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapS),
          itemBuilder: (context, index) {
            return _buildActivityItem(
              title: '부산 해운대 해변 ${index + 1}',
              subtitle: '2024.06.1${5 - index}',
              icon: Icons.place,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: AppSizes.elevationS,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: AppSizes.iconM,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: AppSizes.iconS,
        ),
        onTap: () {
          // 상세 페이지로 이동
        },
      ),
    );
  }
}
