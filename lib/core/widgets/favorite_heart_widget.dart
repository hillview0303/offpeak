import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/custom_toast.dart';

class FavoriteHeartWidget extends HookConsumerWidget {
  final String contentId;
  final String contentTitle;
  final bool isTablet;
  final Color? backgroundColor;
  final Color? borderColor;

  const FavoriteHeartWidget({
    Key? key,
    required this.contentId,
    required this.contentTitle,
    this.isTablet = false,
    this.backgroundColor,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // favorite provider 관련 코드는 실제 프로젝트에 맞게 수정 필요
    final isFavorite = useState(false); // 임시로 useState 사용

    final heartSize = isTablet
        ? AppSizes.avatarM - AppSizes.gapXS
        : AppSizes.spacingL + AppSizes.gapS;

    return GestureDetector(
      onTap: () {
        // 실제 구현에서는 favoritesNotifier.toggleFavorite(contentId); 사용
        isFavorite.value = !isFavorite.value;

        // 햅틱 피드백 (선택사항)
        // HapticFeedback.lightImpact();

        // 커스텀 토스트로 피드백 제공 (기존 구현된 함수 사용)
        showFavoriteToast(
          context,
          contentTitle,
          isFavorite.value,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: heartSize,
        height: heartSize,
        decoration: BoxDecoration(
          color: isFavorite.value
              ? (backgroundColor ?? Colors.pink.shade50)
              : (backgroundColor ?? Color(0xFFF8F9FA)),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: isFavorite.value
              ? Border.all(
            color: borderColor ?? Colors.pink.shade200,
            width: 1,
          )
              : null,
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Icon(
            isFavorite.value ? Icons.favorite : Icons.favorite_border,
            key: ValueKey(isFavorite.value),
            size: isTablet ? AppSizes.iconM : AppSizes.iconS + 4,
            color: isFavorite.value ? Colors.pink : Color(0xFF888888),
          ),
        ),
      ),
    );
  }
}
