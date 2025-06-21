import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSizes.gapM,
        AppSizes.gapS,
        AppSizes.gapM,
        AppSizes.gapL,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: AppSizes.elevationM,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단 앱바 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 앱 타이틀
              Text(
                'OffPeak',
                style: AppTextStyles.appBarTitle.copyWith(
                  color: AppColors.white,
                ),
              ),

              // 액션 버튼들
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // 알림 페이지로 이동
                    },
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.white.withOpacity(0.9),
                      size: AppSizes.iconM,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // 설정 페이지로 이동
                    },
                    icon: Icon(
                      Icons.person_outline,
                      color: AppColors.white.withOpacity(0.9),
                      size: AppSizes.iconM,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: AppSizes.gapM),

          // 환영 메시지 영역
          Align(
            alignment: Alignment.centerLeft,
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
          ),
        ],
      ),
    );
  }
}
