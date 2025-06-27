import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/service/tourism_api_service.dart';
import '../../../../core/service/transpotation_travel_service.dart';
import '../../../../core/widgets/common_place_detail_bottom_sheet.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../widgets/transportation_recommendation/region_filter_modal.dart';


class TransportationRecommendationPage extends HookConsumerWidget {
  const TransportationRecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = useState(0);
    final isLoading = useState(false);
    final places = useState<List<NearbyPlace>>([]);
    final error = useState<String?>(null);
    final selectedRegion = useState<String?>(null);
    final selectedRegionName = useState<String>('내 주변');

    // 교통수단별 설정
    final tabs = [
      _TransportationTab(
        icon: Icons.directions_walk,
        label: '도보',
        color: Color(0xFF66BB6A),
      ),
      _TransportationTab(
        icon: Icons.train,
        label: '대중교통',
        color: Color(0xFF42A5F5),
      ),
      _TransportationTab(
        icon: Icons.directions_car,
        label: '드라이브',
        color: Color(0xFFAB47BC),
      ),
      _TransportationTab(
        icon: Icons.directions_bike,
        label: '자전거',
        color: Color(0xFFFF7043),
      ),
    ];

    // 탭 변경시 또는 지역 변경시 API 호출
    useEffect(() {
      Future<void> loadPlaces() async {
        if (isLoading.value) return;

        isLoading.value = true;
        error.value = null;

        try {
          final currentTab = tabs[selectedTabIndex.value];

          print('🔄 ${currentTab.label} 여행지 로딩 시작... (지역: ${selectedRegionName.value})');

          final apiPlaces = await TransportationTravelService.fetchPlacesByTransportation(
            transportation: currentTab.label,
            areaCode: selectedRegion.value ?? '6',
            maxResults: 6,
          );

          places.value = apiPlaces;

          print('✅ ${currentTab.label}: ${apiPlaces.length}개 여행지 로드 완료');

        } catch (e) {
          print('❌ ${tabs[selectedTabIndex.value].label} API 조회 실패: $e');
          error.value = '데이터를 불러오는데 실패했습니다.';
          places.value = [];
        } finally {
          isLoading.value = false;
        }
      }

      loadPlaces();
      return null;
    }, [selectedTabIndex.value, selectedRegion.value]);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 커스텀 헤더
          CustomHeaderBar(
            title: selectedRegion.value != null
                ? '${selectedRegionName.value} 교통편별 여행지'
                : '교통편별 여행지',
            backgroundColor: AppColors.background,
            showFilterButton: true,
            onFilterPressed: () {
              _showRegionFilter(
                context,
                selectedRegion,
                selectedRegionName,
              );
            },
          ),

          // 탭 버튼들
          _buildTabButtons(tabs, selectedTabIndex),

