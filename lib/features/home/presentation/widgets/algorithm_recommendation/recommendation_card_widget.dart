import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recommendation_model.dart';
import '../../../../../core/widgets/custom_toast.dart';
import 'recommendation_image_gallery.dart';
import 'recommendation_info_sections.dart';

class RecommendationCardWidget extends HookConsumerWidget {
  final RecommendationCard recommendation;
  final VoidCallback? onTap;

  const RecommendationCardWidget({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final cardColors = [
      Color(0xFF8B9A8B), // 차분한 세이지 그린
      Color(0xFF9B96A6), // 부드러운 라벤더 그레이
      Color(0xFFB8A082), // 따뜻한 베이지
      Color(0xFFA08A8A), // 더스티 로즈
      Color(0xFF7B8FA3), // 차분한 슬레이트 블루
    ];
    final colorIndex = recommendation.title.hashCode % cardColors.length;
    final cardColor = cardColors[colorIndex.abs()];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: AppSizes.elevationL * 2,
              offset: Offset(0, AppSizes.elevationS),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? AppSizes.gapXL : AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(cardColor, isTablet, context, ref),
              SizedBox(height: AppSizes.gapM),
              RecommendationImageGallery(
                recommendation: recommendation,
                isTablet: isTablet,
              ),
              RecommendationInfoSections(
                recommendation: recommendation,
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color cardColor, bool isTablet, BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(recommendation.contentId));
    final favoritesNotifier = ref.read(favoritesProvider.notifier);

    final heartSize = isTablet
        ? AppSizes.avatarM - AppSizes.gapXS
        : AppSizes.spacingL + AppSizes.gapS;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목과 매칭률이 세로로 배치
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                recommendation.title,
                style: isTablet
                    ? AppTextStyles.h3.copyWith(fontSize: AppTextStyles.fontSizeXXL)
                    : AppTextStyles.h4,
              ),
              SizedBox(height: AppSizes.gapXS + 2),
              // 매칭률
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.gapS,
                  vertical: AppSizes.gapXS,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  '${recommendation.matchPercentage}% 일치',
                  style: AppTextStyles.caption.copyWith(
                    color: cardColor,
                    fontWeight: AppTextStyles.semiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSizes.gapS),
        // 좋아요 버튼
        GestureDetector(
          onTap: () {
            favoritesNotifier.toggleFavorite(recommendation.contentId);

            // 햅틱 피드백 (선택사항)
            // HapticFeedback.lightImpact();

            // 커스텀 토스트로 피드백 제공
            showFavoriteToast(
              context,
              recommendation.title,
              !isFavorite, // 토글 후의 상태
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: heartSize,
            height: heartSize,
            decoration: BoxDecoration(
              color: isFavorite ? Colors.pink.shade50 : Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: isFavorite
                  ? Border.all(color: Colors.pink.shade200, width: 1)
                  : null,
            ),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFavorite),
                size: isTablet ? AppSizes.iconM : AppSizes.iconS + 4,
                color: isFavorite ? Colors.pink : Color(0xFF888888),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
