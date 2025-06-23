import 'package:flutter/material.dart';
import '../constants/color.dart';
import '../constants/size.dart';
import '../constants/style.dart';

enum ToastType {
  favorite,
  success,
  error,
  info,
  warning,
}

class CustomToast extends StatelessWidget {
  final String message;
  final ToastType type;
  final IconData? customIcon;

  const CustomToast({
    super.key,
    required this.message,
    required this.type,
    this.customIcon,
  });

  // 찜 토스트 생성자
  const CustomToast.favorite({
    super.key,
    required this.message,
  }) : type = ToastType.favorite,
        customIcon = null;

  // 성공 토스트 생성자
  const CustomToast.success({
    super.key,
    required this.message,
  }) : type = ToastType.success,
        customIcon = null;

  // 에러 토스트 생성자
  const CustomToast.error({
    super.key,
    required this.message,
  }) : type = ToastType.error,
        customIcon = null;

  // 정보 토스트 생성자
  const CustomToast.info({
    super.key,
    required this.message,
  }) : type = ToastType.info,
        customIcon = null;

  // 경고 토스트 생성자
  const CustomToast.warning({
    super.key,
    required this.message,
  }) : type = ToastType.warning,
        customIcon = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(AppSizes.spacingL),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withAlpha((0.9 * 255).toInt()),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Icon(
              _getIcon(),
              color: Colors.white,
              size: AppSizes.iconL,
            ),
            SizedBox(height: AppSizes.gapM),
            // 메시지
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: AppTextStyles.semiBold,
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (customIcon != null) return customIcon!;

    switch (type) {
      case ToastType.favorite:
        return Icons.favorite;
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.info:
        return Icons.info;
      case ToastType.warning:
        return Icons.warning;
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ToastType.favorite:
        return Colors.pink;
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.info;
      case ToastType.warning:
        return AppColors.warning;
    }
  }
}

// CustomToast 표시 함수 (Overlay 방식으로 수정)
Future<void> showCustomToast(
    BuildContext context,
    Widget toast, {
      Duration duration = const Duration(milliseconds: 1500),
    }) async {
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => toast,
  );

  Overlay.of(context).insert(overlayEntry);

  await Future.delayed(duration);
  overlayEntry.remove();
}

// 찜 토스트 표시 (찜할 때만 알림)
Future<void> showFavoriteToast(
    BuildContext context,
    String title,
    bool isFavorited,
    ) async {
  // 찜할 때만 토스트 표시
  if (isFavorited) {
    await showCustomToast(
      context,
      CustomToast.favorite(
        message: '$title 찜 완료!',
      ),
    );
  }
}

// 성공 토스트 표시
Future<void> showSuccessToast(
    BuildContext context,
    String message,
    ) async {
  await showCustomToast(
    context,
    CustomToast.success(message: message),
  );
}

// 에러 토스트 표시
Future<void> showErrorToast(
    BuildContext context,
    String message,
    ) async {
  await showCustomToast(
    context,
    CustomToast.error(message: message),
    duration: const Duration(milliseconds: 2000),
  );
}

// 정보 토스트 표시
Future<void> showInfoToast(
    BuildContext context,
    String message,
    ) async {
  await showCustomToast(
    context,
    CustomToast.info(message: message),
  );
}

// 경고 토스트 표시
Future<void> showWarningToast(
    BuildContext context,
    String message,
    ) async {
  await showCustomToast(
    context,
    CustomToast.warning(message: message),
  );
}
