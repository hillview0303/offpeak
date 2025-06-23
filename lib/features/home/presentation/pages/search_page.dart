import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../widgets/search/search_bar_widget.dart';
import '../widgets/search/recent_searches_widget.dart';
import '../widgets/search/search_tips_widget.dart';
import '../providers/search_state_provider.dart';

class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: EdgeInsets.all(AppSizes.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SearchBarWidget(
                  onSearchChanged: (value) {
                    // 검색어 변경 처리
                  },
                  onSearchSubmitted: (value) {
                    // 검색 실행
                    performSearch(ref, value);
                    // 최근 검색어에 추가
                    addToRecentSearches(ref, value);
                  },
                ),
                SizedBox(height: AppSizes.gapXL),

                // 검색 결과가 없을 때만 메시지 표시
                if (searchState == SearchState.noResults) ...[
                  _buildNoResultsMessage(),
                  SizedBox(height: AppSizes.gapXL),
                ],

                RecentSearchesWidget(
                  onSearchTap: (searchTerm) {
                    // 최근 검색어 클릭시 검색 실행
                    performSearch(ref, searchTerm);
                    addToRecentSearches(ref, searchTerm);
                  },
                  onClearAll: () {
                    // 최근 검색어 전체 삭제시 검색 상태 초기화
                    ref.read(searchStateProvider.notifier).state = SearchState.initial;
                  },
                ),
                SizedBox(height: AppSizes.gapXL),
                SearchTipsWidget(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      pinned: false,
      floating: true,
      snap: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColors.textPrimary,
          size: AppSizes.iconM,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '여행지 검색',
        style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
      ),
      centerTitle: false,
    );
  }

  Widget _buildNoResultsMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.gapS),
      child: Text(
        '검색된 내용이 없습니다',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
