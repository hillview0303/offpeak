import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/widgets/common_place_detail_bottom_sheet.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../../../../core/widgets/common_bottom_sheet.dart';
import '../../../../core/widgets/favorite_heart_widget.dart';
import '../../../../core/service/quiet_activities_service.dart';

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
    final isMounted = useIsMounted();

    // 상태 관리
    final showNearbyOnly = useState(false);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // 데이터 상태
    final weeklyRecommendations = useState<List<QuietPlace>>([]);
    final allPlaces = useState<List<QuietPlace>>([]);
    final nearbyPlaces = useState<List<QuietPlace>>([]);
    final currentPage = useState(1);
    final hasNextPage = useState(true);

    // 로딩 상태
    final isLoadingWeekly = useState(true);
    final isLoadingAll = useState(false);
    final isLoadingNearby = useState(false);

    // 위치 정보
    final userPosition = useState<Position?>(null);

    // 이번주 추천 로드
    Future<void> loadWeeklyRecommendations() async {
      if (!isMounted()) return;

      try {
        isLoadingWeekly.value = true;
        print('📅 이번주 추천 로드 시작: $categoryTitle');

        final recommendations = await QuietActivitiesService.getWeeklyRecommendations(categoryTitle);

        if (!isMounted()) return;

        weeklyRecommendations.value = recommendations;
        print('✅ 이번주 추천 로드 완료: ${recommendations.length}개');
      } catch (e) {
        print('❌ 이번주 추천 로드 실패: $e');
        if (isMounted()) {
          weeklyRecommendations.value = [];
        }
      } finally {
        if (isMounted()) {
          isLoadingWeekly.value = false;
        }
      }
    }

    // 전체 장소 로드 (페이지네이션)
    Future<void> loadAllPlaces({bool isRefresh = false}) async {
      if (!isMounted()) return;

      try {
        isLoadingAll.value = true;
        final page = isRefresh ? 1 : currentPage.value;

        print('📄 전체 장소 로드: $categoryTitle (페이지: $page)');

        final result = await QuietActivitiesService.getAllPlaces(
          categoryTitle,
          page: page,
          itemsPerPage: 10,
        );

        if (!isMounted()) return;

        if (isRefresh) {
          allPlaces.value = result.places;
          currentPage.value = 1;
        } else {
          allPlaces.value = [...allPlaces.value, ...result.places];
        }

        hasNextPage.value = result.hasNextPage;
        currentPage.value = page;

        print('✅ 전체 장소 로드 완료: ${result.places.length}개');
      } catch (e) {
        print('❌ 전체 장소 로드 실패: $e');
      } finally {
        if (isMounted()) {
          isLoadingAll.value = false;
        }
      }
    }

    // 내 주변 장소 로드
    Future<void> loadNearbyPlaces() async {
      if (!isMounted()) return;

      try {
        isLoadingNearby.value = true;

        // 위치 권한 확인 및 요청
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('위치 권한이 필요합니다');
        }

        // 현재 위치 가져오기
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );

        if (!isMounted()) return;

        userPosition.value = position;

        print('📍 내 주변 장소 로드: $categoryTitle');

        final nearby = await QuietActivitiesService.getNearbyPlaces(
          categoryTitle,
          latitude: position.latitude,
          longitude: position.longitude,
          radiusKm: 2.0,
        );

        if (!isMounted()) return;

        nearbyPlaces.value = nearby;
        print('✅ 내 주변 장소 로드 완료: ${nearby.length}개');
      } catch (e) {
        print('❌ 내 주변 장소 로드 실패: $e');
        if (isMounted()) {
          // 위치 기반 검색 실패시 가까운 거리 장소들 필터링
          nearbyPlaces.value = allPlaces.value
              .where((place) => place.distance <= 2.0)
              .toList();
        }
      } finally {
        if (isMounted()) {
          isLoadingNearby.value = false;
        }
      }
    }

    // 초기 데이터 로드
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isMounted()) {
          loadWeeklyRecommendations();
          loadAllPlaces(isRefresh: true);
        }
      });
      return null;
    }, []);

    // 내 주변보기 토글 감지
    useEffect(() {
      if (showNearbyOnly.value && nearbyPlaces.value.isEmpty) {
        loadNearbyPlaces();
      }
      return null;
    }, [showNearbyOnly.value]);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 커스텀 헤더
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
              _buildWeeklyRecommendationSection(
                context,
                weeklyRecommendations.value,
                isLoadingWeekly.value,
              ),

              const SizedBox(height: AppSizes.gapL),

              // 내 주변보기 토글 버튼
              _buildNearbyToggleButton(
                context,
                showNearbyOnly,
                animationController,
                isLoadingNearby.value,
              ),

              const SizedBox(height: AppSizes.gapM),

              // 장소 리스트
              _buildPlacesList(
                context,
                showNearbyOnly.value,
                allPlaces.value,
                nearbyPlaces.value,
                isLoadingAll.value,
              ),

              // 더보기 버튼 (전체보기일 때만)
              if (!showNearbyOnly.value && hasNextPage.value && !isLoadingAll.value)
                _buildLoadMoreButton(context, () {
                  currentPage.value++;
                  loadAllPlaces();
                }),

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

  Widget _buildWeeklyRecommendationSection(
      BuildContext context,
      List<QuietPlace> recommendations,
      bool isLoading,
      ) {
    // 🔧 미디어쿼리로 유연한 높이 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 화면 높이의 52% (최소 180px, 최대 240px)
    final cardHeight = (screenHeight * 0.52).clamp(180.0, 240.0);

    // 카드 너비도 화면에 맞게 조정 (화면 너비의 75%, 최소 260px, 최대 320px)
    final cardWidth = (screenWidth * 0.75).clamp(260.0, 320.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.gapL),
          Row(
            children: [
              Text(
                '이번주 추천 ${categoryTitle}',
                style: AppTextStyles.h4.copyWith(fontSize: 16),
              ),
              const Spacer(),
              // 🔧 수정: 로딩 인디케이터 제거 (카드 영역에서만 표시)
            ],
          ),
          const SizedBox(height: AppSizes.gapM),

          // 🔧 수정: 유연한 높이 적용
          Container(
            height: cardHeight,
            child: isLoading
                ? _buildWeeklyLoadingState(cardWidth, cardHeight)
                : recommendations.isEmpty
                ? _buildWeeklyEmptyState()
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                    right: index < recommendations.length - 1 ? AppSizes.gapM : 0,
                  ),
                  child: _buildWeeklyRecommendationCard(context, recommendations[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyLoadingState(double cardWidth, double cardHeight) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: cardWidth,
          height: cardHeight,
          margin: EdgeInsets.only(right: index < 2 ? AppSizes.gapM : 0),
          child: Card(
            elevation: AppSizes.elevationM,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: categoryGradient.colors.first,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyEmptyState() {
    return Center(
      child: Text(
        '이번주 추천 장소를 불러오는 중입니다...',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildWeeklyRecommendationCard(BuildContext context, QuietPlace place) {
    // 🔧 미디어쿼리로 텍스트 높이도 유연하게 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 화면 크기에 따른 제목 높이 (화면 높이의 5-7% 범위)
    final titleHeight = (screenHeight * 0.055).clamp(40.0, 50.0);

    // 화면 크기에 따른 폰트 크기
    final titleFontSize = (screenWidth * 0.04).clamp(14.0, 16.0);
    final descriptionFontSize = (screenWidth * 0.032).clamp(11.0, 13.0);

    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          showCommonBottomSheet(
            context: context,
            title: null,
            content: CommonPlaceDetailBottomSheet(
              placeData: PlaceDetailData.fromMap(
                {
                  ...place.toMap(),
                  'id': place.id, // 🔧 추가: contentId 전달
                },
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
              // 배경 패턴 (카드 크기에 맞게 조정)
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(70),
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

                    // 🔧 수정: 유연한 간격
                    SizedBox(height: AppSizes.gapM),

                    // 🔧 수정: 텍스트를 카드 크기에 맞게 제한
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔧 장소 이름 (미디어쿼리 적용한 2줄 여유있는 높이)
                          Container(
                            height: titleHeight,
                            child: Text(
                              place.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: titleFontSize,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          SizedBox(height: AppSizes.gapS),

                          // 🔧 설명 (Expanded로 남은 공간을 모두 사용)
                          Expanded(
                            child: Text(
                              place.description,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withOpacity(0.9),
                                fontSize: descriptionFontSize,
                                height: 1.4, // 줄 간격을 약간 늘려서 가독성 향상
                              ),
                              maxLines: 4, // 🔧 4줄로 설정
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
  }

  Widget _buildNearbyToggleButton(
      BuildContext context,
      ValueNotifier<bool> showNearbyOnly,
      AnimationController animationController,
      bool isLoadingNearby,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Row(
        children: [
          Text(
            showNearbyOnly.value ? '내 주변 장소' : '전체 보기',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: isLoadingNearby ? null : () {
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
                      if (isLoadingNearby)
                        SizedBox(
                          width: AppSizes.iconS,
                          height: AppSizes.iconS,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: showNearbyOnly.value ? AppColors.white : AppColors.secondary,
                          ),
                        )
                      else
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

  Widget _buildPlacesList(
      BuildContext context,
      bool showNearbyOnly,
      List<QuietPlace> allPlaces,
      List<QuietPlace> nearbyPlaces,
      bool isLoading,
      ) {
    final places = showNearbyOnly ? nearbyPlaces : allPlaces;

    if (isLoading && places.isEmpty) {
      return _buildPlacesLoadingState();
    }

    if (places.isEmpty) {
      return _buildPlacesEmptyState(showNearbyOnly);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        children: places.map((place) => Container(
          margin: EdgeInsets.only(bottom: AppSizes.gapM),
          child: _buildPlaceCard(context, place, showNearbyOnly),
        )).toList(),
      ),
    );
  }

  Widget _buildPlacesLoadingState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Column(
        children: List.generate(3, (index) => Container(
          margin: EdgeInsets.only(bottom: AppSizes.gapM),
          child: Card(
            elevation: AppSizes.elevationS,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: Container(
              padding: EdgeInsets.all(AppSizes.gapL),
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: categoryGradient.colors.first,
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildPlacesEmptyState(bool isNearby) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      padding: EdgeInsets.all(AppSizes.gapXL),
      child: Center(
        child: Column(
          children: [
            Icon(
              isNearby ? Icons.location_off : Icons.search_off,
              size: AppSizes.iconXL,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.gapM),
            Text(
              isNearby ? '내 주변에 장소가 없습니다' : '장소를 찾을 수 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, QuietPlace place, bool isNearbyMode) {
    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          showCommonBottomSheet(
            context: context,
            title: null,
            content: CommonPlaceDetailBottomSheet(
              placeData: PlaceDetailData.fromMap(
                {
                  ...place.toMap(),
                  'id': place.id, // 🔧 추가: contentId 전달
                },
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
                      place.name,
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
                    contentId: place.id,
                    contentTitle: place.name,
                    isTablet: false,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.gapXS),

              // 🔧 수정: 실제 주소 표시
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
                      place.location,
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

              // 🔧 추가: 내 주변보기일 때만 거리 표시
              if (isNearbyMode) ...[
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
                      '${place.distance.toStringAsFixed(1)}km 거리',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: Center(
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.expand_more,
            color: categoryGradient.colors.first,
          ),
          label: Text(
            '더 많은 장소 보기',
            style: AppTextStyles.bodyMedium.copyWith(
              color: categoryGradient.colors.first,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
