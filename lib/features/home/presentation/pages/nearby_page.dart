import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/custom_header_bar.dart';

class NearbyPage extends HookConsumerWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          CustomHeaderBar(
            title: '내 주변',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.spacingM),
              child: Column(
                children: [
                  _buildLocationInfo(),
                  SizedBox(height: AppSizes.gapL),
                  _buildCategoryFilter(),
                  SizedBox(height: AppSizes.gapL),
                  Expanded(child: _buildNearbyPlaces()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
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
            padding: EdgeInsets.all(AppSizes.gapS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: Icon(
              Icons.location_on,
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
                  '현재 위치',
                  style: AppTextStyles.caption.copyWith(color: Color(0xFF666666)),
                ),
                Text(
                  '서울특별시 강남구',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('변경', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['전체', '도서관', '카페', '공원', '미술관', '박물관'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: AppSizes.gapS),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: isSelected ? AppColors.primary : Color(0xFFE5E5E5),
              ),
            ),
            child: Center(
              child: Text(
                categories[index],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.white : Color(0xFF666666),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapM),
      itemBuilder: (context, index) {
        return _buildPlaceCard(index);
      },
    );
  }

  Widget _buildPlaceCard(int index) {
    final places = ['강남 중앙도서관', '조용한 북카페', '올림픽공원', '국립현대미술관', '서울숲'];
    final distances = ['0.3km', '0.5km', '0.8km', '1.2km', '1.5km'];

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
                  places[index],
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSizes.gapXS),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF666666)),
                    SizedBox(width: 4),
                    Text(
                      distances[index],
                      style: AppTextStyles.caption.copyWith(color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
