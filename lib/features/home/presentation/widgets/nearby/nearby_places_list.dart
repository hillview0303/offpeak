import 'package:flutter/material.dart';
import '../../../../../core/constants/color.dart';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/service/nearby_service.dart';
import '../../../../../core/service/tourism_api_service.dart';
import '../../../../../core/utils/category_utils.dart';

import 'place_card.dart';

class NearbyPlacesList extends StatelessWidget {
  final List<NearbyPlace> places;
  final bool isLoading;
  final VoidCallback onRefresh;

  // 페이지 기반 무한 스크롤 관련
  final bool isLoadingMore;
  final bool hasMoreData;
  final int currentPage;
  final int maxPages;
  final String selectedCategory;

  // 위치 검색 상태 추가
  final bool isLocationLoading; // 위치 검색 중인지 여부

  const NearbyPlacesList({
    super.key,
    required this.places,
    required this.isLoading,
    required this.onRefresh,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.currentPage = 1,
    this.maxPages = 10,
    this.selectedCategory = '전체',
    this.isLocationLoading = false, // 기본값은 false
  });

  @override
  Widget build(BuildContext context) {
    // 위치 검색 중일 때는 로딩 인디케이터만 표시
    if (isLocationLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    if (isLoading) {
      return _buildLoadingState();
    }

    if (places.isEmpty) {
      return _buildEmptyState();
    }

    return SliverList.separated(
      itemCount: places.length + (hasMoreData || isLoadingMore ? 1 : 0), // 로딩 인디케이터를 위한 +1
      separatorBuilder: (context, index) {
        // 마지막 아이템(로딩 인디케이터)에는 separator 없음
        if (index >= places.length - 1) return SizedBox.shrink();
        return SizedBox(height: AppSizes.gapM);
      },
      itemBuilder: (context, index) {
        // 로딩 인디케이터 표시
        if (index >= places.length) {
          return _buildLoadMoreIndicator();
        }

        final place = places[index];
        return PlaceCard(
          name: place.name,
          address: place.address,
          distance: place.distance,
          category: place.category,
          isOpen: place.isOpen,
          description: place.description,
          onTap: () {
            print('👆 PlaceCard 터치됨: ${place.name} (contentId: ${place.contentId})');
            _showPlaceDetail(context, place);
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              '주변 장소를 검색하고 있어요...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(AppSizes.gapXL),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: AppSizes.iconXL * 1.5,
              color: AppColors.textHint,
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              '주변에 장소가 없어요',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              '다른 카테고리를 선택하거나\n검색 범위를 넓혀보세요',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapL),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh, size: AppSizes.iconS),
              label: Text('다시 검색'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
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

  Widget _buildLoadMoreIndicator() {
    if (isLoadingMore) {
      return Container(
        padding: EdgeInsets.all(AppSizes.gapL),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 2,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              '$selectedCategory ${currentPage + 1}페이지 불러오는 중...',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (!hasMoreData) {
      return Container(
        padding: EdgeInsets.all(AppSizes.gapL),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: AppSizes.iconM,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              currentPage >= maxPages
                  ? '$selectedCategory 최대 ${maxPages}페이지까지 불러왔습니다'
                  : '$selectedCategory 모든 장소를 불러왔습니다',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '총 ${places.length}개 장소 (${currentPage}페이지)',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }

  void _showPlaceDetail(BuildContext context, NearbyPlace place) {
    print('🚀 =================================');
    print('🚀 바텀시트 열기 시작');
    print('🚀 장소명: ${place.name}');
    print('🚀 contentId: ${place.contentId}');
    print('🚀 카테고리: ${place.category}');
    print('🚀 설명: "${place.description}"');
    print('🚀 설명 길이: ${place.description.length}');
    print('🚀 =================================');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        print('🏗️ 바텀시트 builder 호출됨');
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            print('🏗️ DraggableScrollableSheet builder 호출됨');

            // contentId가 있는 경우에만 이미지 로딩 상태 관리
            if (place.contentId.isNotEmpty) {
              return FutureBuilder<List<String>>(
                future: _fetchPlaceImages(place.contentId),
                builder: (context, snapshot) {
                  // 이미지 로딩 중일 때 전체 로딩 화면
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusXL),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 드래그 핸들
                          Container(
                            margin: EdgeInsets.only(top: AppSizes.gapS),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: AppSizes.gapL),
                                  Text(
                                    place.name,
                                    style: AppTextStyles.h4.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: AppSizes.gapS),
                                  Text(
                                    '상세 정보를 불러오는 중...',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // 로딩 완료 후 실제 컨텐츠 표시
                  return _buildDetailContent(context, scrollController, place, snapshot.data);
                },
              );
            } else {
              // contentId가 없는 경우 바로 컨텐츠 표시
              return _buildDetailContent(context, scrollController, place, null);
            }
          },
        );
      },
    ).then((_) {
      print('🚀 바텀시트 닫힘');
    });
  }

  Widget _buildDetailContent(BuildContext context, ScrollController scrollController, NearbyPlace place, List<String>? images) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: EdgeInsets.only(top: AppSizes.gapS),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                AppSizes.spacingM,
                AppSizes.gapM,
                AppSizes.spacingM,
                AppSizes.gapXL,
              ),
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 장소 헤더
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSizes.gapS),
                        decoration: BoxDecoration(
                          color: CategoryUtils.getCategoryColors(place.category)['background'],
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: Icon(
                          CategoryUtils.getCategoryIcon(place.category),
                          color: CategoryUtils.getCategoryColors(place.category)['icon'],
                          size: AppSizes.iconM,
                        ),
                      ),
                      SizedBox(width: AppSizes.gapM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppSizes.gapXS),
                            // 카테고리 태그
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.gapS,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CategoryUtils.getCategoryColors(place.category)['tag'],
                                borderRadius: BorderRadius.circular(AppSizes.radiusS),
                              ),
                              child: Text(
                                CategoryUtils.getCategoryDisplayText(place.category),
                                style: AppTextStyles.caption.copyWith(
                                  color: CategoryUtils.getCategoryColors(place.category)['tagText'],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppSizes.gapL),

                  // 장소 이미지 (이미지가 있는 경우에만)
                  if (images != null && images.isNotEmpty) ...[
                    _buildStaticPlaceImage(images.first),
                    SizedBox(height: AppSizes.gapL),
                  ],

                  // 거리 정보
                  _buildInfoSection('거리', place.distance, Icons.location_on),

                  // 주소 정보 (의미있는 주소가 있을 때만)
                  if (_hasValidAddress(place.address)) ...[
                    _buildInfoSection('주소', place.address, Icons.home),
                  ],

                  // ⭐ 실제 상세 설명만 표시 (API에서 가져온 진짜 정보만)
                  if (_hasRealDescription(place.description)) ...[
                    _buildDescriptionSection(place.description),
                  ],

                  // ⭐ 새로 추가: API 기반 실용 정보 표시
                  if (place.contentId.isNotEmpty) ...[
                    _buildApiBasedTipSection(place.contentId),
                  ],

                  // ⭐ 정보가 적을 때 안내 메시지 (선택사항)
                  if (!_hasRealDescription(place.description)) ...[
                    _buildMinimalInfoMessage(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ 유효한 주소인지 확인
  bool _hasValidAddress(String address) {
    if (address.isEmpty) return false;

    // 의미없는 주소 필터링
    final meaninglessAddresses = [
      '주소 정보 없음',
      '주소를 찾을 수 없음',
      '위치 정보 없음',
    ];

    return !meaninglessAddresses.contains(address) && address.length > 5;
  }

  // ⭐ 실제 상세 설명인지 확인 (API에서 가져온 진짜 정보만)
  bool _hasRealDescription(String description) {
    if (description.isEmpty) return false;

    print('🔍 설명 체크: "$description"');

    // 기본/생성된 설명들 필터링
    final generatedDescriptions = [
      '상세 정보를 확인해보세요.',
      '멋진 관광지입니다.',
      '정보입니다.',
      '장소입니다.',
      '시설입니다.',
      '음식점입니다.',
      '관광지 정보입니다.',
      '문화시설 정보입니다.',
      '카페 정보입니다.',
      '음식점 정보입니다.',
      '숙박 정보입니다.',
      '레포츠 정보입니다.',
      '쇼핑 정보입니다.',
    ];

    // 완전 일치하는 기본 문구들 제외
    if (generatedDescriptions.contains(description)) {
      print('❌ 기본 설명이라 표시 안함: $description');
      return false;
    }

    // 짧은 기본 문구들 제외
    if (description.length < 15) {
      print('❌ 너무 짧은 설명: ${description.length}자');
      return false;
    }

    // "~정보입니다"로 끝나는 생성된 설명들 제외
    if (description.endsWith('정보입니다.')) {
      print('❌ 생성된 설명이라 표시 안함: $description');
      return false;
    }

    print('✅ 실제 설명으로 판단: 길이 ${description.length}');
    return true;
  }

  // ⭐ 정보가 적을 때 안내 메시지
  Widget _buildMinimalInfoMessage() {
    return Container(
      margin: EdgeInsets.only(top: AppSizes.gapM),
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: AppSizes.iconS,
            color: AppColors.textHint,
          ),
          SizedBox(width: AppSizes.gapS),
          Expanded(
            child: Text(
              '더 자세한 정보는 직접 방문하거나 문의해보세요.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticPlaceImage(String imageUrl) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print('❌ 이미지 로드 실패: $imageUrl');
            // 이미지 로드 실패 시 빈 공간 반환 (이미지 없는 것처럼 처리)
            return SizedBox.shrink();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ 이미지 로드 완료: $imageUrl');
              return child;
            }
            return Container(
              color: AppColors.greyLight,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 장소 이미지 조회 - detailCommon2와 detailImage2 API 사용
  Future<List<String>> _fetchPlaceImages(String contentId) async {
    try {
      print('🔍 이미지 조회 시작: contentId=$contentId');
      return await TourismApiService.fetchPlaceImages(contentId);
    } catch (e) {
      print('❌ 이미지 조회 실패: $e');
      return [];
    }
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: AppSizes.iconS,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppSizes.gapS),
            Text(
              '상세 정보',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.gapS),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSizes.gapM),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            // ⭐ 전체 내용 표시
            softWrap: true,
          ),
        ),
        SizedBox(height: AppSizes.gapM),
      ],
    );
  }

  // ⭐ 새로 추가: API 기반 실용 정보 섹션
  Widget _buildApiBasedTipSection(String contentId) {
    return FutureBuilder<PlaceDetail?>(
      future: TourismApiService.fetchPlaceDetail(contentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.all(AppSizes.gapM),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: AppSizes.gapS),
                Text(
                  '상세 정보를 불러오는 중...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData &&
            snapshot.data!.facilities.isNotEmpty &&
            snapshot.data!.facilities != '시설 정보 없음') {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: AppSizes.iconS,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: AppSizes.gapS),
                  Text(
                    '이용 안내',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.gapS),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  snapshot.data!.facilities,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  softWrap: true,
                ),
              ),
              SizedBox(height: AppSizes.gapM),
            ],
          );
        }

        return SizedBox.shrink(); // 데이터가 없으면 표시하지 않음
      },
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.gapM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: Offset(0, 3),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AppSizes.gapS),
          Text(
            '$title: ',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
