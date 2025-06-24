import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/custom_header_bar.dart';

class TransportationRecommendationPage extends HookConsumerWidget {
  const TransportationRecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = useState(0);

    final tabs = [
      _TransportationTab(
        icon: Icons.directions_walk,
        label: '도보',
        color: Color(0xFF66BB6A), // 연한 그린
        places: [
          _TransportationPlace('한강공원', '여의도·반포 일대'),
          _TransportationPlace('명동거리', '중구 명동'),
          _TransportationPlace('홍대 걷고싶은거리', '마포구 홍대'),
          _TransportationPlace('청계천', '종로구·중구'),
        ],
      ),
      _TransportationTab(
        icon: Icons.train,
        label: '대중교통',
        color: Color(0xFF42A5F5), // 스카이 블루
        places: [
          _TransportationPlace('경복궁', '지하철 3호선 경복궁역'),
          _TransportationPlace('롯데월드타워', '지하철 2,8호선 잠실역'),
          _TransportationPlace('동대문디자인플라자', '지하철 2,4,5호선 동대문역사문화공원역'),
          _TransportationPlace('남산서울타워', '지하철 4호선 명동역 + 케이블카'),
        ],
      ),
      _TransportationTab(
        icon: Icons.directions_car,
        label: '드라이브',
        color: Color(0xFFAB47BC), // 퍼플
        places: [
          _TransportationPlace('올림픽대로', '한강변 드라이브 코스'),
          _TransportationPlace('남한산성', '경기도 광주시'),
          _TransportationPlace('가평 자라섬', '경기도 가평군'),
          _TransportationPlace('강화도', '인천광역시 강화군'),
        ],
      ),
      _TransportationTab(
        icon: Icons.directions_bike,
        label: '자전거',
        color: Color(0xFFFF7043), // 오렌지
        places: [
          _TransportationPlace('한강 자전거길', '한강공원 전 구간'),
          _TransportationPlace('청계천 자전거길', '종로구·중구'),
          _TransportationPlace('잠실 석촌호수', '송파구 잠실'),
          _TransportationPlace('여의도 한강공원', '영등포구 여의도'),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 커스텀 헤더
          CustomHeaderBar(
            title: '교통편별 여행지',
            backgroundColor: AppColors.background,
          ),

          // 탭 버튼들
          _buildTabButtons(tabs, selectedTabIndex),

          // 선택된 탭의 내용
          Expanded(
            child: _buildTabContent(tabs[selectedTabIndex.value]),
          ),
        ],
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
              onTap: () => selectedTabIndex.value = index,
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

  Widget _buildTabContent(_TransportationTab tab) {
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

          // 장소 리스트
          ...tab.places.map((place) => _buildPlaceCard(place, tab.color)).toList(),

          SizedBox(height: AppSizes.gapXL),
        ],
      ),
    );
  }

  String _getParticle(String label) {
    return label == '대중교통' ? '으로' : '로';
  }

  String _getTabDescription(String label) {
    switch (label) {
      case '도보':
        return '산책하기 좋은 명소와 거리';
      case '대중교통':
        return '지하철·버스로 접근 가능한 관광 명소';
      case '드라이브':
        return '드라이브 코스와 교외 명소';
      case '자전거':
        return '자전거도로와 라이딩 코스';
      default:
        return '';
    }
  }

  Widget _buildPlaceCard(_TransportationPlace place, Color accentColor) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSizes.gapXS),
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
                        place.location,
                        style: AppTextStyles.caption.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 교통수단 탭 모델
class _TransportationTab {
  final IconData icon;
  final String label;
  final Color color;
  final List<_TransportationPlace> places;

  const _TransportationTab({
    required this.icon,
    required this.label,
    required this.color,
    required this.places,
  });
}

// 교통수단별 장소 모델
class _TransportationPlace {
  final String name;
  final String location;

  const _TransportationPlace(this.name, this.location);
}
