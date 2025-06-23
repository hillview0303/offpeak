import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/recommendation_model.dart';
import '../providers/ai_recommendation_service.dart';

// State Providers
final recommendationsProvider = StateProvider<List<RecommendationCard>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final selectedAreaCodeProvider = StateProvider<String?>((ref) => null);
final selectedContentTypeProvider = StateProvider<String?>((ref) => null);
final hasErrorProvider = StateProvider<bool>((ref) => false);

// Business Logic Provider
final algorithmRecommendationControllerProvider = Provider<AlgorithmRecommendationController>((ref) {
  return AlgorithmRecommendationController(ref);
});

class AlgorithmRecommendationController {
  final Ref ref;

  AlgorithmRecommendationController(this.ref);

  // AI 추천 데이터 로드
  Future<void> loadAIRecommendations() async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(hasErrorProvider.notifier).state = false;
    ref.read(recommendationsProvider.notifier).state = [];

    try {
      final selectedAreaCode = ref.read(selectedAreaCodeProvider);
      final selectedContentType = ref.read(selectedContentTypeProvider);

      final recommendations = await AIRecommendationService.fetchRecommendations(
        areaCode: selectedAreaCode,
        contentType: selectedContentType,
      );

      if (recommendations.isNotEmpty) {
        ref.read(recommendationsProvider.notifier).state = recommendations;
        ref.read(hasErrorProvider.notifier).state = false;
      } else {
        ref.read(hasErrorProvider.notifier).state = true;
      }
    } catch (e) {
      print('Error loading AI recommendations: $e');
      ref.read(hasErrorProvider.notifier).state = true;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // 필터 초기화
  void resetFilters() {
    ref.read(selectedAreaCodeProvider.notifier).state = null;
    ref.read(selectedContentTypeProvider.notifier).state = null;
  }

  // 지역 코드 업데이트
  void updateAreaCode(String? areaCode) {
    ref.read(selectedAreaCodeProvider.notifier).state = areaCode;
  }

  // 콘텐츠 타입 업데이트
  void updateContentType(String? contentType) {
    ref.read(selectedContentTypeProvider.notifier).state = contentType;
  }

  // 현재 상태 getter들
  List<RecommendationCard> get recommendations => ref.read(recommendationsProvider);
  bool get isLoading => ref.read(isLoadingProvider);
  bool get hasError => ref.read(hasErrorProvider);
  String? get selectedAreaCode => ref.read(selectedAreaCodeProvider);
  String? get selectedContentType => ref.read(selectedContentTypeProvider);
}
