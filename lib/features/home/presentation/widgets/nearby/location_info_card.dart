import 'package:flutter/material.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import 'category_filter.dart';

class LocationInfoCard extends StatelessWidget {
  final String currentAddress;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final Function(String) onCategoryChanged;
  final String selectedCategory;

  const LocationInfoCard({
    super.key,
    required this.currentAddress,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.onRefresh,
    required this.onCategoryChanged,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLocationInfo(),
        SizedBox(height: AppSizes.gapL),
        CategoryFilter(
          onCategoryChanged: onCategoryChanged,
          selectedCategory: selectedCategory,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSizes.gapXS),
                if (hasError) ...[
                  Text(
                    '위치 오류',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ] else if (isLoading) ...[
                  Text(
                    '현재 위치를 찾는 중입니다...',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  Text(
                    currentAddress,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 수정된 새로고침 버튼
          GestureDetector(
            onTap: isLoading ? null : onRefresh, // 로딩 중이 아닐 때만 작동
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(AppSizes.gapS),
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.greyLight
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: isLoading
                      ? AppColors.grey.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? Icon(
                  key: const ValueKey('disabled'),
                  Icons.refresh,
                  color: AppColors.grey,
                  size: AppSizes.iconS,
                )
                    : Icon(
                  key: const ValueKey('refresh'),
                  Icons.refresh,
                  color: AppColors.primary,
                  size: AppSizes.iconS,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
