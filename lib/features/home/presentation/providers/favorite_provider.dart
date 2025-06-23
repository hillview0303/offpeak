import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'recommendation_model.dart';

// 찜한 장소들의 상태를 관리하는 StateNotifier
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(<String>{});

  // 찜 추가/제거 토글 (contentId 사용)
  void toggleFavorite(String contentId) {
    if (state.contains(contentId)) {
      // 이미 찜한 상태라면 제거
      state = Set.from(state)..remove(contentId);
    } else {
      // 찜하지 않은 상태라면 추가
      state = Set.from(state)..add(contentId);
    }
  }

  // 특정 추천장소가 찜되어 있는지 확인
  bool isFavorite(String contentId) {
    return state.contains(contentId);
  }

  // 찜한 장소 개수
  int get favoritesCount => state.length;

  // 찜한 장소 목록 (contentId 리스트)
  List<String> get favoriteContentIds => state.toList();

  // 모든 찜 제거
  void clearAllFavorites() {
    state = <String>{};
  }

  // 여러 장소를 한번에 찜하기
  void addMultipleFavorites(List<String> contentIds) {
    state = Set.from(state)..addAll(contentIds);
  }

  // 여러 장소를 한번에 찜 해제
  void removeMultipleFavorites(List<String> contentIds) {
    state = Set.from(state)..removeAll(contentIds);
  }

  // RecommendationCard 객체로 찜 추가/제거
  void toggleFavoriteCard(RecommendationCard card) {
    toggleFavorite(card.contentId);
  }

  // RecommendationCard 객체가 찜되어 있는지 확인
  bool isFavoriteCard(RecommendationCard card) {
    return isFavorite(card.contentId);
  }
}

// 찜 상태 provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

// 특정 추천장소의 찜 상태를 확인하는 provider (contentId 사용)
final isFavoriteProvider = Provider.family<bool, String>((ref, contentId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(contentId);
});

// 찜한 장소 개수를 반환하는 provider
final favoritesCountProvider = Provider<int>((ref) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.length;
});

// 찜한 추천장소 리스트를 반환하는 provider (실제 RecommendationCard 객체들)
// 이것은 나중에 전체 추천장소 리스트 provider가 있을 때 사용
final favoriteRecommendationsProvider = Provider<List<RecommendationCard>>((ref) {
  final favoriteContentIds = ref.watch(favoritesProvider);
  // TODO: 실제 추천장소 데이터 provider에서 가져와서 필터링
  // final allRecommendations = ref.watch(recommendationsProvider);
  // return allRecommendations.where((rec) => favoriteContentIds.contains(rec.contentId)).toList();

  // 현재는 빈 리스트 반환 (나중에 구현)
  return [];
});
