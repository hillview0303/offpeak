import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../providers/favorite_provider.dart';

class FavoritesPage extends HookConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesCount = ref.watch(favoritesCountProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          CustomHeaderBar(
            title: '찜한 장소',
          ),
          Expanded(
            child: favoritesCount == 0
                ? _buildEmptyState(context)
                : _buildFavoritesList(ref),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSizes.gapL),
          Text(
            '아직 찜한 장소가 없어요',
            style: AppTextStyles.h4.copyWith(color: Color(0xFF666666)),
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '마음에 드는 조용한 장소를 찜해보세요',
            style: AppTextStyles.bodyMedium.copyWith(color: Color(0xFF999999)),
          ),
          SizedBox(height: AppSizes.gapXL),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.explore),
            label: Text('장소 둘러보기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.gapXL,
                vertical: AppSizes.gapM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(WidgetRef ref) {
    final favoritesCount = ref.watch(favoritesCountProvider);

    return Column(
      children: [
        _buildHeader(favoritesCount),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(AppSizes.spacingM),
            itemCount: favoritesCount,
            separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapM),
            itemBuilder: (context, index) => _buildFavoriteCard(index),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: Colors.pink, size: AppSizes.iconM),
          SizedBox(width: AppSizes.gapS),
          Text(
            '총 ${count}개의 장소를 찜했어요',
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(int index) {
    final places = ['경복궁', '북촌한옥마을', '인사동', '창덕궁', '덕수궁'];
    final descriptions = ['조용한 궁궐 산책', '전통 한옥의 아름다움', '문화거리 탐방', '비밀의 정원', '근대 건축물'];

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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.place,
              color: AppColors.primary,
              size: AppSizes.iconM,
            ),
          ),
          SizedBox(width: AppSizes.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  places[index % places.length],
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSizes.gapXS),
                Text(
                  descriptions[index % descriptions.length],
                  style: AppTextStyles.caption.copyWith(color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // 찜 해제 기능
            },
            icon: Icon(
              Icons.favorite,
              color: Colors.pink,
              size: AppSizes.iconM,
            ),
          ),
        ],
      ),
    );
  }
}
