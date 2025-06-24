import 'package:flutter/material.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/service/nearby_service.dart';

class PlaceDetailContent extends StatelessWidget {
  final String title;
  final String? location;
  final String? distance;
  final String? description;
  final String? reason;
  final String? category;
  final bool isOpen;

  const PlaceDetailContent({
    super.key,
    required this.title,
    this.location,
    this.distance,
    this.description,
    this.reason,
    this.category,
    this.isOpen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationInfo(),
        _buildDescription(),
        SizedBox(height: AppSizes.gapM),
        _buildRecommendationInfo(),
        SizedBox(height: AppSizes.gapM),
        _buildStatusInfo(),
        SizedBox(height: AppSizes.gapXL), // 하단 여백
      ],
    );
  }

  Widget _buildLocationInfo() {
    if ((location == null || location!.isEmpty || location == '주소 정보 없음') &&
        (distance == null || distance!.isEmpty || distance == '거리 정보 없음')) {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        // 주소
        if (location != null && location!.isNotEmpty && location != '주소 정보 없음') ...[
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFF888888),
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.gapXS + 2),
              Expanded(
                child: Text(
                  location!,
                  style: AppTextStyles.bodySmall.copyWith(color: Color(0xFF888888)),
                ),
              ),
            ],
          ),
        ],

        // 거리
        if (distance != null && distance!.isNotEmpty && distance != '거리 정보 없음') ...[
          if (location != null && location!.isNotEmpty && location != '주소 정보 없음')
            SizedBox(height: AppSizes.gapXS),
          Row(
            children: [
              Icon(
                Icons.directions_walk,
                color: Color(0xFF888888),
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.gapXS + 2),
              Text(
                distance!,
                style: AppTextStyles.bodySmall.copyWith(color: Color(0xFF888888)),
              ),
            ],
          ),
        ],
        SizedBox(height: AppSizes.gapM),
      ],
    );
  }

  Widget _buildDescription() {
    if (description == null || description!.isEmpty) {
      return SizedBox.shrink();
    }

    return Text(
      description!.replaceAll(RegExp(r'\*+'), ''),
      style: AppTextStyles.bodyMedium.copyWith(color: Color(0xFF666666)),
    );
  }

  Widget _buildRecommendationInfo() {
    if (reason == null || reason!.isEmpty) {
      return SizedBox.shrink();
    }

    return _buildInfoContainer(
      backgroundColor: Color(0xFFF0F8F0),
      borderColor: Color(0xFF4CAF50).withOpacity(0.2),
      iconColor: Color(0xFF4CAF50),
      textColor: Color(0xFF4CAF50),
      icon: Icons.thumb_up_outlined,
      text: reason!.replaceAll(RegExp(r'\*+'), ''),
    );
  }

  Widget _buildStatusInfo() {
    return _buildInfoContainer(
      backgroundColor: isOpen ? Color(0xFFF0F8F0) : Color(0xFFFFF0F0),
      borderColor: isOpen
          ? Color(0xFF4CAF50).withOpacity(0.2)
          : Color(0xFFFF5722).withOpacity(0.2),
      iconColor: isOpen ? Color(0xFF4CAF50) : Color(0xFFFF5722),
      textColor: isOpen ? Color(0xFF4CAF50) : Color(0xFFFF5722),
      icon: Icons.access_time,
      text: isOpen ? '영업중입니다' : '현재 휴무 중입니다',
    );
  }

  Widget _buildInfoContainer({
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.gapS),
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
              size: 14.0,
            ),
          ),
          SizedBox(width: AppSizes.gapXS + 2),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
