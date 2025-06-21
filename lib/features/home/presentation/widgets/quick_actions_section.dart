import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 액션',
            style: AppTextStyles.label,
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
      ),
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
}
