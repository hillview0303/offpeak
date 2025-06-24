import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/recommendation_model.dart';
import '../../../../core/service/ai_recommendation_service.dart';
import '../../../../core/service/unified_laas_api_service.dart';

// State Providers
final recommendationsProvider = StateProvider<List<RecommendationCard>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final hasErrorProvider = StateProvider<bool>((ref) => false);

// Filter State Providers
final selectedAreaCodeProvider = StateProvider<String?>((ref) => null);
final selectedSigunguCodeProvider = StateProvider<String?>((ref) => null);
final selectedContentTypeProvider = StateProvider<String?>((ref) => null);
final selectedCategoryCodeProvider = StateProvider<String?>((ref) => null);

// Business Logic Provider
final algorithmRecommendationControllerProvider = Provider<AlgorithmRecommendationController>((ref) {
  return AlgorithmRecommendationController(ref);
});

// 필터 요약 Provider
final filterSummaryProvider = Provider<String>((ref) {
  final controller = ref.watch(algorithmRecommendationControllerProvider);
  return controller.getFilterSummary();
});

// LaaS API 상태 관리 Provider
final laasApiStatusProvider = FutureProvider<bool>((ref) async {
  try {
    return await UnifiedLaaSAPIService.checkAPIConnection();
  } catch (e) {
    print('❌ LaaS API 연결 확인 실패: $e');
    return false;
  }
});

// LaaS AI API 상태 관리 Provider
final laasAiStatusProvider = FutureProvider<bool>((ref) async {
  try {
    return await UnifiedLaaSAPIService.checkAIConnection();
  } catch (e) {
    print('❌ LaaS AI API 연결 확인 실패: $e');
    return false;
  }
});

// 지역별 시군구 목록 Provider
final sigunguListProvider = FutureProviderFamily<List<DropdownItem>, String?>((ref, areaCode) async {
  if (areaCode == null) return [];

  try {
    final response = await UnifiedLaaSAPIService.getAreaCode(areaCode: areaCode);
    final items = UnifiedLaaSAPIService.extractItems(response);

    if (items == null || items.isEmpty) return [DropdownItem(value: null, label: '전체 시군구')];

    final dropdownItems = <DropdownItem>[
      DropdownItem(value: null, label: '전체 시군구'),
    ];

    for (final item in items) {
      dropdownItems.add(DropdownItem(
        value: item['code'],
        label: item['name'],
      ));
    }

    return dropdownItems;
  } catch (e) {
    print('❌ 시군구 목록 조회 실패: $e');
    return [DropdownItem(value: null, label: '전체 시군구')];
  }
});

// 콘텐츠타입별 분류 목록 Provider
final categoryListProvider = FutureProviderFamily<List<DropdownItem>, String?>((ref, contentTypeId) async {
  if (contentTypeId == null) return [];

  try {
    final response = await UnifiedLaaSAPIService.getDetailIntroByCategory(
      contentTypeId: contentTypeId,
      numOfRows: 100,
    );
    final items = UnifiedLaaSAPIService.extractItems(response);

    if (items == null || items.isEmpty) return [DropdownItem(value: null, label: '전체 분류')];

    final dropdownItems = <DropdownItem>[
      DropdownItem(value: null, label: '전체 분류'),
    ];

    for (final item in items) {
      dropdownItems.add(DropdownItem(
        value: item['code'],
        label: item['name'],
      ));
    }

    return dropdownItems;
  } catch (e) {
    print('❌ 분류 목록 조회 실패: $e');
    return [DropdownItem(value: null, label: '전체 분류')];
  }
});

// 지역 코드 목록 Provider
final areaCodeListProvider = FutureProvider<List<DropdownItem>>((ref) async {
  try {
    final response = await UnifiedLaaSAPIService.getAreaCode(numOfRows: 50);
    final items = UnifiedLaaSAPIService.extractItems(response);

    if (items == null || items.isEmpty) {
      return _getFallbackAreaCodes();
    }

    final dropdownItems = <DropdownItem>[
      DropdownItem(value: null, label: '전체 지역'),
    ];

    for (final item in items) {
      dropdownItems.add(DropdownItem(
        value: item['code'],
        label: item['name'],
      ));
    }

    return dropdownItems;
  } catch (e) {
    print('❌ 지역 코드 목록 조회 실패: $e');
    return _getFallbackAreaCodes();
  }
});

