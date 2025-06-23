import 'package:flutter/material.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../providers/recommendation_model.dart';

class RecommendationInfoSections extends StatelessWidget {
  final RecommendationCard recommendation;
  final bool isTablet;

  const RecommendationInfoSections({
    super.key,
    required this.recommendation,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationInfo(),
        _buildDescription(),
        SizedBox(height: AppSizes.gapS),
        _buildQuietReason(),
        SizedBox(height: AppSizes.gapS),
        _buildRecommendedActivity(),
        SizedBox(height: AppSizes.gapS),
        _buildTransportationInfo(),
        SizedBox(height: AppSizes.gapS),
        _buildWeatherInfo(),
      ],
    );
  }

  Widget _buildLocationInfo() {
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
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.gapS),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      recommendation.description.replaceAll(RegExp(r'\*+'), ''),
      style: isTablet
          ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF666666))
          : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF666666)),
    );
  }

  Widget _buildQuietReason() {
    return _buildInfoContainer(
      backgroundColor: Color(0xFFF0F8F0),
      borderColor: Color(0xFF4CAF50).withOpacity(0.2),
      iconColor: Color(0xFF4CAF50),
      textColor: Color(0xFF4CAF50),
      icon: Icons.volume_off,
      text: recommendation.quietReason.replaceAll(RegExp(r'\*+'), ''),
    );
  }

  Widget _buildRecommendedActivity() {
    return _buildInfoContainer(
      backgroundColor: Color(0xFFF8F0FF),
      borderColor: Color(0xFF9C27B0).withOpacity(0.2),
      iconColor: Color(0xFF9C27B0),
      textColor: Color(0xFF9C27B0),
      icon: Icons.self_improvement,
      text: recommendation.recommendedActivity.replaceAll(RegExp(r'\*+'), ''),
    );
  }

  Widget _buildTransportationInfo() {
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

  Widget _buildWeatherInfo() {
    return _buildInfoContainer(
      backgroundColor: Color(0xFFFFF8E1),
      borderColor: Color(0xFFFF9800).withOpacity(0.2),
      iconColor: Color(0xFFFF9800),
      textColor: Color(0xFFFF9800),
      icon: Icons.wb_cloudy,
      text: recommendation.weatherSuitability.replaceAll(RegExp(r'\*+'), ''),
      useSmallPadding: true,
    );
  }

  Widget _buildInfoContainer({
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    required String text,
    bool useSmallPadding = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
          useSmallPadding
              ? (isTablet ? AppSizes.gapS : 10.0)
              : (isTablet ? AppSizes.gapS : 10.0)),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              icon,
              color: iconColor,
              size: isTablet ? AppSizes.iconS : 14.0,
            ),
          ),
          SizedBox(width: AppSizes.gapXS + 2),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: AppTextStyles.medium,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
