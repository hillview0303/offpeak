import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/common_place_detail_bottom_sheet.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../../../../core/widgets/common_bottom_sheet.dart';
import '../../../../core/widgets/favorite_heart_widget.dart';

class QuietActivitiesDetailPage extends HookConsumerWidget {
  final String categoryTitle;
  final String categoryType;
  final LinearGradient categoryGradient;
  final IconData categoryIcon;

  const QuietActivitiesDetailPage({
    Key? key,
    required this.categoryTitle,
    required this.categoryType,
    required this.categoryGradient,
    required this.categoryIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNearbyOnly = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 커스텀 헤더 (필터 버튼 제거)
          SliverToBoxAdapter(
            child: CustomHeaderBar(
              title: categoryTitle,
              backgroundColor: AppColors.white,
              subtitle: _buildHeaderSubtitle(context),
            ),
          ),

          // 메인 콘텐츠들
          SliverList(
            delegate: SliverChildListDelegate([
              // 이번주 추천 섹션
              _buildWeeklyRecommendationSection(context),

              const SizedBox(height: AppSizes.gapL),

              // 내 주변보기 토글 버튼
              _buildNearbyToggleButton(context, showNearbyOnly, animationController),

              const SizedBox(height: AppSizes.gapM),

              // 장소 리스트
              _buildPlacesList(context, showNearbyOnly.value),

              const SizedBox(height: AppSizes.gapL),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSubtitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.gapL,
        vertical: AppSizes.gapM,
      ),
      decoration: BoxDecoration(
        gradient: categoryGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Row(
        children: [
          Icon(
            categoryIcon,
            color: AppColors.white,
            size: AppSizes.iconM,
          ),
          const SizedBox(width: AppSizes.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryType,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSizes.gapXS),
                Text(
                  '조용하고 편안한 ${categoryTitle.replaceAll(' ', '')} 공간을 찾아보세요',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecommendationSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.gapL),
          Text(
            '이번주 추천 ${categoryTitle}',
            style: AppTextStyles.h4.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSizes.gapM),
          Container(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    right: index < 2 ? AppSizes.gapM : 0,
                  ),
                  child: _buildWeeklyRecommendationCard(context, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecommendationCard(BuildContext context, int index) {
    final recommendedPlaces = _getWeeklyRecommendedPlaces();
    final place = recommendedPlaces[index];

    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          showCommonBottomSheet(
            context: context,
            title: null, // 제목 제거
            content: CommonPlaceDetailBottomSheet(
              placeData: PlaceDetailData.fromMap(
                place,
                category: categoryTitle,
                categoryGradient: categoryGradient,
                categoryIcon: categoryIcon,
              ),
              showCrowdingInfo: true,
              showLocationSection: true,
            ),
            initialHeightFactor: 0.7,
            maxHeightFactor: 0.95,
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: categoryGradient.colors.map((color) =>
                  color.withOpacity(0.8)).toList(),
              begin: categoryGradient.begin,
              end: categoryGradient.end,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: Stack(
            children: [
              // 배경 패턴
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                ),
              ),

              // 콘텐츠
              Padding(
                padding: EdgeInsets.all(AppSizes.gapL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 추천 뱃지
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.gapS,
                        vertical: AppSizes.gapXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        '이번주 추천',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 장소 정보
                    Text(
                      place['name'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppSizes.gapXS),

                    Text(
                      _getPlaceDescription(place['name']),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyToggleButton(
      BuildContext context,
      ValueNotifier<bool> showNearbyOnly,
      AnimationController animationController,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Row(
        children: [
          Text(
            '전체 보기',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              showNearbyOnly.value = !showNearbyOnly.value;
              if (showNearbyOnly.value) {
                animationController.forward();
              } else {
                animationController.reverse();
              }
            },
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.gapM,
                    vertical: AppSizes.gapS,
                  ),
                  decoration: BoxDecoration(
                    color: showNearbyOnly.value
                        ? AppColors.secondary
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    border: showNearbyOnly.value
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.near_me,
                        color: showNearbyOnly.value
                            ? AppColors.white
                            : AppColors.textSecondary,
                        size: AppSizes.iconS,
                      ),
                      const SizedBox(width: AppSizes.gapXS),
                      Text(
                        '내 주변보기',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: showNearbyOnly.value
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesList(BuildContext context, bool showNearbyOnly) {
    final places = showNearbyOnly ? _getNearbyPlaces() : _getAllPlaces();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        children: places.map((place) => Container(
          margin: EdgeInsets.only(bottom: AppSizes.gapM),
          child: _buildPlaceCard(context, place),
        )).toList(),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Map<String, dynamic> place) {
    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          showCommonBottomSheet(
            context: context,
            title: null, // 제목 제거
            content: CommonPlaceDetailBottomSheet(
              placeData: PlaceDetailData.fromMap(
                place,
                category: categoryTitle,
                categoryGradient: categoryGradient,
                categoryIcon: categoryIcon,
              ),
              showCrowdingInfo: true,
              showLocationSection: true,
            ),
            initialHeightFactor: 0.7,
            maxHeightFactor: 0.95,
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: EdgeInsets.all(AppSizes.gapL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 하트
              Row(
                children: [
                  Expanded(
                    child: Text(
                      place['name'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: AppSizes.gapS),
                  FavoriteHeartWidget(
                    contentId: place['name'], // 실제로는 고유 ID 사용
                    contentTitle: place['name'],
                    isTablet: false,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.gapXS),

              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: AppSizes.gapXS),
                  Expanded(
                    child: Text(
                      place['location'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.gapXS),

              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: AppColors.grey,
                    size: 12,
                  ),
                  const SizedBox(width: AppSizes.gapXS),
                  Text(
                    '${place['distance']}km 거리',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getWeeklyRecommendedPlaces() {
    // 카테고리별 이번주 추천 장소 데이터
    switch (categoryTitle) {
      case '도서관 투어':
        return [
          {
            'name': '국립중앙도서관',
            'location': '서초구 반포로',
            'rating': 4.6,
            'distance': 2.1,
          },
          {
            'name': '서울도서관',
            'location': '중구 세종대로',
            'rating': 4.4,
            'distance': 3.5,
          },
          {
            'name': '강남도서관',
            'location': '강남구 개포로',
            'rating': 4.3,
            'distance': 1.8,
          },
        ];
      case '미술관 관람':
        return [
          {
            'name': '국립현대미술관',
            'location': '종로구 삼청로',
            'rating': 4.5,
            'distance': 2.8,
          },
          {
            'name': '리움미술관',
            'location': '용산구 이태원로',
            'rating': 4.7,
            'distance': 3.2,
          },
          {
            'name': '서울시립미술관',
            'location': '중구 덕수궁길',
            'rating': 4.2,
            'distance': 2.5,
          },
        ];
      case '조용한 카페':
        return [
          {
            'name': '북카페 온유',
            'location': '마포구 홍대입구',
            'rating': 4.8,
            'distance': 1.2,
          },
          {
            'name': '조용한 공간',
            'location': '강남구 신사동',
            'rating': 4.6,
            'distance': 0.8,
          },
          {
            'name': '독서실 카페',
            'location': '서초구 서초동',
            'rating': 4.4,
            'distance': 1.5,
          },
        ];
      case '산책로 걷기':
        return [
          {
            'name': '청계천 산책로',
            'location': '중구 청계천로',
            'rating': 4.3,
            'distance': 2.1,
          },
          {
            'name': '한강공원 산책로',
            'location': '영등포구 여의도동',
            'rating': 4.5,
            'distance': 3.8,
          },
          {
            'name': '남산 둘레길',
            'location': '중구 남산공원길',
            'rating': 4.7,
            'distance': 2.9,
          },
        ];
      case '명상 공간':
        return [
          {
            'name': '조계사 명상센터',
            'location': '종로구 우정국로',
            'rating': 4.6,
            'distance': 2.4,
          },
          {
            'name': '마음챙김 센터',
            'location': '강남구 테헤란로',
            'rating': 4.8,
            'distance': 1.7,
          },
          {
            'name': '힐링 명상원',
            'location': '서초구 서초대로',
            'rating': 4.5,
            'distance': 2.1,
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getAllPlaces() {
    // 카테고리별 전체 장소 데이터
    switch (categoryTitle) {
      case '도서관 투어':
        return [
          {
            'name': '국립중앙도서관',
            'description': '국내 최대 규모의 도서관으로 조용한 열람실과 다양한 컬렉션을 제공합니다.',
            'location': '서초구 반포로 201',
            'rating': 4.6,
            'distance': 2.1,
          },
          {
            'name': '서울도서관',
            'description': '서울시청 건물 내 위치한 공공도서관으로 접근성이 좋습니다.',
            'location': '중구 세종대로 110',
            'rating': 4.4,
            'distance': 3.5,
          },
          {
            'name': '강남도서관',
            'description': '현대적인 시설과 편안한 환경을 제공하는 지역 도서관입니다.',
            'location': '강남구 개포로 235',
            'rating': 4.3,
            'distance': 1.8,
          },
          {
            'name': '마포중앙도서관',
            'description': '지역주민을 위한 친근한 분위기의 도서관입니다.',
            'location': '마포구 성미산로 55',
            'rating': 4.2,
            'distance': 4.2,
          },
        ];
      case '미술관 관람':
        return [
          {
            'name': '국립현대미술관',
            'description': '한국 현대미술의 중심지로 다양한 전시를 즐길 수 있습니다.',
            'location': '종로구 삼청로 30',
            'rating': 4.5,
            'distance': 2.8,
          },
          {
            'name': '리움미술관',
            'description': '전통과 현대가 조화된 특별한 미술관 경험을 제공합니다.',
            'location': '용산구 이태원로 60-16',
            'rating': 4.7,
            'distance': 3.2,
          },
          {
            'name': '서울시립미술관',
            'description': '덕수궁 근처에 위치한 시립미술관으로 무료 관람이 가능합니다.',
            'location': '중구 덕수궁길 61',
            'rating': 4.2,
            'distance': 2.5,
          },
        ];
      case '조용한 카페':
        return [
          {
            'name': '북카페 온유',
            'description': '책과 커피를 함께 즐길 수 있는 조용하고 아늑한 공간입니다.',
            'location': '마포구 홍대입구역 근처',
            'rating': 4.8,
            'distance': 1.2,
          },
          {
            'name': '조용한 공간',
            'description': '업무나 독서에 집중할 수 있는 조용한 분위기의 카페입니다.',
            'location': '강남구 신사동 가로수길',
            'rating': 4.6,
            'distance': 0.8,
          },
          {
            'name': '독서실 카페',
            'description': '독서실과 카페가 결합된 공간으로 조용한 환경을 제공합니다.',
            'location': '서초구 서초동 1305-3',
            'rating': 4.4,
            'distance': 1.5,
          },
        ];
      case '산책로 걷기':
        return [
          {
            'name': '청계천 산책로',
            'description': '도심 속 자연을 느낄 수 있는 대표적인 산책 코스입니다.',
            'location': '중구 청계천로 일대',
            'rating': 4.3,
            'distance': 2.1,
          },
          {
            'name': '한강공원 산책로',
            'description': '강변을 따라 걸으며 여유로운 시간을 보낼 수 있습니다.',
            'location': '영등포구 여의도동',
            'rating': 4.5,
            'distance': 3.8,
          },
          {
            'name': '남산 둘레길',
            'description': '서울 시내를 조망하며 걸을 수 있는 아름다운 산책로입니다.',
            'location': '중구 남산공원길',
            'rating': 4.7,
            'distance': 2.9,
          },
        ];
      case '명상 공간':
        return [
          {
            'name': '조계사 명상센터',
            'description': '전통 불교 사찰에서 진행하는 명상 프로그램을 체험할 수 있습니다.',
            'location': '종로구 우정국로 55',
            'rating': 4.6,
            'distance': 2.4,
          },
          {
            'name': '마음챙김 센터',
            'description': '현대적인 명상 기법을 배우고 실습할 수 있는 공간입니다.',
            'location': '강남구 테헤란로 427',
            'rating': 4.8,
            'distance': 1.7,
          },
          {
            'name': '힐링 명상원',
            'description': '조용한 환경에서 마음의 평안을 찾을 수 있는 명상 공간입니다.',
            'location': '서초구 서초대로 74길',
            'rating': 4.5,
            'distance': 2.1,
          },
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _getNearbyPlaces() {
    // 내 주변 2km 이내 장소만 필터링
    return _getAllPlaces().where((place) => place['distance'] <= 2.0).toList();
  }

  String _getPlaceDescription(String placeName) {
    // 장소명으로 설명 찾기
    final allPlaces = _getAllPlaces();
    final place = allPlaces.firstWhere(
          (p) => p['name'] == placeName,
      orElse: () => {'description': '조용하고 편안한 공간입니다.'},
    );
    return place['description'] ?? '조용하고 편안한 공간입니다.';
  }
}