// 콘텐츠 타입 목록 Provider
final contentTypeListProvider = Provider<List<DropdownItem>>((ref) {
  const iconMap = {
    '12': '🏔️', '14': '🎭', '15': '🎪', '25': '🗺️',
    '28': '🏃', '32': '🏨', '38': '🛍️', '39': '🍽️',
  };

  const typeNames = {
    '12': '관광지', '14': '문화시설', '15': '축제공연행사', '25': '여행코스',
    '28': '레포츠', '32': '숙박', '38': '쇼핑', '39': '음식점',
  };

  final items = <DropdownItem>[
    DropdownItem(value: null, label: '전체 유형'),
  ];

  typeNames.entries.forEach((entry) {
    final icon = iconMap[entry.key] ?? '📍';
    items.add(DropdownItem(
      value: entry.key,
      label: '$icon ${entry.value}',
    ));
  });

  return items;
});

class AlgorithmRecommendationController {
  final Ref ref;

  AlgorithmRecommendationController(this.ref);

  // AI 추천 데이터 로드 (개선된 버전)
  Future<void> loadAIRecommendations() async {
    // 로딩 상태로 변경
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(hasErrorProvider.notifier).state = false;

    try {
      // LaaS API 연결 상태 확인
      final isApiConnected = await UnifiedLaaSAPIService.checkAPIConnection();
      if (!isApiConnected) {
        throw Exception('LaaS API 연결에 실패했습니다. 네트워크 상태를 확인해주세요.');
      }

      // 사용자 선호도 수집 (향후 확장 가능)
      final userPreferences = _collectUserPreferences();

      // 현재 선택된 필터 값들 가져오기
      final selectedAreaCode = ref.read(selectedAreaCodeProvider);
      final selectedSigunguCode = ref.read(selectedSigunguCodeProvider);
      final selectedContentType = ref.read(selectedContentTypeProvider);
      final selectedCategoryCode = ref.read(selectedCategoryCodeProvider);

      print('🤖 AI 추천 요청: area=$selectedAreaCode, sigungu=$selectedSigunguCode, content=$selectedContentType, category=$selectedCategoryCode');

      // AI 추천 가져오기
      final recommendations = await AIRecommendationService.fetchRecommendations(
        areaCode: selectedAreaCode,
        sigunguCode: selectedSigunguCode,
        contentType: selectedContentType,
        categoryCode: selectedCategoryCode,
        userPreferences: userPreferences,
      );

      // 추천 결과 업데이트
      ref.read(recommendationsProvider.notifier).state = recommendations;
      ref.read(isLoadingProvider.notifier).state = false;

      print('✅ AI 추천 완료: ${recommendations.length}개');

    } catch (e) {
      print('❌ AI 추천 실패: $e');
      ref.read(hasErrorProvider.notifier).state = true;
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(recommendationsProvider.notifier).state = [];
    }
  }

  // 지역 코드 업데이트
  void updateAreaCode(String? areaCode) {
    ref.read(selectedAreaCodeProvider.notifier).state = areaCode;
    // 지역 변경시 시군구 초기화
    ref.read(selectedSigunguCodeProvider.notifier).state = null;
    print('📍 지역 변경: ${_getAreaName(areaCode)}');
  }

  // 시군구 코드 업데이트
  void updateSigunguCode(String? sigunguCode) {
    ref.read(selectedSigunguCodeProvider.notifier).state = sigunguCode;
    print('🏘️ 시군구 변경: $sigunguCode');
  }

  // 콘텐츠 타입 업데이트
  void updateContentType(String? contentType) {
    ref.read(selectedContentTypeProvider.notifier).state = contentType;
    // 콘텐츠타입 변경시 분류 초기화
    ref.read(selectedCategoryCodeProvider.notifier).state = null;
    print('🏷️ 콘텐츠타입 변경: ${_getContentTypeName(contentType)}');
  }

  // 분류 코드 업데이트
  void updateCategoryCode(String? categoryCode) {
    ref.read(selectedCategoryCodeProvider.notifier).state = categoryCode;
    print('📂 분류 변경: $categoryCode');
  }

  // 필터 초기화
  void resetFilters() {
    ref.read(selectedAreaCodeProvider.notifier).state = null;
    ref.read(selectedSigunguCodeProvider.notifier).state = null;
    ref.read(selectedContentTypeProvider.notifier).state = null;
    ref.read(selectedCategoryCodeProvider.notifier).state = null;
    print('🔄 필터 초기화');
  }

