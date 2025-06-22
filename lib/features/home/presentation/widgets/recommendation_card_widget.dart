import 'package:flutter/material.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../providers/recommendation_model.dart';

class RecommendationCardWidget extends StatelessWidget {
  final RecommendationCard recommendation;
  final VoidCallback? onTap;

  const RecommendationCardWidget({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        constraints: BoxConstraints(
          minHeight: isTablet ? 240.0 : 200.0,
        ),
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
              _buildHeader(cardColor, isTablet),
              SizedBox(height: AppSizes.gapM),
              _buildLocationInfo(isTablet),
              _buildDescription(isTablet),
              SizedBox(height: AppSizes.gapS),
              _buildQuietReason(isTablet),
              SizedBox(height: AppSizes.gapS),
              _buildRecommendedActivity(isTablet),
              SizedBox(height: AppSizes.gapM),
              _buildTransportationInfo(isTablet),
              SizedBox(height: AppSizes.gapS),
              _buildWeatherInfo(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color cardColor, bool isTablet) {
    // AppSizes 상수를 활용한 반응형 크기
    final imageSize = isTablet ? AppSizes.iconXL * 2 : AppSizes.avatarL + AppSizes.gapS;
    final heartSize = isTablet ? AppSizes.avatarM - AppSizes.gapXS : AppSizes.spacingL + AppSizes.gapS;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 좌측 이미지/아이콘 컨테이너
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            child: recommendation.imageUrl.isNotEmpty
                ? Image.network(
              recommendation.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderIcon(cardColor, isTablet),
            )
                : _buildPlaceholderIcon(cardColor, isTablet),
          ),
        ),
        SizedBox(width: AppSizes.gapM),

        // 제목, 매칭률, 별점이 세로로 배치
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

              SizedBox(height: AppSizes.gapXS + 2),

              // 별점
              Row(
                children: [
                  Text(
                    recommendation.rating.toStringAsFixed(1),
                    style: isTablet
                        ? AppTextStyles.numberSmall.copyWith(fontSize: AppTextStyles.fontSizeLG)
                        : AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.semiBold),
                  ),
                  SizedBox(width: AppSizes.gapXS),
                  Icon(
                    Icons.star_rounded,
                    size: isTablet ? AppSizes.iconM : AppSizes.iconS,
                    color: Color(0xFFFFB800),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(width: AppSizes.gapS),

        // 좋아요 버튼
        Container(
          width: heartSize,
          height: heartSize,
          decoration: BoxDecoration(
            color: Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: Icon(
            Icons.favorite_border,
            size: isTablet ? AppSizes.iconM : AppSizes.iconS + 4,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(bool isTablet) {
    if (recommendation.location.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Color(0xFF888888),
              size: isTablet ? AppSizes.iconM : AppSizes.iconS,
            ),
            SizedBox(width: AppSizes.gapXS + 2),
            Expanded(
              child: Text(
                recommendation.location,
                style: isTablet
                    ? AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888))
                    : AppTextStyles.bodySmall.copyWith(color: Color(0xFF888888)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.gapS),
      ],
    );
  }

  Widget _buildDescription(bool isTablet) {
    return Text(
      recommendation.description.replaceAll(RegExp(r'\*+'), ''),
      style: isTablet
          ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF666666))
          : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF666666)),
      maxLines: isTablet ? 4 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildQuietReason(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? AppSizes.gapS : 10.0),
      decoration: BoxDecoration(
        color: Color(0xFFF0F8F0),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: Color(0xFF4CAF50).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.volume_off,
              color: Color(0xFF4CAF50),
              size: isTablet ? AppSizes.iconS : 14.0,
            ),
          ),
          SizedBox(width: AppSizes.gapXS + 2),
          Expanded(
            child: Text(
              recommendation.quietReason.replaceAll(RegExp(r'\*+'), ''),
              style: AppTextStyles.caption.copyWith(
                color: Color(0xFF4CAF50),
                fontWeight: AppTextStyles.medium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedActivity(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? AppSizes.gapS : 10.0),
      decoration: BoxDecoration(
        color: Color(0xFFF8F0FF),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: Color(0xFF9C27B0).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.self_improvement,
              color: Color(0xFF9C27B0),
              size: isTablet ? AppSizes.iconS : 14.0,
            ),
          ),
          SizedBox(width: AppSizes.gapXS + 2),
          Expanded(
            child: Text(
              recommendation.recommendedActivity.replaceAll(RegExp(r'\*+'), ''),
              style: AppTextStyles.caption.copyWith(
                color: Color(0xFF9C27B0),
                fontWeight: AppTextStyles.medium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationInfo(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? AppSizes.gapM : AppSizes.gapS),
      decoration: BoxDecoration(
        color: Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: Color(0xFF4A90E2).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.directions_transit,
              color: Color(0xFF4A90E2),
              size: isTablet ? AppSizes.iconM : AppSizes.iconS,
            ),
          ),
          SizedBox(width: AppSizes.gapS),
          Expanded(
            child: Text(
              recommendation.transportation.replaceAll(RegExp(r'\*+'), ''),
              style: isTablet
                  ? AppTextStyles.bodyMedium.copyWith(
                color: Color(0xFF4A90E2),
                fontWeight: AppTextStyles.medium,
              )
                  : AppTextStyles.bodySmall.copyWith(
                color: Color(0xFF4A90E2),
                fontWeight: AppTextStyles.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? AppSizes.gapS : 10.0),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: Color(0xFFFF9800).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.wb_cloudy,
              color: Color(0xFFFF9800),
              size: isTablet ? AppSizes.iconS : 14.0,
            ),
          ),
          SizedBox(width: AppSizes.gapXS + 2),
          Expanded(
            child: Text(
              recommendation.weatherSuitability.replaceAll(RegExp(r'\*+'), ''),
              style: AppTextStyles.caption.copyWith(
                color: Color(0xFFFF9800),
                fontWeight: AppTextStyles.medium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon(Color color, bool isTablet) {
    final icons = [
      Icons.landscape_outlined,
      Icons.temple_buddhist_outlined,
      Icons.museum_outlined,
      Icons.park_outlined,
      Icons.beach_access_outlined,
    ];
    final iconIndex = color.hashCode % icons.length;

    return Center(
      child: Icon(
        icons[iconIndex.abs()],
        size: isTablet ? AppSizes.iconL + AppSizes.gapS : AppSizes.iconL,
        color: color,
      ),
    );
  }
}
