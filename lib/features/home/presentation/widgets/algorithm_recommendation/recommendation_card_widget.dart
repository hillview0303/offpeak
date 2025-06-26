import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/service/tourism_api_service.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recommendation_model.dart';
import '../../../../../core/widgets/custom_toast.dart';
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

    // 🆕 이미지 상태 관리
    final images = useState<List<String>>([]);
    final isLoadingImages = useState<bool>(false);
    final currentImageIndex = useState<int>(0);

    // 🆕 이미지 로드 함수
    Future<void> loadImages() async {
      if (recommendation.contentId.isEmpty) return;

      isLoadingImages.value = true;

      try {
        print('🖼️ 메인 이미지 로드 시작: ${recommendation.title}');

        final imageList = await TourismApiService.fetchPlaceImages(recommendation.contentId);

        images.value = imageList;
        isLoadingImages.value = false;

        print('✅ 메인 이미지 로드 완료: ${images.value.length}개');
      } catch (e) {
        print('❌ 메인 이미지 로드 실패: $e');
        images.value = [];
        isLoadingImages.value = false;
      }
    }

    // 🆕 초기 이미지 로드
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadImages();
      });
      return null;
    }, []);

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
              // 🆕 실제 API 이미지를 X% 일치 아래에 표시
              _buildMainImageSection(
                recommendation,
                images.value,
                isLoadingImages.value,
                currentImageIndex.value,
                    (index) => currentImageIndex.value = index,
                isTablet,
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

  /// 🆕 메인 이미지 섹션 (X% 일치 아래에 표시)
  Widget _buildMainImageSection(
      RecommendationCard recommendation,
      List<String> images,
      bool isLoadingImages,
      int currentImageIndex,
      Function(int) onImageIndexChanged,
      bool isTablet,
      ) {
    // contentId가 없으면 이미지 섹션을 표시하지 않음
    if (recommendation.contentId.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 로딩 중일 때
        if (isLoadingImages) ...[
          Container(
            height: isTablet ? 200 : 160,
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF7A9B76),
                    strokeWidth: 2.0,
                  ),
                  SizedBox(height: AppSizes.gapS),
                  Text(
                    '이미지 로딩 중...',
                    style: AppTextStyles.caption.copyWith(
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSizes.gapM),
        ],

        // 이미지가 있을 때 갤러리 표시
        if (!isLoadingImages && images.isNotEmpty) ...[
          _buildImageGallery(images, currentImageIndex, onImageIndexChanged, isTablet),
          SizedBox(height: AppSizes.gapM),
        ],
      ],
    );
  }

  /// 🆕 이미지 갤러리 구현
  Widget _buildImageGallery(
      List<String> images,
      int currentImageIndex,
      Function(int) onImageIndexChanged,
      bool isTablet,
      ) {
    final imageHeight = isTablet ? 200.0 : 160.0;
    final hasMultipleImages = images.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 표시
        SizedBox(
          height: imageHeight,
          child: hasMultipleImages
              ? _buildImageSlider(images, imageHeight, onImageIndexChanged)
              : _buildSingleImage(images.first, imageHeight),
        ),

        // 여러 이미지가 있을 때 인디케이터 표시
        if (hasMultipleImages) ...[
          SizedBox(height: AppSizes.gapS),
          _buildImageIndicator(images, currentImageIndex, isTablet),
        ],
      ],
    );
  }

  /// 🆕 단일 이미지 표시
  Widget _buildSingleImage(String imageUrl, double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Color(0xFFF5F5F5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7A9B76),
                  strokeWidth: 2.0,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ 메인 이미지 로드 실패: $imageUrl');
            return Container(
              color: Color(0xFFF5F5F5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF888888),
                      size: AppSizes.iconM,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      '이미지를 불러올 수 없습니다',
                      style: AppTextStyles.caption.copyWith(
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🆕 이미지 슬라이더 (여러 이미지)
  Widget _buildImageSlider(
      List<String> images,
      double height,
      Function(int) onImageIndexChanged,
      ) {
    return PageView.builder(
      itemCount: images.length,
      onPageChanged: onImageIndexChanged,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < images.length - 1 ? AppSizes.gapS : 0,
          ),
          child: _buildSingleImage(images[index], height),
        );
      },
    );
  }

  /// 🆕 이미지 인디케이터 (페이지 표시)
  Widget _buildImageIndicator(List<String> images, int currentImageIndex, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(images.length, (index) {
          final isActive = index == currentImageIndex;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            width: isActive ? AppSizes.gapM : AppSizes.gapS,
            height: AppSizes.gapXS,
            decoration: BoxDecoration(
              color: isActive
                  ? Color(0xFF7A9B76)
                  : Color(0xFF7A9B76).withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSizes.gapXS / 2),
            ),
          );
        }),
        SizedBox(width: AppSizes.gapS),
        Text(
          '${currentImageIndex + 1}/${images.length}',
          style: AppTextStyles.caption.copyWith(
            color: Color(0xFF666666),
            fontSize: isTablet ? 11.0 : 10.0,
          ),
        ),
      ],
    );
  }
}
