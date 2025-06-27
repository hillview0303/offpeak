import 'dart:math';
import '../../features/home/presentation/providers/recommendation_model.dart';
import 'tourism_api_service.dart' hide CongestionData;

/// 관광공사 API 기반 AI 스타일 추천 서비스 (다양성 개선)
class AIRecommendationService {
  static final Random _random = Random();

  /// 메인 추천 메서드 - 다양성 보장
  static Future<List<RecommendationCard>> fetchRecommendations({
    String? areaCode,
    String? sigunguCode,
    String? contentType,
    String? categoryCode,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      print('🎯 AI 스타일 추천 시작 (다양성 개선)');
      print('📍 필터: area=$areaCode, sigungu=$sigunguCode, content=$contentType');

      List<NearbyPlace> allPlaces = [];

      try {
        // 1. 다양한 페이지에서 장소 수집
        final futures = <Future<List<NearbyPlace>>>[];

        // 페이지 1-3 동시 요청
        for (int page = 1; page <= 3; page++) {
          futures.add(TourismApiService.fetchPlacesByCategory(
            category: _mapContentTypeToCategory(contentType),
            areaCode: areaCode,
            page: page,
          ));
        }

        final results = await Future.wait(futures);

        // 모든 페이지 결과 합치기 (중복 제거)
        final seenIds = <String>{};
        for (final pageResults in results) {
          for (final place in pageResults) {
            if (place.contentId.isNotEmpty && !seenIds.contains(place.contentId)) {
              seenIds.add(place.contentId);
              allPlaces.add(place);
            }
          }
        }

        print('📊 다중 페이지 검색 결과: ${allPlaces.length}개');

        // 2. 결과가 부족하면 전국 검색으로 보완
        if (allPlaces.length < 15 && areaCode != null) {
          print('🔍 전국 검색으로 보완...');
          final additionalPlaces = await TourismApiService.fetchPlacesByCategory(
            category: _mapContentTypeToCategory(contentType),
            page: 1,
          );

          for (final place in additionalPlaces) {
            if (place.contentId.isNotEmpty &&
                !seenIds.contains(place.contentId) &&
                allPlaces.length < 50) {
              seenIds.add(place.contentId);
              allPlaces.add(place);
            }
          }
          print('📊 전국 검색 후 총: ${allPlaces.length}개');
        }

      } catch (e) {
        print('❌ 관광지 검색 실패: $e');
        throw AIServiceException('관광지 정보를 가져올 수 없습니다.');
      }

      if (allPlaces.isEmpty) {
        throw AIServiceException('조건에 맞는 관광지를 찾을 수 없습니다.');
      }

      // 3. 스마트 선택 알고리즘 (다양성 보장)
      final selectedPlaces = _selectDiversePlaces(allPlaces, 8);
      print('✨ 다양성 기반 선택: ${selectedPlaces.length}개');

      // 4. AI 스타일 추천카드로 변환
      final recommendations = await _convertToAIRecommendations(
        selectedPlaces,
        areaCode,
        sigunguCode,
      );

      print('✅ AI 스타일 추천 완료: ${recommendations.length}개 (다양성 개선)');
      return recommendations;

    } catch (e) {
      print('❌ AI 추천 서비스 실패: $e');
      if (e is AIServiceException) rethrow;
      throw AIServiceException('추천 서비스에 문제가 발생했습니다.');
    }
  }

  /// 다양성을 보장하는 장소 선택 알고리즘
  static List<NearbyPlace> _selectDiversePlaces(List<NearbyPlace> allPlaces, int count) {
    if (allPlaces.length <= count) return allPlaces;

    final selected = <NearbyPlace>[];
    final remaining = List<NearbyPlace>.from(allPlaces);

    // 1. 카테고리별 다양성 보장
    final categoryGroups = <String, List<NearbyPlace>>{};
    for (final place in remaining) {
      categoryGroups.putIfAbsent(place.category, () => []).add(place);
    }

    // 2. 각 카테고리에서 최소 1개씩 선택
    for (final category in categoryGroups.keys) {
      if (selected.length >= count) break;

      final categoryPlaces = categoryGroups[category]!;
      if (categoryPlaces.isNotEmpty) {
        final randomIndex = _random.nextInt(categoryPlaces.length);
        final selectedPlace = categoryPlaces[randomIndex];
        selected.add(selectedPlace);
        remaining.remove(selectedPlace);
      }
    }

    // 3. 남은 슬롯을 지역 다양성으로 채우기
    while (selected.length < count && remaining.isNotEmpty) {
      NearbyPlace? bestChoice;
      double maxDiversity = -1;

      for (final candidate in remaining) {
        double diversity = _calculateLocationDiversity(candidate, selected);
        if (diversity > maxDiversity) {
          maxDiversity = diversity;
          bestChoice = candidate;
        }
      }

      if (bestChoice != null) {
        selected.add(bestChoice);
        remaining.remove(bestChoice);
      } else {
        // 다양성 계산 실패시 랜덤 선택
        final randomIndex = _random.nextInt(remaining.length);
        selected.add(remaining.removeAt(randomIndex));
      }
    }

    // 4. 매번 다른 순서로 섞기
    selected.shuffle(_random);

    print('🎲 선택된 장소 다양성:');
    final categoryCount = <String, int>{};
    for (final place in selected) {
      categoryCount[place.category] = (categoryCount[place.category] ?? 0) + 1;
      print('   ${place.name} (${place.category})');
    }
    print('📊 카테고리 분포: $categoryCount');

    return selected;
  }

