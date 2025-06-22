import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> quickActions = [
      {'icon': Icons.search, 'label': '여행지 검색', 'route': '/search'},
      {'icon': Icons.location_on_outlined, 'label': '내 주변', 'route': '/nearby'},
      {'icon': Icons.bookmark_outline, 'label': '찜한 장소', 'route': '/bookmarks'},
      {'icon': Icons.history, 'label': '최근 활동', 'route': '/recent'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '바로 가기',
            style: AppTextStyles.h3.copyWith(
              fontSize: 15
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: quickActions.map((action) {
              return Expanded(
                child: _buildQuickActionItem(
                  icon: action['icon'],
                  label: action['label'],
                  onTap: () {
                    // 해당 페이지로 이동
                    print('Navigate to: ${action['route']}');
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSizes.gapM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: AppSizes.iconM,
              ),
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
