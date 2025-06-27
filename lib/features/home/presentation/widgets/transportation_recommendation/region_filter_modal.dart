import 'package:flutter/material.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/service/tourism_api_service.dart';

class RegionFilterModal extends StatefulWidget {
  final String? selectedRegion;
  final Function(String?, String) onRegionSelected;

  const RegionFilterModal({
    Key? key,
    this.selectedRegion,
    required this.onRegionSelected,
  }) : super(key: key);

  @override
  State<RegionFilterModal> createState() => _RegionFilterModalState();
}

class _RegionFilterModalState extends State<RegionFilterModal> {
  String? tempSelectedRegion;
  String tempSelectedRegionName = '내 주변';
  List<AreaCodeInfo> regions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    tempSelectedRegion = widget.selectedRegion;
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('🌍 지역코드 API 조회 시작...');

      // API에서 실제 지역코드 조회
      final apiRegions = await TourismApiService.fetchAreaCodes();

      // 내 주변 옵션을 맨 앞에 추가
      final allRegions = [
        AreaCodeInfo(code: null, name: '내 주변'),
        ...apiRegions,
      ];

      setState(() {
        regions = allRegions;
        isLoading = false;
      });

      print('✅ 총 ${regions.length}개 지역 로드 완료');

      // 현재 선택된 지역의 이름 찾기
      if (tempSelectedRegion != null) {
        final foundRegion = regions.firstWhere(
              (region) => region.code == tempSelectedRegion,
          orElse: () => AreaCodeInfo(code: null, name: '내 주변'),
        );
        tempSelectedRegionName = foundRegion.name;
      }

    } catch (e) {
      print('❌ 지역코드 조회 실패: $e');
      setState(() {
        error = '지역 정보를 불러올 수 없습니다.';
        isLoading = false;
        // 오류시 기본 지역들 사용
        regions = _getDefaultRegions();
      });
    }
  }

  // API 실패시 사용할 기본 지역 목록
  List<AreaCodeInfo> _getDefaultRegions() {
    return [
      AreaCodeInfo(code: null, name: '내 주변'),
      AreaCodeInfo(code: '1', name: '서울특별시'),
      AreaCodeInfo(code: '6', name: '부산광역시'),
      AreaCodeInfo(code: '2', name: '인천광역시'),
      AreaCodeInfo(code: '3', name: '대구광역시'),
      AreaCodeInfo(code: '4', name: '광주광역시'),
      AreaCodeInfo(code: '5', name: '대전광역시'),
      AreaCodeInfo(code: '7', name: '울산광역시'),
      AreaCodeInfo(code: '8', name: '세종특별자치시'),
      AreaCodeInfo(code: '31', name: '경기도'),
      AreaCodeInfo(code: '32', name: '강원도'),
      AreaCodeInfo(code: '33', name: '충청북도'),
      AreaCodeInfo(code: '34', name: '충청남도'),
      AreaCodeInfo(code: '35', name: '전라북도'),
      AreaCodeInfo(code: '36', name: '전라남도'),
      AreaCodeInfo(code: '37', name: '경상북도'),
      AreaCodeInfo(code: '38', name: '경상남도'),
      AreaCodeInfo(code: '39', name: '제주특별자치도'),
    ];
  }

  String _getRegionDescription(String regionName) {
    switch (regionName) {
      case '내 주변': return '현재 위치 기준';
      case '서울특별시': return '수도권 관광명소';
      case '부산광역시': return '해변과 항구도시';
      case '인천광역시': return '공항과 차이나타운';
      case '대구광역시': return '전통문화의 도시';
      case '광주광역시': return '예술과 문화의 도시';
      case '대전광역시': return '과학기술의 중심';
      case '울산광역시': return '산업도시와 자연';
      case '세종특별자치시': return '행정중심복합도시';
      case '경기도': return '다양한 테마파크';
      case '강원도': return '산과 바다의 자연';
      case '충청북도': return '내륙의 자연명소';
      case '충청남도': return '역사와 온천';
      case '전라북도': return '전통문화 유산';
      case '전라남도': return '섬과 해안절경';
      case '경상북도': return '고도와 문화재';
      case '경상남도': return '자연과 산업';
      case '제주특별자치도': return '화산섬의 비경';
      default: return '다양한 관광명소';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // 핸들바
          Container(
            margin: EdgeInsets.only(top: AppSizes.gapM),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: EdgeInsets.all(AppSizes.gapL),
            child: Row(
              children: [
                Text(
                  '지역 선택',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                if (!isLoading) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        tempSelectedRegion = null;
                        tempSelectedRegionName = '내 주변';
                      });
                    },
                    child: Text(
                      '전체',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(
            color: AppColors.textSecondary.withOpacity(0.1),
            thickness: 1,
          ),

          // 콘텐츠
          Expanded(
            child: isLoading
                ? _buildLoadingWidget()
                : error != null
                ? _buildErrorWidget()
                : _buildRegionList(),
          ),

          // 하단 버튼
          if (!isLoading && error == null) _buildBottomButtons(),
        ],
      ),
    );
  }

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
            '지역 정보를 불러오고 있습니다...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.gapL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              error!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapL),
            ElevatedButton(
              onPressed: _loadRegions,
              child: Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        final isSelected = tempSelectedRegion == region.code;

        return Container(
          margin: EdgeInsets.only(bottom: AppSizes.gapS),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  tempSelectedRegion = region.code;
                  tempSelectedRegionName = region.name;
                });
                print('🎯 지역 선택: ${region.name} (${region.code})');
              },
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // 지역 아이콘
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Icon(
                        region.code == null
                            ? Icons.my_location
                            : Icons.location_city,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),

                    SizedBox(width: AppSizes.gapM),

                    // 지역 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            region.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppSizes.gapXS),
                          Text(
                            _getRegionDescription(region.name),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 선택 표시
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapL),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.gapM),
                side: BorderSide(color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                '취소',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(width: AppSizes.gapM),

          // 적용 버튼
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                print('✅ 지역 선택 확정: $tempSelectedRegionName ($tempSelectedRegion)');
                widget.onRegionSelected(tempSelectedRegion, tempSelectedRegionName);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.gapM),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
              ),
              child: Text(
                '적용하기',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