  /// 지역 다양성 계산
  static double _calculateLocationDiversity(NearbyPlace candidate, List<NearbyPlace> selected) {
    if (selected.isEmpty) return 1.0;

    double totalSimilarity = 0.0;

    for (final existing in selected) {
      final similarity = _calculateAddressSimilarity(candidate.address, existing.address);
      totalSimilarity += similarity;
    }

    return 1.0 - (totalSimilarity / selected.length);
  }

  /// 주소 기반 유사성 계산
  static double _calculateAddressSimilarity(String addr1, String addr2) {
    final words1 = addr1.split(' ').where((w) => w.isNotEmpty).toList();
    final words2 = addr2.split(' ').where((w) => w.isNotEmpty).toList();

    if (words1.isEmpty || words2.isEmpty) return 0.0;

    int commonWords = 0;
    for (final word in words1) {
      if (words2.contains(word)) {
        commonWords++;
      }
    }

    return commonWords / max(words1.length, words2.length);
  }

  /// AI 스타일 추천카드로 변환 (필수 필드만)
  static Future<List<RecommendationCard>> _convertToAIRecommendations(
      List<NearbyPlace> places,
      String? areaCode,
      String? sigunguCode,
      ) async {
    final recommendations = <RecommendationCard>[];

    for (int i = 0; i < places.length; i++) {
      final place = places[i];

      try {
        // 상세 정보 가져오기
        String detailedDescription = place.description;
        if (place.contentId.isNotEmpty) {
          try {
            final detail = await TourismApiService.fetchPlaceDetail(place.contentId);
            if (detail != null && detail.description.isNotEmpty) {
              detailedDescription = detail.description;
            }
          } catch (e) {
            print('⚠️ 상세 정보 조회 실패: ${place.name} - $e');
          }
        }

        // 혼잡도 데이터 가져오기
        CongestionData? congestionData;
        if (place.contentId.isNotEmpty) {
          try {
            print('📊 ${place.name} 혼잡도 조회 중...');
            congestionData = await TourismApiService.fetchCongestionData(
              contentId: place.contentId,
              areaCode: areaCode,
              sigunguCode: sigunguCode,
            );
            print('✅ ${place.name} 혼잡도: ${congestionData?.currentLevel}%');
          } catch (e) {
            print('⚠️ ${place.name} 혼잡도 조회 실패: $e');
          }
        }

        // 혼잡도 데이터가 없으면 기본값 생성
        congestionData ??= _generateDefaultCongestionData(place);

        // ✨ 간소화된 추천카드 생성 (필수 필드만)
        final recommendation = RecommendationCard(
          contentId: place.contentId,
          title: place.name,
          location: place.address,
          description: detailedDescription.isNotEmpty
              ? detailedDescription
              : '${place.name}에서 특별한 여행 경험을 만끽해보세요.',
          rating: 4.5, // 고정값
          matchPercentage: 90, // 고정값
          congestionLevel: congestionData.currentLevel,
          reason: '', // 빈 값
          imageUrl: '', // 별도 로드
          contentTypeId: _mapCategoryToContentTypeId(place.category) ?? '12',
          transportation: '', // 빈 값
          quietReason: '', // 빈 값
          recommendedActivity: '', // 빈 값
          weatherSuitability: '', // 빈 값
        );

        recommendations.add(recommendation);
      } catch (e) {
        print('❌ 추천카드 생성 실패: ${place.name} - $e');
      }
    }

    // 최종 랜덤 섞기
    recommendations.shuffle(_random);

    return recommendations;
  }

