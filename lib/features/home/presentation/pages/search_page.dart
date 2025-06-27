// lib/features/search/presentation/pages/search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/service/search_service.dart';
import '../../../../core/widgets/custom_header_bar.dart';
import '../../../../core/widgets/common_place_detail_bottom_sheet.dart';
import '../../../../core/widgets/common_bottom_sheet.dart';
import '../providers/search_state_provider.dart';
import '../widgets/search/recent_searches_widget.dart';
import '../widgets/search/search_bar_widget.dart';
import '../widgets/search/search_tips_widget.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResult = ref.watch(searchResultProvider);
    final isSearching = ref.watch(isSearchingProvider);

    final searchFocusNode = useFocusNode();
    final scrollController = useScrollController();

    // 페이지 진입 시 상태 초기화
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        resetSearchState(ref);
      });
      return null;
    }, []);

    // 검색어 변경 함수
    void onSearchChanged(String value) {
      updateSearchQuery(ref, value);
    }

    // 검색 실행 함수
    Future<void> onSearchSubmitted(String keyword) async {
      await performSearch(ref, keyword);
      // 키보드 숨기기
      FocusScope.of(context).unfocus();
    }

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Column(
        children: [
          // 헤더
          CustomHeaderBar(
            title: '여행지 검색',
            backgroundColor: AppColors.background,
          ),

          // 검색창
          Container(
            padding: EdgeInsets.all(AppSizes.gapM),
            color: AppColors.background,
            child: SearchBarWidget(
              onSearchChanged: onSearchChanged,
              onSearchSubmitted: onSearchSubmitted,
              initialValue: '', // 항상 빈 상태로 시작
            ),
          ),

          // 메인 콘텐츠
          Expanded(
            child: _buildMainContent(
              context,
              ref,
              searchState,
              searchResult,
              isSearching,
              onSearchSubmitted,
              scrollController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context,
      WidgetRef ref,
      SearchState searchState,
      SearchResult? searchResult,
      bool isSearching,
      Function(String) onSearchSubmitted,
      ScrollController scrollController,
      ) {
    switch (searchState) {
      case SearchState.initial:
        return _buildInitialState(context, ref, onSearchSubmitted);
      case SearchState.searching:
        return _buildLoadingState();
      case SearchState.hasResults:
        return _buildSearchResults(context, searchResult!, scrollController);
      case SearchState.noResults:
        return _buildEmptyState(searchResult!.keyword);
      case SearchState.error:
        return _buildErrorState(searchResult?.error ?? '알 수 없는 오류가 발생했습니다.');
    }
  }

  // 초기 상태 (검색 전)
  Widget _buildInitialState(
      BuildContext context,
      WidgetRef ref,
      Function(String) onSearchSubmitted,
      ) {
    return ListView(
      padding: EdgeInsets.all(AppSizes.gapM),
      children: [
        // 최근 검색어
        RecentSearchesWidget(
          onSearchTap: onSearchSubmitted,
        ),

        SizedBox(height: AppSizes.gapL),

        // 인기 검색어
        _buildPopularKeywords(onSearchSubmitted),

        SizedBox(height: AppSizes.gapL),

        // 검색 팁
        SearchTipsWidget(
          customTips: [
            '구체적인 장소명으로 검색하면 더 정확한 결과를 얻을 수 있어요',
            '"조용한", "한적한" 등의 키워드를 함께 사용해보세요',
            '지역명과 함께 검색하면 원하는 지역의 장소를 찾기 쉬워요',
            '도서관, 미술관, 사찰 등 카테고리별로도 검색 가능해요',
          ],
        ),
      ],
    );
  }

  // 로딩 상태
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSizes.gapM),
          Text(
            '검색 중...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 검색 결과
  Widget _buildSearchResults(
      BuildContext context,
      SearchResult searchResult,
      ScrollController scrollController,
      ) {
    return Column(
      children: [
        // 검색 결과 헤더
        Container(
          padding: EdgeInsets.all(AppSizes.gapM),
          color: AppColors.background,
          child: Row(
            children: [
              Text(
                '"${searchResult.keyword}" 검색결과',
                style: AppTextStyles.labelBold,
              ),
              Spacer(),
              Text(
                '총 ${searchResult.totalCount}개',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // 검색 결과 목록
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(AppSizes.gapM),
            itemCount: searchResult.places.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: AppSizes.gapS),
                child: _buildSearchResultCard(
                  context,
                  searchResult.places[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 검색 결과 카드 (사용자 디자인 유지)
  Widget _buildSearchResultCard(BuildContext context, SearchPlace place) {
    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          // 상세 정보 표시
          showCommonBottomSheet(
            context: context,
            title: null,
            content: CommonPlaceDetailBottomSheet(
              placeData: PlaceDetailData.fromMap(
                {
                  'id': place.contentId,
                  'name': place.name,
                  'location': place.address,
                  'description': place.description,
                  'areaCode': place.areaCode,
                  'sigunguCode': place.sigunguCode,
                },
                category: place.category,
                categoryGradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                categoryIcon: Icons.place,
              ),
              showCrowdingInfo: true,
              showLocationSection: true,
            ),
            initialHeightFactor: 0.7,
            maxHeightFactor: 0.95,
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.gapL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: AppSizes.gapXS),

              // 제목 (사용자 디자인)
              Row(
                children: [
                  Text(
                    place.categoryIcon,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: AppSizes.gapXS),
                  Expanded(
                    child: Text(
                      place.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (place.isPopular)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.gapXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        '인기',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: AppSizes.gapXS),
              // 카테고리 (사용자 디자인 - 맨 위에)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.gapXS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  place.category,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),

              SizedBox(height: AppSizes.gapXS),
              // 주소 (사용자 디자인 유지)
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.textHint,
                    size: 12,
                  ),
                  SizedBox(width: AppSizes.gapXS),
                  Expanded(
                    child: Text(
                      place.address,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  // 에러 상태
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.gapXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: AppSizes.iconXL,
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              '검색 중 오류가 발생했습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 검색 결과 없음
  Widget _buildEmptyState(String keyword) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.gapXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.textHint,
              size: AppSizes.iconXL,
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              '"$keyword" 검색 결과가 없습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              '다른 키워드로 검색해보시거나\n검색어의 철자를 확인해주세요',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 인기 검색어
  Widget _buildPopularKeywords(Function(String) onTap) {
    final keywords = SearchService.getPopularKeywords();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인기 검색어',
          style: AppTextStyles.labelBold,
        ),
        SizedBox(height: AppSizes.gapM),
        Wrap(
          spacing: AppSizes.gapS,
          runSpacing: AppSizes.gapS,
          children: keywords.take(8).map((keyword) => _buildKeywordChip(
            keyword,
            onTap,
            isPopular: true,
          )).toList(),
        ),
      ],
    );
  }


  // 키워드 칩
  Widget _buildKeywordChip(
      String keyword,
      Function(String) onTap, {
        bool isPopular = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: isPopular ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: isPopular ? AppColors.primary.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: () => onTap(keyword),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.gapM,
            vertical: AppSizes.gapS,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPopular) ...[
                Icon(
                  Icons.trending_up,
                  size: AppSizes.iconS,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppSizes.gapXS),
              ],
              Text(
                keyword,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isPopular ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
