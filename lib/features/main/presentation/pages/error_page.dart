import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';

class ErrorPage extends StatelessWidget {
  final String error;

  const ErrorPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '오류',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        leading: IconButton(
          onPressed: () => NavigationService.instance.goHome(),
          icon: Icon(
            Icons.home,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.gapL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 에러 아이콘
              Container(
                padding: EdgeInsets.all(AppSizes.gapXL),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: AppSizes.iconXL * 2,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: AppSizes.gapL),

              // 에러 제목
              Text(
                '페이지를 찾을 수 없습니다',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.gapM),

              // 에러 설명
              Text(
                '요청하신 페이지가 존재하지 않거나\n일시적인 오류가 발생했습니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSizes.gapS),

              // 에러 상세 정보 (디버그용)
              if (error.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(vertical: AppSizes.gapM),
                  padding: EdgeInsets.all(AppSizes.gapM),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Text(
                    error,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(height: AppSizes.gapXL),

              // 홈으로 돌아가기 버튼
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => NavigationService.instance.goHome(),
                  icon: Icon(
                    Icons.home,
                    color: AppColors.white,
                    size: AppSizes.iconM,
                  ),
                  label: Text(
                    '홈으로 돌아가기',
                    style: AppTextStyles.buttonMedium,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    elevation: AppSizes.elevationS,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.gapM),

              // 다시 시도 버튼
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // 페이지 새로고침 또는 뒤로가기
                    if (NavigationService.instance.canPop()) {
                      NavigationService.instance.goBack();
                    } else {
                      NavigationService.instance.goHome();
                    }
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: AppColors.primary,
                    size: AppSizes.iconM,
                  ),
                  label: Text(
                    '다시 시도',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
