import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';

class AILoadingState extends StatelessWidget {
  final bool isTablet;

  const AILoadingState({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? AppSizes.iconXL * 2 : AppSizes.iconXL + AppSizes.gapXL,
            height: isTablet ? AppSizes.iconXL * 2 : AppSizes.iconXL + AppSizes.gapXL,
            decoration: BoxDecoration(
              color: Color(0xFF7A9B76).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7A9B76),
                strokeWidth: isTablet ? 4.0 : 3.0,
              ),
            ),
          ),
          SizedBox(height: isTablet ? AppSizes.gapXXL : AppSizes.gapL),
          Text(
            'AI가 분석 중이에요',
            style: isTablet ? AppTextStyles.h3 : AppTextStyles.h4,
          ),
          SizedBox(height: AppSizes.gapS),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.gapXL),
            child: Text(
              '당신만을 위한 특별한 여행지를\n찾고 있어요',
              style: isTablet
                  ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF888888))
                  : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class AIEmptyState extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onRetry;

  const AIEmptyState({
    super.key,
    required this.isTablet,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? AppSizes.gapXXL + AppSizes.gapL : AppSizes.gapXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isTablet ? AppSizes.iconXL * 2.5 : AppSizes.iconXL * 2,
              height: isTablet ? AppSizes.iconXL * 2.5 : AppSizes.iconXL * 2,
              decoration: BoxDecoration(
                color: Color(0xFF7A9B76).withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  isTablet ? AppSizes.gapXL + 6 : AppSizes.radiusXL + 9,
                ),
              ),
              child: Icon(
                Icons.cloud_off,
                size: isTablet ? AppSizes.iconXL + AppSizes.gapS : AppSizes.iconXL + 2,
                color: Color(0xFF7A9B76),
              ),
            ),
            SizedBox(height: isTablet ? AppSizes.gapXXL : AppSizes.gapXL),
            Text(
              '연결할 수 없습니다',
              style: isTablet ? AppTextStyles.h2 : AppTextStyles.h3,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              'AI 서비스에 연결할 수 없어요\n인터넷 연결을 확인하고 다시 시도해주세요',
              style: isTablet
                  ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF888888))
                  : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? AppSizes.gapXL : AppSizes.gapL),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7A9B76), Color(0xFF8FA68E)],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: TextButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: isTablet ? AppSizes.iconM : AppSizes.iconS + 2,
                ),
                label: Text(
                  '다시 시도',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AIFloatingButton extends StatelessWidget {
  final bool isLoading;
  final bool isTablet;
  final VoidCallback onPressed;

  const AIFloatingButton({
    super.key,
    required this.isLoading,
    required this.isTablet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = isTablet ? AppSizes.avatarL : AppSizes.listItemHeight;
    final iconSize = isTablet ? AppSizes.iconL : AppSizes.iconM;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: isLoading
            ? null
            : LinearGradient(
          colors: [
            Color(0xFF7A9B76),
            Color(0xFF8FA68E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: isLoading ? Colors.grey[400] : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: isLoading
                ? Colors.grey.withOpacity(0.2)
                : Color(0xFF7A9B76).withOpacity(0.4),
            blurRadius: AppSizes.spacingM,
            offset: Offset(0, AppSizes.gapS),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: Center(
            child: Icon(
              isLoading ? Icons.refresh_outlined : Icons.refresh,
              color: isLoading ? Colors.grey[600] : Colors.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
