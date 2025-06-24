import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 기본 네비게이션 바
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: Container(
              height: 65, // 80 → 65로 줄임
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6), // 패딩도 살짝 줄임
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 홈 버튼
                  _buildNavItem(
                    iconPath: 'assets/images/home.svg',
                    fallbackIcon: Icons.home,
                    label: '홈',
                    isSelected: navigationShell.currentIndex == 0,
                    onTap: () => _onTap(0),
                  ),

                  // 마이 버튼
                  _buildNavItem(
                    iconPath: 'assets/images/my.svg',
                    fallbackIcon: Icons.person,
                    label: '마이',
                    isSelected: navigationShell.currentIndex == 2,
                    onTap: () => _onTap(2),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 챗 버튼 (상단에 걸치게)
        Positioned(
          top: -15, // -35 → -30으로 조정 (높이가 줄어든 만큼)
          left: 0,
          right: 0,
          child: Center(
            child: _buildFloatingChatButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required IconData fallbackIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45, // 50 → 45로 줄임
        padding: const EdgeInsets.symmetric(vertical: 4), // 8 → 4로 줄임
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SVG 아이콘 또는 fallback 아이콘
            _buildSvgIcon(
              iconPath: iconPath,
              fallbackIcon: fallbackIcon,
              size: 20, // 24 → 20으로 줄임
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 1), // 2 → 1로 줄임
            Text(
              label,
              style: TextStyle(
                fontSize: 10, // 11 → 10으로 줄임
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingChatButton() {
    final isSelected = navigationShell.currentIndex == 1;

    return GestureDetector(
      onTap: () => _onTap(1),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.secondary : AppColors.secondary,
          border: Border.all(
            color: AppColors.surface,
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.chat_outlined,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSvgIcon({
    required String iconPath,
    required IconData fallbackIcon,
    required double size,
    required Color color,
  }) {
    try {
      return SvgPicture.asset(
        iconPath,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } catch (e) {
      // SVG 로딩 실패시 기본 아이콘 사용
      print('SVG 로딩 실패: $iconPath, 에러: $e');
      return Icon(fallbackIcon, size: size, color: color);
    }
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // 같은 탭을 다시 누르면 루트로 이동
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
