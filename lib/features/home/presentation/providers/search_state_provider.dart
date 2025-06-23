import 'package:hooks_riverpod/hooks_riverpod.dart';

// 검색 상태 관리
final searchStateProvider = StateProvider<SearchState>((ref) => SearchState.initial);

enum SearchState {
  initial,        // 초기 상태 (아직 검색 안함)
  searching,      // 검색 중
  noResults,      // 검색 결과 없음
  hasResults,     // 검색 결과 있음
}

// 검색 실행 헬퍼 함수
void performSearch(WidgetRef ref, String searchTerm) {
  if (searchTerm.trim().isEmpty) return;

  // 검색 상태를 searching으로 변경
  ref.read(searchStateProvider.notifier).state = SearchState.searching;

  // TODO: 실제 검색 로직 구현
  // 임시로 검색 결과 없음으로 설정 (나중에 실제 검색 결과에 따라 변경)
  Future.delayed(Duration(milliseconds: 500), () {
    ref.read(searchStateProvider.notifier).state = SearchState.noResults;
  });
}