          // 선택된 탭의 내용
          Expanded(
            child: isLoading.value
                ? _buildLoadingWidget()
                : error.value != null
                ? _buildErrorWidget(error.value!, () {
              selectedTabIndex.value = selectedTabIndex.value;
            })
                : _buildTabContent(tabs[selectedTabIndex.value], places.value, selectedRegionName.value, context),
          ),
        ],
      ),
    );
  }

  // 지역 필터 모달 표시
  void _showRegionFilter(
      BuildContext context,
      ValueNotifier<String?> selectedRegion,
      ValueNotifier<String> selectedRegionName,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RegionFilterModal(
        selectedRegion: selectedRegion.value,
        onRegionSelected: (String? regionCode, String regionName) {
          selectedRegion.value = regionCode;
          selectedRegionName.value = regionName;
          print('🌍 지역 변경: $regionName ($regionCode)');
        },
      ),
    );
  }

  // 장소 상세 바텀시트 표시
  void _showPlaceDetail(BuildContext context, NearbyPlace place, Color accentColor) {
    // NearbyPlace를 PlaceDetailData로 변환
    final placeData = PlaceDetailData(
      name: place.name,
      description: place.description.isNotEmpty ? place.description : place.reason,
      location: place.address,
      distance: _parseDistance(place.distance),
      rating: place.rating > 0 ? place.rating : null,
      category: _getCategoryDisplayName(place.category),
      categoryGradient: LinearGradient(
        colors: [accentColor, accentColor.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      categoryIcon: _getCategoryIcon(place.category),
      categoryColor: accentColor,
      contentId: place.contentId,
      areaCode: place.areaCode,
      sigunguCode: place.sigunguCode,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXL),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(AppSizes.gapL),
            child: CommonPlaceDetailBottomSheet(
              placeData: placeData,
              showCrowdingInfo: true,
              showLocationSection: true,
            ),
          ),
        ),
      ),
    );
  }

  // 거리 문자열을 double로 변환
  double? _parseDistance(String distanceStr) {
    if (distanceStr.isEmpty) return null;

    // "도보 15분", "자전거 20분", "2.5km" 등에서 숫자 추출
    final RegExp regex = RegExp(r'(\d+\.?\d*)');
    final match = regex.firstMatch(distanceStr);

    if (match != null) {
      final value = double.tryParse(match.group(1)!);
      if (distanceStr.contains('분')) {
        // 분 단위를 km로 변환 (대략적)
        return value != null ? value / 20 : null; // 20분 = 1km로 가정
      }
      return value;
    }
    return null;
  }

  // 카테고리 표시명 변환
  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'tourist_spot': return '관광지';
      case 'culture': return '문화시설';
      case 'leisure': return '레포츠';
      case 'shopping': return '쇼핑';
      case 'restaurant': return '음식점';
      case 'accommodation': return '숙박';
      case 'festival': return '축제/행사';
      case 'course': return '여행코스';
      default: return '일반';
    }
  }

  // 카테고리 아이콘 반환
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'tourist_spot': return Icons.place;
      case 'culture': return Icons.museum;
      case 'leisure': return Icons.sports_soccer;
      case 'shopping': return Icons.shopping_bag;
      case 'restaurant': return Icons.restaurant;
      case 'accommodation': return Icons.hotel;
      case 'festival': return Icons.celebration;
      case 'course': return Icons.route;
      default: return Icons.location_on;
    }
  }

  // 로딩 위젯
  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: AppSizes.gapM),
          Text(
            '맞춤 여행지를 찾고 있습니다...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '잠시만 기다려주세요',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 에러 위젯
  Widget _buildErrorWidget(String errorMessage, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.gapXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSizes.gapL),
            Text(
              '연결에 문제가 발생했습니다',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapXL),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.gapL,
                  vertical: AppSizes.gapM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButtons(List<_TransportationTab> tabs, ValueNotifier<int> selectedTabIndex) {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapL),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedTabIndex.value == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (selectedTabIndex.value != index) {
                  selectedTabIndex.value = index;
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppSizes.gapXS),
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.gapM,
                  horizontal: AppSizes.gapS,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? tab.color : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: tab.color.withOpacity(0.3),
                      blurRadius: AppSizes.elevationM,
                      offset: Offset(0, 4),
                    ),
                  ] : [
                    BoxShadow(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      blurRadius: AppSizes.elevationS,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      tab.icon,
                      color: isSelected ? AppColors.white : tab.color,
                      size: 24,
                    ),
                    SizedBox(height: AppSizes.gapXS),
                    Text(
                      tab.label,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? AppColors.white : tab.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(_TransportationTab tab, List<NearbyPlace> places, String regionName, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.gapL),
            decoration: BoxDecoration(
              color: tab.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: tab.color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(
                    tab.icon,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tab.label}${_getParticle(tab.label)} 떠나는 여행',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSizes.gapXS),
                      Text(
                        _getTabDescription(tab.label),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.gapL),

          // 데이터 상태별 표시
          if (places.isEmpty)
            _buildEmptyState()
          else ...[
            // 결과 요약
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.gapM,
                vertical: AppSizes.gapS,
              ),
              decoration: BoxDecoration(
                color: tab.color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: tab.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: tab.color,
                  ),
                  SizedBox(width: AppSizes.gapS),
                  Text(
                    '$regionName에서 ${tab.label}에 적합한 ${places.length}곳',
                    style: AppTextStyles.caption.copyWith(
                      color: tab.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.gapM),

            // 장소 리스트
            ...places.map((place) => _buildPlaceCard(place, tab.color, context)).toList(),
          ],

          SizedBox(height: AppSizes.gapXL),
        ],
      ),
    );
  }

  // 빈 상태 위젯
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapXL),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: AppSizes.gapL),
          Text(
            '조건에 맞는 여행지를\n찾을 수 없습니다',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSizes.gapS),
          Text(
            '다른 교통수단이나 지역을 선택해보세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(NearbyPlace place, Color accentColor, BuildContext context) {
    return GestureDetector(
      onTap: () => _showPlaceDetail(context, place, accentColor),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSizes.gapM),
        padding: EdgeInsets.all(AppSizes.gapL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.1),
              blurRadius: AppSizes.elevationS,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              place.name,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: AppSizes.gapS),

            // 주소
            if (place.address.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: accentColor,
                  ),
                  SizedBox(width: AppSizes.gapXS),
                  Expanded(
                    child: Text(
                      place.address,
                      style: AppTextStyles.caption.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // 거리 정보
            if (place.distance.isNotEmpty) ...[
              SizedBox(height: AppSizes.gapXS),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSizes.gapXS),
                  Text(
                    place.distance,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            // 설명 또는 추천 이유
            if (place.description.isNotEmpty || place.reason.isNotEmpty) ...[
              SizedBox(height: AppSizes.gapS),
              Container(
                padding: EdgeInsets.all(AppSizes.gapS),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  place.reason.isNotEmpty ? place.reason : place.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],

            // 팁
            if (place.tip.isNotEmpty) ...[
              SizedBox(height: AppSizes.gapS),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 14,
                    color: Colors.orange,
                  ),
                  SizedBox(width: AppSizes.gapXS),
                  Expanded(
                    child: Text(
                      place.tip,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getParticle(String label) {
    return label == '대중교통' ? '으로' : '로';
  }

  String _getTabDescription(String label) {
    switch (label) {
      case '도보':
        return '걸어서 즐기기 좋은 공원과 거리';
      case '대중교통':
        return '지하철·버스로 편리하게 갈 수 있는 명소';
      case '드라이브':
        return '경치 좋은 드라이브 코스와 전망대';
      case '자전거':
        return '자전거 전용도로와 라이딩 코스';
      default:
        return '';
    }
  }
}

// 교통수단 탭 모델
class _TransportationTab {
  final IconData icon;
  final String label;
  final Color color;

  const _TransportationTab({
    required this.icon,
    required this.label,
    required this.color,
  });
}
