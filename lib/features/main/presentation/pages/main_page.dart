import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';

class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await NavigationService.instance.handleBackPress(context);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.elevationM,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.gapS,
            vertical: AppSizes.gapXS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
                isSelected: navigationShell.currentIndex == 0,
                onTap: () => _onTap(0),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: '챗',
                isSelected: navigationShell.currentIndex == 1,
                onTap: () => _onTap(1),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.local_activity_outlined,
                activeIcon: Icons.local_activity,
                label: '액티비티',
                isSelected: navigationShell.currentIndex == 2,
                onTap: () => _onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.gapS,
            horizontal: AppSizes.gapXS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: AppSizes.iconM,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSizes.gapXS),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? AppTextStyles.semiBold : AppTextStyles.regular,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // 같은 탭을 다시 누르면 루트로 이동
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
