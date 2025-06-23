import 'package:flutter/material.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../providers/recommendation_model.dart';

class RecommendationImageGallery extends StatelessWidget {
  final RecommendationCard recommendation;
  final bool isTablet;

  const RecommendationImageGallery({
    super.key,
    required this.recommendation,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final availableImages = [
      'assets/images/forest.png',
      'assets/images/water.png',
      'assets/images/forest.png',
      'assets/images/water.png',
    ];

    if (!_hasValidImage() || availableImages.isEmpty) {
      return SizedBox.shrink();
    }

    final hasMoreThanThreeImages = availableImages.length > 3;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.28;

    return Column(
      children: [
        SizedBox(
          height: imageSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hasMoreThanThreeImages ? 3 : availableImages.length,
            separatorBuilder: (context, index) => SizedBox(width: AppSizes.gapM),
            itemBuilder: (context, index) {
              final isFirstImageWithOverlay = hasMoreThanThreeImages && index == 0;

              return _buildImageItem(
                context,
                availableImages,
                index,
                imageSize,
                imageSize,
                isFirstImageWithOverlay,
              );
            },
          ),
        ),
        SizedBox(height: AppSizes.gapM),
      ],
    );
  }

  Widget _buildImageItem(
      BuildContext context,
      List<String> availableImages,
      int index,
      double imageWidth,
      double imageHeight,
      bool isFirstImageWithOverlay,
      ) {
    return GestureDetector(
      onTap: () => _showImageGallery(context, availableImages),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    availableImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('이미지 로딩 실패: ${availableImages[index]}');
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: AppSizes.iconL,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '이미지 없음',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (isFirstImageWithOverlay)
                  ImageOverlay(
                    totalImages: availableImages.length,
                    isTablet: isTablet,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasValidImage() {
    return true;
  }

  void _showImageGallery(BuildContext context, List<String> images) {
    final PageController pageController = PageController();
    int currentIndex = 0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.black87,
          insetPadding: EdgeInsets.all(AppSizes.gapM),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                _buildGalleryHeader(context, currentIndex, images.length),
                _buildGalleryContent(pageController, images, setState, currentIndex),
                _buildGalleryFooter(pageController, images, currentIndex, setState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryHeader(BuildContext context, int currentIndex, int totalImages) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.gapM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              recommendation.title,
              style: AppTextStyles.h4.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: AppSizes.gapS),
          Text(
            '${currentIndex + 1}/$totalImages',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          SizedBox(width: AppSizes.gapS),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(AppSizes.gapXS),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: AppSizes.iconM,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryContent(
      PageController pageController,
      List<String> images,
      StateSetter setState,
      int currentIndex,
      ) {
    return Expanded(
      child: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: AppSizes.gapS),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              child: Image.asset(
                images[index],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: AppSizes.iconXL,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryFooter(
      PageController pageController,
      List<String> images,
      int currentIndex,
      StateSetter setState,
      ) {
    return Padding(
      padding: EdgeInsets.all(AppSizes.gapM),
      child: Column(
        children: [
          if (images.length > 1) _buildDotIndicator(pageController, images, currentIndex),
          if (images.length > 1) ...[
            SizedBox(height: AppSizes.gapM),
            _buildNavigationButtons(pageController, images, currentIndex),
          ],
        ],
      ),
    );
  }

  Widget _buildDotIndicator(PageController pageController, List<String> images, int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        images.length,
            (index) => GestureDetector(
          onTap: () {
            pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            width: currentIndex == index ? AppSizes.gapM : AppSizes.gapS,
            height: AppSizes.gapS,
            margin: EdgeInsets.symmetric(horizontal: AppSizes.gapXS),
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppSizes.gapS / 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
      PageController pageController,
      List<String> images,
      int currentIndex,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavButton(
          label: '이전',
          icon: Icons.arrow_back_ios,
          isEnabled: currentIndex > 0,
          onTap: () {
            pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          isNext: false,
        ),
        _buildNavButton(
          label: '다음',
          icon: Icons.arrow_forward_ios,
          isEnabled: currentIndex < images.length - 1,
          onTap: () {
            pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          isNext: true,
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required String label,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
    required bool isNext,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.gapM,
          vertical: AppSizes.gapS,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNext) ...[
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.gapXS),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
            if (isNext) ...[
              SizedBox(width: AppSizes.gapXS),
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
                size: AppSizes.iconS,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImageOverlay extends StatelessWidget {
  final int totalImages;
  final bool isTablet;

  const ImageOverlay({
    super.key,
    required this.totalImages,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 3.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: isTablet ? AppSizes.iconM : AppSizes.iconS + 2,
                  ),
                ),
                SizedBox(height: AppSizes.gapXS),
                Text(
                  '+${totalImages - 1}',
                  style: (isTablet ? AppTextStyles.bodyMedium : AppTextStyles.bodySmall).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 3.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
