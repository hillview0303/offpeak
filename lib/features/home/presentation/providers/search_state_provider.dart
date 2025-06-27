
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/service/search_service.dart';
import '../widgets/search/recent_searches_widget.dart';

// ==================== 상태 프로바이더들 ====================

/// 검색 상태 관리 (메인 상태)
final searchStateProvider = StateProvider<SearchState>((ref) => SearchState.initial);

/// 검색 쿼리 관리
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 검색 결과 관리
final searchResultProvider = StateProvider<SearchResult?>(((ref) => null));

/// 로딩 상태 관리
final isSearchingProvider = StateProvider<bool>((ref) => false);

// ==================== 검색 상태 enum ====================

enum SearchState {
  initial,        // 초기 상태 (아직 검색 안함)
  searching,      // 검색 중
  noResults,      // 검색 결과 없음
  hasResults,     // 검색 결과 있음
  error,          // 검색 오류
}

// ==================== 헬퍼 함수들 ====================

/// 검색 실행 메인 함수
Future<void> performSearch(WidgetRef ref, String searchTerm) async {
  if (searchTerm.trim().isEmpty) return;

  try {
    // 1단계: 검색 시작 상태로 변경
    ref.read(searchStateProvider.notifier).state = SearchState.searching;
    ref.read(isSearchingProvider.notifier).state = true;
    ref.read(searchQueryProvider.notifier).state = searchTerm;

    // 2단계: 최근 검색어에 추가
    addToRecentSearches(ref, searchTerm);

    // 3단계: 실제 검색 API 호출
    final result = await SearchService.searchPlaces(keyword: searchTerm);

    // 4단계: 검색 결과 저장
    ref.read(searchResultProvider.notifier).state = result;

    // 5단계: 결과에 따른 상태 업데이트
    if (result.isSuccess) {
      if (result.isEmpty) {
        ref.read(searchStateProvider.notifier).state = SearchState.noResults;
      } else {
        ref.read(searchStateProvider.notifier).state = SearchState.hasResults;
      }
    } else {
      ref.read(searchStateProvider.notifier).state = SearchState.error;
    }

  } catch (e) {
    print('🔍 검색 오류: $e');

    // 에러 결과 생성
    ref.read(searchResultProvider.notifier).state = SearchResult(
      places: [],
      keyword: searchTerm,
      totalCount: 0,
      currentPage: 1,
      hasNextPage: false,
      searchTime: DateTime.now(),
      error: '검색 중 오류가 발생했습니다.',
    );

    ref.read(searchStateProvider.notifier).state = SearchState.error;

  } finally {
    // 로딩 상태 해제
    ref.read(isSearchingProvider.notifier).state = false;
  }
}

/// 검색 상태 완전 초기화
void resetSearchState(WidgetRef ref) {
  ref.read(searchStateProvider.notifier).state = SearchState.initial;
  ref.read(searchQueryProvider.notifier).state = '';
  ref.read(searchResultProvider.notifier).state = null;
  ref.read(isSearchingProvider.notifier).state = false;

  print('🔄 검색 상태 초기화 완료');
}

/// 검색어만 업데이트 (실시간 검색용)
void updateSearchQuery(WidgetRef ref, String query) {
  ref.read(searchQueryProvider.notifier).state = query;
}
