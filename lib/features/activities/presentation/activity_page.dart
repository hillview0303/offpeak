import 'package:flutter/material.dart';

import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '내 활동',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        actions: [
          IconButton(
            onPressed: () {
              // 필터 기능
            },
            icon: Icon(
              Icons.filter_list,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.tabActive,
          unselectedLabelStyle: AppTextStyles.tabInactive,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '최근 활동'),
            Tab(text: '찜한 장소'),
            Tab(text: '내 리뷰'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentActivityTab(),
          _buildFavoriteTab(),
          _buildReviewTab(),
        ],
      ),
    );
  }

  Widget _buildRecentActivityTab() {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.gapM),
      itemCount: 10,
      separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapM),
      itemBuilder: (context, index) {
        return _buildActivityCard(
          title: '부산 해운대 해변 방문',
          subtitle: '부산광역시 해운대구',
          date: '2024.06.${15 - index}',
          type: ActivityType.visit,
          imageUrl: null,
        );
      },
    );
  }

  Widget _buildFavoriteTab() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSizes.gapM),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.gapM,
        mainAxisSpacing: AppSizes.gapM,
        childAspectRatio: 0.8,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildFavoriteCard(
          title: '${index % 2 == 0 ? '해운대' : '광안리'} 해변',
          location: '부산광역시',
          rating: 4.5 + (index % 3) * 0.2,
        );
      },
    );
  }

  Widget _buildReviewTab() {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.gapM),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapM),
      itemBuilder: (context, index) {
        return _buildReviewCard(
          placeName: '해운대 해변 ${index + 1}',
          rating: 4 + index % 2,
          review: '정말 아름다운 곳이었어요! 다시 방문하고 싶습니다. 특히 일몰이 정말 장관이었습니다.',
          date: '2024.06.${10 + index}',
          images: index % 3 == 0 ? 3 : 0,
        );
      },
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String subtitle,
    required String date,
    required ActivityType type,
    String? imageUrl,
  }) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ActivityType.visit:
        iconData = Icons.place;
        iconColor = AppColors.primary;
        break;
      case ActivityType.favorite:
        iconData = Icons.favorite;
        iconColor = AppColors.error;
        break;
      case ActivityType.review:
        iconData = Icons.rate_review;
        iconColor = AppColors.secondary;
        break;
    }

    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: () {
          // 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.gapM),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: EdgeInsets.all(AppSizes.gapS),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: AppSizes.iconM,
                ),
              ),
              SizedBox(width: AppSizes.gapM),

              // 텍스트 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      date,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),

              // 화살표 아이콘
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: AppSizes.iconS,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard({
    required String title,
    required String location,
    required double rating,
  }) {
    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: () {
          // 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusM),
                ),
              ),
              child: Icon(
                Icons.image,
                color: AppColors.primary,
                size: AppSizes.iconXL,
              ),
            ),

            // 텍스트 정보
            Padding(
              padding: EdgeInsets.all(AppSizes.gapM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.gapXS),
                  Text(
                    location,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.gapS),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: AppSizes.iconS,
                      ),
                      SizedBox(width: AppSizes.gapXS),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: AppTextStyles.medium,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.favorite,
                        color: AppColors.error,
                        size: AppSizes.iconS,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String placeName,
    required int rating,
    required String review,
    required String date,
    required int images,
  }) {
    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: () {
          // 리뷰 상세 보기
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.gapM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (장소명, 별점)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      placeName,
                      style: AppTextStyles.labelBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: AppSizes.iconS,
                      );
                    }),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.gapS),

              // 리뷰 내용
              Text(
                review,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSizes.gapS),

              // 하단 정보 (날짜, 이미지 개수)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date,
                    style: AppTextStyles.caption,
                  ),
                  if (images > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.photo,
                          color: AppColors.textSecondary,
                          size: AppSizes.iconS,
                        ),
                        SizedBox(width: AppSizes.gapXS),
                        Text(
                          '$images장',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

enum ActivityType {
  visit,
  favorite,
  review,
}
