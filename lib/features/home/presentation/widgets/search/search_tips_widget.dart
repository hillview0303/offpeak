import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';

class SearchTipsWidget extends HookConsumerWidget {
  final List<String>? customTips;
  final String? title;
  final IconData? icon;

  const SearchTipsWidget({
    super.key,
    this.customTips,
    this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = customTips ?? _getDefaultTips();
    final tipTitle = title ?? '검색 팁';
    final tipIcon = icon ?? Icons.lightbulb_outline;

    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipHeader(tipTitle, tipIcon),
          SizedBox(height: AppSizes.gapS),
          ...tips.map((tip) => _buildTipItem(tip)).toList(),
        ],
      ),
    );
  }

  Widget _buildTipHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: AppSizes.iconS,
        ),
        SizedBox(width: AppSizes.gapXS),
        Text(
          title,
          style: AppTextStyles.labelBold.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.gapXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getDefaultTips() {
    return [
      '조용한 도서관, 한적한 카페 등을 검색해보세요',
      '지역명과 함께 검색하면 더 정확한 결과를 얻을 수 있어요',
      '관심 있는 활동을 입력해보세요 (독서, 산책, 명상 등)',
      '궁궐, 사찰, 공원 등 조용한 장소를 추천해드려요',
    ];
  }
}
