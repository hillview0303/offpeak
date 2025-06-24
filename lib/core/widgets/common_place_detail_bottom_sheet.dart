import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/favorite_heart_widget.dart';

// 공통으로 사용할 장소 데이터 모델
class PlaceDetailData {
  final String name;
  final String? description;
  final String? location;
  final double? distance;
  final double? rating;
  final String category;
  final LinearGradient? categoryGradient;
  final IconData? categoryIcon;
  final Color? categoryColor;

  PlaceDetailData({
    required this.name,
    this.description,
    this.location,
    this.distance,
    this.rating,
    required this.category,
    this.categoryGradient,
    this.categoryIcon,
    this.categoryColor,
  });

  // 기존 Map 데이터에서 변환
  factory PlaceDetailData.fromMap(
      Map<String, dynamic> place, {
        required String category,
        LinearGradient? categoryGradient,
        IconData? categoryIcon,
        Color? categoryColor,
      }) {
    return PlaceDetailData(
      name: place['name'] ?? '',
      description: place['description'],
      location: place['location'],
      distance: place['distance']?.toDouble(),
      rating: place['rating']?.toDouble(),
      category: category,
      categoryGradient: categoryGradient,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
    );
  }

  // 위클리 추천 데이터에서 변환
  factory PlaceDetailData.fromWeeklyRecommendation({
    required String title,
    required String subtitle,
    required String category,
    required IconData categoryIcon,
    String? location,
    double? distance,
  }) {
    return PlaceDetailData(
      name: title,
      description: subtitle,
      location: location ?? '정확한 위치 정보를 확인해주세요',
      distance: distance ?? 0.0,
      category: category,
      categoryIcon: categoryIcon,
      categoryColor: AppColors.secondary,
      categoryGradient: LinearGradient(
        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

class CommonPlaceDetailBottomSheet extends StatelessWidget {
  final PlaceDetailData placeData;
  final bool showCrowdingInfo;
  final bool showLocationSection;

  const CommonPlaceDetailBottomSheet({
    Key? key,
    required this.placeData,
    this.showCrowdingInfo = true,
    this.showLocationSection = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 섹션
        _buildHeaderSection(isTablet),

        SizedBox(height: AppSizes.gapL),

        // 혼잡도 정보 (옵션)
        if (showCrowdingInfo) ...[
          _buildCrowdingSection(),
          SizedBox(height: AppSizes.gapL),
        ],

        // 장소 설명
        if (placeData.description != null) ...[
          _buildDescriptionSection(),
          SizedBox(height: AppSizes.gapL),
        ],

        // 위치 정보 (옵션)
        if (showLocationSection && placeData.location != null) ...[
          _buildLocationSection(context),
          SizedBox(height: AppSizes.gapL),
        ],

        // 추가 정보 (카테고리별 맞춤 정보)
        _buildCategorySpecificInfo(),

        SizedBox(height: AppSizes.gapXL),
      ],
    );
  }

  Widget _buildHeaderSection(bool isTablet) {
    return Container(
      height: 180,
      child: Row(
        children: [
          // 장소 이미지 placeholder
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              gradient: placeData.categoryGradient ?? LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Icon(
              placeData.categoryIcon ?? Icons.place,
              color: AppColors.white,
              size: AppSizes.iconXL,
            ),
          ),

          SizedBox(width: AppSizes.gapL),

          // 장소 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목과 하트
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        placeData.name,
                        style: isTablet ? AppTextStyles.h2 : AppTextStyles.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppSizes.gapS),
                    FavoriteHeartWidget(
                      contentId: placeData.name,
                      contentTitle: placeData.name,
                      isTablet: isTablet,
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.gapM),

                // 카테고리 태그
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.gapS,
                    vertical: AppSizes.gapXS,
                  ),
                  decoration: BoxDecoration(
                    color: (placeData.categoryColor ?? AppColors.primary).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Text(
                    placeData.category,
                    style: AppTextStyles.caption.copyWith(
                      color: placeData.categoryColor ?? AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(height: AppSizes.gapS),

                // 거리 정보 (있을 때만)
                if (placeData.distance != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: AppColors.grey,
                        size: 16,
                      ),
                      SizedBox(width: AppSizes.gapXS),
                      Text(
                        '${placeData.distance!.toStringAsFixed(1)}km 거리',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdingSection() {
    final crowdingLevel = _getCrowdingLevel();
    final crowdingData = _getCrowdingData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '혼잡도 정보',
          style: AppTextStyles.h4.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.gapS),

        // 현재 혼잡도
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.gapM),
          decoration: BoxDecoration(
            color: _getCrowdingColor(crowdingLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: _getCrowdingColor(crowdingLevel).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCrowdingIcon(crowdingLevel),
                    color: _getCrowdingColor(crowdingLevel),
                    size: AppSizes.iconM,
                  ),
                  SizedBox(width: AppSizes.gapS),
                  Text(
                    '현재 ${_getCrowdingText(crowdingLevel)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getCrowdingColor(crowdingLevel),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.gapXS),
              Text(
                _getCrowdingDescription(crowdingLevel),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: AppSizes.gapM),

        // 방문자 통계
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: AppColors.success,
                      size: AppSizes.iconS + 2,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      '${crowdingData['lastWeekVisitors']}명',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '지난주 방문자',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: AppSizes.gapS),

            Expanded(
              child: Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.warning,
                      size: AppSizes.iconS + 2,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      '${crowdingData['expectedVisitors']}명',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '이번주 예상',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: AppSizes.gapS),

        // 방문 추천 시간
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.gapS),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.primary,
                size: AppSizes.iconS,
              ),
              SizedBox(width: AppSizes.gapXS),
              Text(
                '추천 방문 시간: ${crowdingData['bestTime']}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '장소 소개',
          style: AppTextStyles.h4.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.gapS),
        Text(
          placeData.description!,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 정보',
          style: AppTextStyles.h4.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.gapS),
        Container(
          padding: EdgeInsets.all(AppSizes.gapM),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: AppSizes.iconM,
                  ),
                  SizedBox(width: AppSizes.gapM),
                  Expanded(
                    child: Text(
                      placeData.location!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSizes.gapM),

              Container(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => _openMap(context, placeData.location!),
                  icon: Icon(
                    Icons.directions,
                    size: AppSizes.iconS,
                  ),
                  label: Text(
                    '길찾기',
                    style: AppTextStyles.buttonMedium,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySpecificInfo() {
    // 카테고리별 특별한 정보 표시
    switch (placeData.category.toLowerCase()) {
      case '사찰':
      case 'temple':
        return _buildTempleInfo();
      case '자연':
      case 'nature':
        return _buildNatureInfo();
      case '역사':
      case 'historical':
        return _buildHistoricalInfo();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildTempleInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.temple_buddhist, color: AppColors.primary, size: AppSizes.iconS),
              SizedBox(width: AppSizes.gapS),
              Text(
                '사찰 방문 안내',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '• 조용한 마음으로 방문해주세요\n• 법당 내 사진 촬영은 금지됩니다\n• 편안한 복장을 권장합니다',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNatureInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.landscape, color: AppColors.success, size: AppSizes.iconS),
              SizedBox(width: AppSizes.gapS),
              Text(
                '자연 관광 팁',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '• 날씨에 따른 적절한 복장 준비\n• 자연 보호를 위해 쓰레기는 되가져가세요\n• 안전한 관람을 위해 지정된 길을 이용해주세요',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: AppColors.warning, size: AppSizes.iconS),
              SizedBox(width: AppSizes.gapS),
              Text(
                '문화재 관람 안내',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '• 문화재 보호를 위해 만지지 말아주세요\n• 해설사 프로그램을 이용하시면 더욱 유익합니다\n• 조용한 관람으로 다른 방문객을 배려해주세요',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 지도 앱 선택 및 열기
  Future<void> _openMap(BuildContext context, String address) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXL),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: AppSizes.gapS),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(AppSizes.gapL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '지도 앱 선택',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: AppSizes.gapL),

                        _buildMapOption(
                          context,
                          title: 'Google Maps',
                          subtitle: '구글 지도에서 열기',
                          icon: Icons.map,
                          color: Color(0xFF4285F4),
                          onTap: () => _launchGoogleMaps(address),
                        ),

                        SizedBox(height: AppSizes.gapS),

                        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                          _buildMapOption(
                            context,
                            title: 'Apple Maps',
                            subtitle: '애플 지도에서 열기',
                            icon: Icons.location_on,
                            color: Color(0xFF007AFF),
                            onTap: () => _launchAppleMaps(address),
                          ),
                          SizedBox(height: AppSizes.gapS),
                        ],

                        _buildMapOption(
                          context,
                          title: 'Kakao Map',
                          subtitle: '카카오맵에서 열기',
                          icon: Icons.location_city,
                          color: Color(0xFFFEE500),
                          onTap: () => _launchKakaoMap(address),
                        ),

                        SizedBox(height: AppSizes.gapS),

                        _buildMapOption(
                          context,
                          title: 'Naver Map',
                          subtitle: '네이버 지도에서 열기',
                          icon: Icons.navigation,
                          color: Color(0xFF03C75A),
                          onTap: () => _launchNaverMap(address),
                        ),

                        SizedBox(height: AppSizes.gapL),

                        Container(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: AppSizes.gapM),
                            ),
                            child: Text(
                              '취소',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: Container(
        padding: EdgeInsets.all(AppSizes.gapM),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Icon(icon, color: color, size: AppSizes.iconM),
            ),
            SizedBox(width: AppSizes.gapM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // 지도 앱 실행 함수들
  Future<void> _launchGoogleMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Google Maps를 열 수 없습니다: $e');
    }
  }

  Future<void> _launchAppleMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'http://maps.apple.com/?q=$encodedAddress';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Apple Maps를 열 수 없습니다: $e');
    }
  }

  Future<void> _launchKakaoMap(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final kakaoMapUrl = 'kakaomap://search?q=$encodedAddress';
    final webUrl = 'https://map.kakao.com/link/search/$encodedAddress';
    try {
      if (await canLaunchUrl(Uri.parse(kakaoMapUrl))) {
        await launchUrl(Uri.parse(kakaoMapUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Kakao Map을 열 수 없습니다: $e');
    }
  }

  Future<void> _launchNaverMap(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final naverMapUrl = 'nmap://search?query=$encodedAddress';
    final webUrl = 'https://map.naver.com/v5/search/$encodedAddress';
    try {
      if (await canLaunchUrl(Uri.parse(naverMapUrl))) {
        await launchUrl(Uri.parse(naverMapUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Naver Map을 열 수 없습니다: $e');
    }
  }

  // 혼잡도 관련 함수들
  String _getCrowdingLevel() {
    if (placeData.distance != null) {
      final distance = placeData.distance!;
      if (distance <= 1.0) return 'medium';
      if (distance <= 2.0) return 'low';
      return 'very_low';
    }
    return 'low';
  }

  Map<String, dynamic> _getCrowdingData() {
    final crowdingLevel = _getCrowdingLevel();
    switch (crowdingLevel) {
      case 'very_low':
        return {
          'lastWeekVisitors': 120,
          'expectedVisitors': 95,
          'bestTime': '평일 오전 10-12시',
        };
      case 'low':
        return {
          'lastWeekVisitors': 280,
          'expectedVisitors': 220,
          'bestTime': '평일 오후 2-4시',
        };
      case 'medium':
        return {
          'lastWeekVisitors': 450,
          'expectedVisitors': 380,
          'bestTime': '평일 오전 9-11시',
        };
      default:
        return {
          'lastWeekVisitors': 150,
          'expectedVisitors': 120,
          'bestTime': '평일 오전',
        };
    }
  }

  Color _getCrowdingColor(String level) {
    switch (level) {
      case 'very_low': return AppColors.success;
      case 'low': return Color(0xFF7CB342);
      case 'medium': return AppColors.warning;
      case 'high': return AppColors.error;
      default: return AppColors.success;
    }
  }

  IconData _getCrowdingIcon(String level) {
    switch (level) {
      case 'very_low': return Icons.sentiment_very_satisfied;
      case 'low': return Icons.sentiment_satisfied;
      case 'medium': return Icons.sentiment_neutral;
      case 'high': return Icons.sentiment_dissatisfied;
      default: return Icons.sentiment_very_satisfied;
    }
  }

  String _getCrowdingText(String level) {
    switch (level) {
      case 'very_low': return '매우 한적함';
      case 'low': return '한적함';
      case 'medium': return '보통';
      case 'high': return '혼잡함';
      default: return '한적함';
    }
  }

  String _getCrowdingDescription(String level) {
    switch (level) {
      case 'very_low': return '지금이 방문하기 최적의 시간입니다';
      case 'low': return '조용하고 편안한 환경에서 관람 가능합니다';
      case 'medium': return '적당한 인원이 있지만 여전히 쾌적합니다';
      case 'high': return '다른 시간대 방문을 권장드립니다';
      default: return '조용한 환경에서 관람 가능합니다';
    }
  }
}