  /// 기본 혼잡도 데이터 생성 (간소화)
  static CongestionData _generateDefaultCongestionData(NearbyPlace place) {
    final baseSeed = place.name.hashCode + (place.category.hashCode * 7);
    final timeSeed = DateTime.now().hour;
    final seededRandom = Random(baseSeed + timeSeed);

    int baseLevel;
    int baseVisitors;
    String baseRecommendedTime;

    switch (place.category) {
      case 'tourist_spot':
        baseLevel = 20 + seededRandom.nextInt(30);
        baseVisitors = 100 + seededRandom.nextInt(250);
        baseRecommendedTime = '평일 오전 권장';
        break;
      case 'culture':
        baseLevel = 10 + seededRandom.nextInt(25);
        baseVisitors = 60 + seededRandom.nextInt(140);
        baseRecommendedTime = '언제든지 방문 가능';
        break;
      case 'restaurant':
        baseLevel = 30 + seededRandom.nextInt(25);
        baseVisitors = 150 + seededRandom.nextInt(200);
        baseRecommendedTime = '식사시간 외 권장';
        break;
      case 'accommodation':
        baseLevel = 15 + seededRandom.nextInt(20);
        baseVisitors = 40 + seededRandom.nextInt(100);
        baseRecommendedTime = '평일 예약 권장';
        break;
      default:
        baseLevel = 15 + seededRandom.nextInt(35);
        baseVisitors = 80 + seededRandom.nextInt(170);
        baseRecommendedTime = '오전 시간 권장';
    }

    // 지역별 조정
    if (place.address.contains('서울')) {
      baseLevel += 5 + seededRandom.nextInt(10);
      baseVisitors = (baseVisitors * (1.3 + seededRandom.nextDouble() * 0.4)).round();
    } else if (place.address.contains('부산') || place.address.contains('제주')) {
      baseLevel += seededRandom.nextInt(8);
      baseVisitors = (baseVisitors * (1.1 + seededRandom.nextDouble() * 0.3)).round();
    }

    final expectedVisitors = (baseVisitors * (0.85 + seededRandom.nextDouble() * 0.3)).round();

    return CongestionData(
      currentLevel: baseLevel.clamp(10, 85),
      lastWeekVisitors: baseVisitors,
      expectedVisitors: expectedVisitors,
      recommendedTime: baseRecommendedTime,
      peakTime: _generatePeakTime(place.category),
      predictedVisitors: null,
      dataSource: 'generated_diverse',
    );
  }

  /// 피크 시간 생성
  static String _generatePeakTime(String category) {
    switch (category) {
      case 'tourist_spot':
        return '주말 오후 1-4시';
      case 'culture':
        return '주말 오전 10-12시';
      case 'restaurant':
        return '점심(12-2시), 저녁(6-8시)';
      case 'accommodation':
        return '주말 및 연휴';
      case 'shopping':
        return '주말 오후 2-6시';
      default:
        return '주말 오후';
    }
  }

  // ==================== 유틸리티 메서드들 ====================

  /// 컨텐츠 타입을 카테고리로 변환
  static String _mapContentTypeToCategory(String? contentTypeId) {
    switch (contentTypeId) {
      case '12': return '관광지';
      case '14': return '문화시설';
      case '15': return '축제공연행사';
      case '25': return '여행코스';
      case '28': return '레포츠';
      case '32': return '숙박';
      case '38': return '쇼핑';
      case '39': return '음식점';
      default: return '관광지';
    }
  }

  /// 카테고리를 컨텐츠 타입으로 변환
  static String? _mapCategoryToContentTypeId(String category) {
    switch (category) {
      case 'tourist_spot': return '12';
      case 'culture': return '14';
      case 'festival': return '15';
      case 'course': return '25';
      case 'leisure': return '28';
      case 'accommodation': return '32';
      case 'shopping': return '38';
      case 'restaurant': return '39';
      default: return '12';
    }
  }

  /// HTTP 연결 상태 확인
  static Future<bool> checkTourismApiConnection() async {
    try {
      print('🔍 관광공사 API 연결 확인 시작...');

      final places = await TourismApiService.fetchPlacesByCategory(
        category: '관광지',
        page: 1,
      );

      print('✅ 관광공사 API 연결 성공: ${places.length}개 장소 조회됨');
      return true;

    } catch (e) {
      print('❌ 관광공사 API 연결 확인 실패: $e');
      return false;
    }
  }
}

/// AI 서비스 예외 클래스
class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => message;
}
