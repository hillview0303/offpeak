import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/recommendation_model.dart';
import '../../../../core/service/ai_recommendation_service.dart';
import '../../../../core/service/tourism_api_service.dart';

// State Providers
final recommendationsProvider = StateProvider<List<RecommendationCard>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final hasErrorProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String>((ref) => '');

// Filter State Providers
final selectedAreaCodeProvider = StateProvider<String?>((ref) => null);
final selectedSigunguCodeProvider = StateProvider<String?>((ref) => null);
final selectedContentTypeProvider = StateProvider<String?>((ref) => null);

// Business Logic Provider
final algorithmRecommendationControllerProvider = Provider<AlgorithmRecommendationController>((ref) {
  return AlgorithmRecommendationController(ref);
});

// 필터 요약 Provider
final filterSummaryProvider = Provider<String>((ref) {
  final controller = ref.watch(algorithmRecommendationControllerProvider);
  return controller.getFilterSummary();
});

// 관광공사 API 상태 관리 Provider
final tourismApiStatusProvider = FutureProvider<bool>((ref) async {
  try {
    return await AIRecommendationService.checkTourismApiConnection();
  } catch (e) {
    print('❌ 관광공사 API 연결 확인 실패: $e');
    return false;
  }
});

// 지역 코드 목록 Provider (간소화)
final areaCodeListProvider = Provider<List<DropdownItem>>((ref) {
  return _getAreaCodes();
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

  /// AI 추천 데이터 로드 (관광공사 API 기반)
  Future<void> loadAIRecommendations() async {
    print('🎯 loadAIRecommendations 시작');

    // 로딩 상태로 변경
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(hasErrorProvider.notifier).state = false;
    ref.read(errorMessageProvider.notifier).state = '';

    try {
      print('🔍 관광공사 API 연결 확인 중...');

      // 관광공사 API 연결 상태 확인
      final isApiConnected = await AIRecommendationService.checkTourismApiConnection();
      print('📡 API 연결 상태: $isApiConnected');

      if (!isApiConnected) {
        throw Exception('관광공사 API 연결에 실패했습니다. 네트워크 상태를 확인해주세요.');
      }

      // 사용자 선호도 수집
      final userPreferences = _collectUserPreferences();
      print('👤 사용자 선호도: $userPreferences');

      // 현재 선택된 필터 값들 가져오기
      final selectedAreaCode = ref.read(selectedAreaCodeProvider);
      final selectedSigunguCode = ref.read(selectedSigunguCodeProvider);
      final selectedContentType = ref.read(selectedContentTypeProvider);

      print('🎯 AI 추천 요청: area=$selectedAreaCode, sigungu=$selectedSigunguCode, content=$selectedContentType');

      // 새로운 AI 추천 가져오기 (관광공사 API 기반)
      final recommendations = await AIRecommendationService.fetchRecommendations(
        areaCode: selectedAreaCode,
        sigunguCode: selectedSigunguCode,
        contentType: selectedContentType,
        userPreferences: userPreferences,
      );

      print('✅ AI 추천 결과: ${recommendations.length}개');

      // 추천 결과 업데이트
      ref.read(recommendationsProvider.notifier).state = recommendations;
      ref.read(isLoadingProvider.notifier).state = false;

      print('✅ AI 추천 완료: ${recommendations.length}개');

    } catch (e, stackTrace) {
      print('❌ AI 추천 실패: $e');
      print('❌ 스택트레이스: $stackTrace');

      ref.read(hasErrorProvider.notifier).state = true;
      ref.read(isLoadingProvider.notifier).state = false;
      ref.read(recommendationsProvider.notifier).state = [];

      // 에러 메시지 설정
      String errorMessage = '추천 서비스에 문제가 발생했습니다.';
      if (e.toString().contains('네트워크')) {
        errorMessage = '인터넷 연결을 확인해주세요.';
      } else if (e.toString().contains('조건에 맞는')) {
        errorMessage = '조건에 맞는 관광지를 찾을 수 없습니다. 다른 조건으로 시도해주세요.';
      } else {
        errorMessage = '오류: ${e.toString()}'; // 임시로 실제 오류 메시지 표시
      }
      ref.read(errorMessageProvider.notifier).state = errorMessage;
    }
  }

  /// 지역 코드 업데이트
  void updateAreaCode(String? areaCode) {
    ref.read(selectedAreaCodeProvider.notifier).state = areaCode;
    // 지역 변경시 시군구 초기화
    ref.read(selectedSigunguCodeProvider.notifier).state = null;
    print('📍 지역 변경: ${_getAreaName(areaCode)}');
  }

  /// 시군구 코드 업데이트
  void updateSigunguCode(String? sigunguCode) {
    ref.read(selectedSigunguCodeProvider.notifier).state = sigunguCode;
    print('🏘️ 시군구 변경: $sigunguCode');
  }

  /// 콘텐츠 타입 업데이트
  void updateContentType(String? contentType) {
    ref.read(selectedContentTypeProvider.notifier).state = contentType;
    print('🏷️ 콘텐츠타입 변경: ${_getContentTypeName(contentType)}');
  }

  /// 필터 초기화
  void resetFilters() {
    ref.read(selectedAreaCodeProvider.notifier).state = null;
    ref.read(selectedSigunguCodeProvider.notifier).state = null;
    ref.read(selectedContentTypeProvider.notifier).state = null;
    print('🔄 필터 초기화');
  }

  /// 현재 필터 상태 가져오기
  Map<String, String?> getCurrentFilters() {
    return {
      'areaCode': ref.read(selectedAreaCodeProvider),
      'sigunguCode': ref.read(selectedSigunguCodeProvider),
      'contentType': ref.read(selectedContentTypeProvider),
    };
  }

  /// 필터 요약 텍스트 생성
  String getFilterSummary() {
    final List<String> filters = [];

    final selectedAreaCode = ref.read(selectedAreaCodeProvider);
    final selectedSigunguCode = ref.read(selectedSigunguCodeProvider);
    final selectedContentType = ref.read(selectedContentTypeProvider);

    if (selectedAreaCode != null) {
      String area = _getAreaName(selectedAreaCode);
      if (selectedSigunguCode != null) {
        area += ' 일대';
      }
      filters.add(area);
    }

    if (selectedContentType != null) {
      filters.add(_getContentTypeName(selectedContentType));
    }

    return filters.isEmpty ? '전체' : filters.join(' • ');
  }

  /// 사용자 선호도 수집 (간소화)
  Map<String, dynamic> _collectUserPreferences() {
    return {
      'quietLevel': 'high', // 조용함 선호도
      'timeOfDay': 'afternoon', // 선호 시간대
      'activityType': 'relaxation', // 선호 활동
      'weatherPreference': 'any', // 날씨 선호도
    };
  }

  /// 지역명 가져오기
  String _getAreaName(String? areaCode) {
    const areaNames = {
      '1': '서울', '2': '인천', '3': '대전', '4': '대구', '5': '광주',
      '6': '부산', '7': '울산', '8': '세종', '31': '경기도', '32': '강원도',
      '33': '충청북도', '34': '충청남도', '35': '경상북도', '36': '경상남도',
      '37': '전라북도', '38': '전라남도', '39': '제주도',
    };
    return areaNames[areaCode] ?? '전국';
  }

  /// 콘텐츠 타입명 가져오기
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
  String get errorMessage => ref.read(errorMessageProvider);
  String? get selectedAreaCode => ref.read(selectedAreaCodeProvider);
  String? get selectedSigunguCode => ref.read(selectedSigunguCodeProvider);
  String? get selectedContentType => ref.read(selectedContentTypeProvider);
}

/// 지역 코드 목록 (간소화)
List<DropdownItem> _getAreaCodes() {
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