  // 현재 필터 상태 가져오기
  Map<String, String?> getCurrentFilters() {
    return {
      'areaCode': ref.read(selectedAreaCodeProvider),
      'sigunguCode': ref.read(selectedSigunguCodeProvider),
      'contentType': ref.read(selectedContentTypeProvider),
      'categoryCode': ref.read(selectedCategoryCodeProvider),
    };
  }

  // 필터 요약 텍스트 생성
  String getFilterSummary() {
    final List<String> filters = [];

    final selectedAreaCode = ref.read(selectedAreaCodeProvider);
    final selectedSigunguCode = ref.read(selectedSigunguCodeProvider);
    final selectedContentType = ref.read(selectedContentTypeProvider);
    final selectedCategoryCode = ref.read(selectedCategoryCodeProvider);

    if (selectedAreaCode != null) {
      String area = _getAreaName(selectedAreaCode);
      if (selectedSigunguCode != null) {
        area += ' 일대';
      }
      filters.add(area);
    }

    if (selectedContentType != null) {
      String type = _getContentTypeName(selectedContentType);
      if (selectedCategoryCode != null) {
        type += ' (세부분류)';
      }
      filters.add(type);
    }

    return filters.isEmpty ? '전체' : filters.join(' • ');
  }

  // 사용자 선호도 수집 (향후 확장)
  Map<String, dynamic> _collectUserPreferences() {
    return {
      'quietLevel': 'high', // 조용함 선호도
      'timeOfDay': 'afternoon', // 선호 시간대
      'activityType': 'relaxation', // 선호 활동
      'budget': 'medium', // 예산 범위
      'weatherPreference': 'any', // 날씨 선호도
    };
  }

  // 지역명 가져오기 (로컬 함수)
  String _getAreaName(String? areaCode) {
    const areaNames = {
      '1': '서울', '2': '인천', '3': '대전', '4': '대구', '5': '광주',
      '6': '부산', '7': '울산', '8': '세종', '31': '경기도', '32': '강원도',
      '33': '충청북도', '34': '충청남도', '35': '경상북도', '36': '경상남도',
      '37': '전라북도', '38': '전라남도', '39': '제주도',
    };
    return areaNames[areaCode] ?? '전국';
  }

  // 콘텐츠 타입명 가져오기 (로컬 함수)
  String _getContentTypeName(String? contentTypeId) {
    const typeNames = {
      '12': '관광지', '14': '문화시설', '15': '축제공연행사', '25': '여행코스',
      '28': '레포츠', '32': '숙박', '38': '쇼핑', '39': '음식점',
    };
    return typeNames[contentTypeId] ?? '모든 유형';
  }

  // 현재 상태 getter들
  List<RecommendationCard> get recommendations => ref.read(recommendationsProvider);
  bool get isLoading => ref.read(isLoadingProvider);
  bool get hasError => ref.read(hasErrorProvider);
  String? get selectedAreaCode => ref.read(selectedAreaCodeProvider);
  String? get selectedSigunguCode => ref.read(selectedSigunguCodeProvider);
  String? get selectedContentType => ref.read(selectedContentTypeProvider);
  String? get selectedCategoryCode => ref.read(selectedCategoryCodeProvider);
}

// 사용자 경험 개선을 위한 Provider들
final recentFiltersProvider = StateProvider<List<Map<String, String?>>>((ref) => []);

// 최근 사용한 필터 저장
void saveRecentFilter(WidgetRef ref, Map<String, String?> filters) {
  final recentFilters = ref.read(recentFiltersProvider);
  final newFilters = [filters, ...recentFilters.where((f) => f != filters).take(4)].toList();
  ref.read(recentFiltersProvider.notifier).state = newFilters;
}

// 폴백 지역 코드 목록
List<DropdownItem> _getFallbackAreaCodes() {
  const areaNames = {
    '1': '서울', '2': '인천', '3': '대전', '4': '대구', '5': '광주',
    '6': '부산', '7': '울산', '8': '세종', '31': '경기도', '32': '강원도',
    '33': '충청북도', '34': '충청남도', '35': '경상북도', '36': '경상남도',
    '37': '전라북도', '38': '전라남도', '39': '제주도',
  };

  final items = <DropdownItem>[
    DropdownItem(value: null, label: '전체 지역'),
  ];

  areaNames.entries.forEach((entry) {
    items.add(DropdownItem(value: entry.key, label: entry.value));
  });

  return items;
}

/// 드롭다운 아이템 모델
class DropdownItem {
  final String? value;
  final String label;

  const DropdownItem({
    required this.value,
    required this.label,
  });
}
