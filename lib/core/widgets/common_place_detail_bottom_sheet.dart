import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/favorite_heart_widget.dart';
import '../../../../core/service/tourism_api_service.dart';
import '../../features/home/presentation/providers/recommendation_model.dart';

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
  final String? contentId; // 🔧 추가: API 조회용 ID
  // 🔧 추가: 혼잡도 API용 지역코드
  final String? areaCode;
  final String? sigunguCode;

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
    this.contentId,
    this.areaCode,
    this.sigunguCode,
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
      contentId: place['id'], // 🔧 추가: contentId 매핑
      areaCode: place['areaCode'],        // 🔧 추가
      sigunguCode: place['sigunguCode'],  // 🔧 추가
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

class CommonPlaceDetailBottomSheet extends StatefulWidget {
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
  State<CommonPlaceDetailBottomSheet> createState() => _CommonPlaceDetailBottomSheetState();
}

class _CommonPlaceDetailBottomSheetState extends State<CommonPlaceDetailBottomSheet> {
  Future<List<String>>? _imagesFuture;
  Future<PlaceDetail?>? _detailFuture;
  Future<CongestionData?>? _congestionFuture; // 🔧 추가: 혼잡도 데이터

  @override
  void initState() {
    super.initState();
    print('🔍 바텀시트 초기화: contentId = ${widget.placeData.contentId}');
    if (widget.placeData.contentId != null && widget.placeData.contentId!.isNotEmpty) {
      print('📸 이미지 로드 시작: ${widget.placeData.contentId}');
      _imagesFuture = TourismApiService.fetchPlaceImages(widget.placeData.contentId!);
      _detailFuture = TourismApiService.fetchPlaceDetail(widget.placeData.contentId!);

      // 🔧 수정: 주소 정보를 추가로 전달
      print('📊 혼잡도 정보 로드 시작: ${widget.placeData.contentId}');
      print('🗺️ 지역코드 정보: areaCode=${widget.placeData.areaCode}, sigunguCode=${widget.placeData.sigunguCode}');
      print('📍 주소 정보: ${widget.placeData.location}');

      _congestionFuture = TourismApiService.fetchCongestionData(
        contentId: widget.placeData.contentId!,
        areaCode: widget.placeData.areaCode,
        sigunguCode: widget.placeData.sigunguCode,
        touristSpotName: widget.placeData.name, // 관광지명으로 사용
        address: widget.placeData.location, // 🔧 추가: 주소 정보 전달
      );
    } else {
      print('⚠️ contentId가 없어서 API 호출 생략');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔧 새로운 헤더: 뱃지 + 장소명
        _buildNewHeader(),

        SizedBox(height: AppSizes.gapL),

        // 🔧 장소 사진
        _buildPlaceImages(),

        SizedBox(height: AppSizes.gapL),

        // 🔧 장소 소개 (API 데이터)
        _buildPlaceIntroduction(),

        SizedBox(height: AppSizes.gapL),

        // 🔧 상세 정보 (혼잡도 위쪽으로 이동)
        _buildDetailedInfo(),

        SizedBox(height: AppSizes.gapL),

        // 기존 혼잡도 정보 (아래쪽 유지)
        if (widget.showCrowdingInfo) _buildCrowdingSection(),

        if (widget.showCrowdingInfo) SizedBox(height: AppSizes.gapL),

        // 기존 위치 섹션 (가장 아래)
        if (widget.showLocationSection && widget.placeData.location != null)
          _buildLocationSection(context),

        SizedBox(height: AppSizes.gapXL),
      ],
    );
  }

  // 🔧 새로운 헤더 (핸들 제거, 뱃지 + 장소명)
  Widget _buildNewHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // XX투어 뱃지
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.gapM,
                vertical: AppSizes.gapS,
              ),
              decoration: BoxDecoration(
                gradient: widget.placeData.categoryGradient ?? LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.placeData.categoryIcon ?? Icons.place,
                    color: AppColors.white,
                    size: AppSizes.iconS,
                  ),
                  const SizedBox(width: AppSizes.gapS),
                  Text(
                    widget.placeData.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // 하트
            FavoriteHeartWidget(
              contentId: widget.placeData.contentId ?? widget.placeData.name,
              contentTitle: widget.placeData.name,
              isTablet: false,
            ),
          ],
        ),

        const SizedBox(height: AppSizes.gapL),

        // 장소명
        Text(
          widget.placeData.name,
          style: AppTextStyles.h2.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 🔧 장소 사진
  Widget _buildPlaceImages() {
    if (_imagesFuture == null) {
      return _buildImagePlaceholder();
    }

    return Container(
      height: 200,
      child: FutureBuilder<List<String>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: widget.placeData.categoryGradient?.colors.first ?? AppColors.primary,
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildImagePlaceholder();
          }

          final images = snapshot.data!;
          if (images.length == 1) {
            // 이미지 1개
            return ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              child: Image.network(
                images.first,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            );
          } else {
            // 이미지 여러 개 (스크롤 가능)
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    right: index < images.length - 1 ? AppSizes.gapM : 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      width: 280,
                      height: 200,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // 이미지 플레이스홀더
  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: (widget.placeData.categoryGradient ?? LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        )),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.placeData.categoryIcon ?? Icons.place,
              size: 48,
              color: AppColors.white.withOpacity(0.8),
            ),
            const SizedBox(height: AppSizes.gapS),
            Text(
              '이미지 준비 중',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 장소 소개 (API 데이터)
  Widget _buildPlaceIntroduction() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '장소 소개',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.gapM),

        if (_detailFuture != null)
          FutureBuilder<PlaceDetail?>(
            future: _detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: widget.placeData.categoryGradient?.colors.first ?? AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              String description = widget.placeData.description ?? '';
              if (snapshot.hasData &&
                  snapshot.data!.description.isNotEmpty) {
                description = snapshot.data!.description;
              }

              if (description.isEmpty) {
                description = '이 장소에 대한 자세한 정보를 준비 중입니다.';
              }

              return Container(
                padding: EdgeInsets.all(AppSizes.gapL),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            },
          )
        else
          Container(
            padding: EdgeInsets.all(AppSizes.gapL),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Text(
              widget.placeData.description ?? '이 장소에 대한 자세한 정보를 준비 중입니다.',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
      ],
    );
  }

  // 🔧 상세 정보 (혼잡도 위쪽으로 이동)
  Widget _buildDetailedInfo() {
    if (_detailFuture == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 정보',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.gapM),

        FutureBuilder<PlaceDetail?>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: widget.placeData.categoryGradient?.colors.first ?? AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Container(
                padding: EdgeInsets.all(AppSizes.gapL),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '상세 정보를 불러오는 중입니다...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final detail = snapshot.data!;
            final infoItems = <Widget>[];

            // 전화번호
            if (detail.phone.isNotEmpty && detail.phone != '전화번호 정보 없음') {
              infoItems.add(_buildInfoItem(Icons.phone, '전화번호', detail.phone));
            }

            // 운영시간
            if (detail.hours.isNotEmpty && detail.hours != '운영시간 정보 없음') {
              infoItems.add(_buildInfoItem(Icons.access_time, '운영시간', detail.hours));
            }

            // 주차정보
            if (detail.parking.isNotEmpty && detail.parking != '주차 정보 없음') {
              infoItems.add(_buildInfoItem(Icons.local_parking, '주차정보', detail.parking));
            }

            // 시설정보
            if (detail.facilities.isNotEmpty && detail.facilities != '시설 정보 없음') {
              infoItems.add(_buildInfoItem(Icons.business, '시설정보', detail.facilities));
            }

            if (infoItems.isEmpty) {
              return Container(
                padding: EdgeInsets.all(AppSizes.gapL),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '상세 정보가 준비 중입니다.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            return Container(
              padding: EdgeInsets.all(AppSizes.gapL),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: infoItems.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.gapM),
                  child: item,
                )).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: widget.placeData.categoryGradient?.colors.first ?? AppColors.primary,
          size: AppSizes.iconS,
        ),
        const SizedBox(width: AppSizes.gapM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.gapXS),
              Text(
                content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 기존 메서드들 유지...
  // 🔧 수정: 실제 API 데이터 기반 혼잡도 정보
  Widget _buildCrowdingSection() {
    if (_congestionFuture == null) {
      return _buildFallbackCrowdingSection();
    }

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

        FutureBuilder<CongestionData?>(
          future: _congestionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: widget.placeData.categoryGradient?.colors.first ?? AppColors.primary,
                      ),
                      SizedBox(height: AppSizes.gapM),
                      Text(
                        '혼잡도 정보를 불러오는 중...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              print('❌ 혼잡도 API 오류: ${snapshot.error}');
              return _buildFallbackCrowdingSection();
            }

            final congestionData = snapshot.data;
            if (congestionData == null) {
              print('⚠️ 혼잡도 데이터 없음, 기본값 사용');
              return _buildFallbackCrowdingSection();
            }

            print('✅ 혼잡도 데이터 로드 성공: ${congestionData.currentLevel}%');
            return _buildRealCrowdingSection(congestionData);
          },
        ),
      ],
    );
  }

  // 🔧 실제 API 데이터 기반 혼잡도 표시
  Widget _buildRealCrowdingSection(CongestionData congestionData) {
    final crowdingLevel = _getCrowdingLevelFromPercentage(congestionData.currentLevel);

    return Column(
      children: [
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
                    '현재 ${_getCrowdingText(crowdingLevel)} (${congestionData.currentLevel}%)',
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
              SizedBox(height: AppSizes.gapXS),
              Text(
                '데이터 출처: ${_getDataSourceText(congestionData.dataSource)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: AppSizes.gapM),

        // 방문자 통계 (실제 API 데이터)
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
                      '${congestionData.lastWeekVisitors}명',
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
                      '${congestionData.expectedVisitors}명',
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

        // 방문 추천 시간 (실제 API 데이터)
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
              Expanded(
                child: Text(
                  '추천 방문 시간: ${congestionData.recommendedTime}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (congestionData.peakTime.isNotEmpty) ...[
          SizedBox(height: AppSizes.gapS),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.gapS),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: AppSizes.iconS,
                ),
                SizedBox(width: AppSizes.gapXS),
                Expanded(
                  child: Text(
                    '피크 시간: ${congestionData.peakTime}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 🔧 폴백 혼잡도 섹션 (API 실패시)
  Widget _buildFallbackCrowdingSection() {
    final crowdingLevel = _getCrowdingLevel();
    final crowdingData = _getCrowdingData();

    return Column(
      children: [
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

  Widget _buildLocationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '위치 정보',
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
                      widget.placeData.location!,
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
                  onPressed: () => _openMap(context, widget.placeData.location!),
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

  // 기존 메서드들 유지 (지도 관련, 혼잡도 관련)...
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

  // 🔧 추가: 퍼센트 기반 혼잡도 레벨 계산
  String _getCrowdingLevelFromPercentage(int percentage) {
    if (percentage <= 25) return 'very_low';
    if (percentage <= 50) return 'low';
    if (percentage <= 75) return 'medium';
    return 'high';
  }

  // 🔧 추가: 데이터 출처 텍스트
  String _getDataSourceText(String dataSource) {
    switch (dataSource) {
      case 'local_visitor_api':
        return '지자체 방문자수 데이터';
      case 'regional_visitor_api':
        return '광역지자체 방문자수 데이터';
      case 'prediction':
        return '관광지 집중률 예측 데이터';
      case 'default':
        return '예상 혼잡도';
      default:
        return '혼잡도 분석';
    }
  }

  // 혼잡도 관련 함수들 (기존 유지)
  String _getCrowdingLevel() {
    if (widget.placeData.distance != null) {
      final distance = widget.placeData.distance!;
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
