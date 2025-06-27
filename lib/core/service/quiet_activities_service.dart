import 'dart:math';
import 'package:offpeak/core/service/tourism_api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// 조용한 활동 전용 서비스
class QuietActivitiesService {
  static final Random _random = Random();

  // 주간 추천 캐시 (1주일 유지)
  static final Map<String, WeeklyRecommendationCache> _weeklyCache = {};

  /// 이번주 추천 장소 가져오기 (1주일마다 변경)
  static Future<List<QuietPlace>> getWeeklyRecommendations(String categoryTitle) async {
    try {
      final weekKey = _getWeekKey();
      final cacheKey = '${categoryTitle}_$weekKey';

      // 캐시 확인
      if (_weeklyCache.containsKey(cacheKey)) {
        final cache = _weeklyCache[cacheKey]!;
        if (cache.isValid()) {
          print('📅 이번주 추천 캐시 사용: $categoryTitle');
          return cache.places;
        }
      }

      print('🔄 이번주 추천 새로 생성: $categoryTitle');

      // 카테고리에 맞는 API 호출
      final contentType = _mapCategoryToContentType(categoryTitle);
      final areaCode = null; // 전국 검색

      List<NearbyPlace> apiPlaces = [];

      try {
        // 여러 페이지에서 랜덤하게 수집
        final randomPage = 1 + _random.nextInt(3); // 1-3페이지 중 랜덤

        apiPlaces = await TourismApiService.fetchPlacesByCategory(
          category: contentType,
          areaCode: areaCode,
          page: randomPage,
        );

        print('✅ API 조회 성공: ${apiPlaces.length}개 (페이지: $randomPage)');
      } catch (e) {
        print('❌ API 조회 실패, 기본 데이터 사용: $e');
        apiPlaces = _getFallbackPlaces(categoryTitle);
      }

      // 랜덤하게 3개 선택
      final selectedPlaces = _selectRandomPlaces(apiPlaces, 3);

      // 🔧 수정: 실제 API 데이터에서 상세 정보를 가져와서 설명 생성
      final quietPlaces = <QuietPlace>[];

      for (final place in selectedPlaces) {
        // 각 장소의 상세 정보 조회하여 실제 설명 가져오기
        String description = _generateDescription(place.name, categoryTitle);

        if (place.contentId.isNotEmpty) {
          try {
            final placeDetail = await TourismApiService.fetchPlaceDetail(place.contentId);
            if (placeDetail != null && placeDetail.description.isNotEmpty) {
              // 실제 API에서 가져온 설명을 전체로 사용 (UI에서 줄 수 제한)
              description = _cleanDescription(placeDetail.description);
              print('✅ ${place.name} 실제 설명 조회 성공');
            }
          } catch (e) {
            print('⚠️ ${place.name} 상세 정보 조회 실패, 기본 설명 사용: $e');
          }
        }

        final quietPlace = QuietPlace(
          id: place.contentId,
          name: place.name,
          location: place.address,
          description: description,
          distance: 1.0 + (_random.nextDouble() * 3.0), // 1.0-4.0km (이번주 추천용 임시값)
          category: categoryTitle,
          isRecommended: true,
          areaCode: place.areaCode,        // 🔧 추가
          sigunguCode: place.sigunguCode,  // 🔧 추가
        );

        quietPlaces.add(quietPlace);
      }

      // 캐시 저장
      _weeklyCache[cacheKey] = WeeklyRecommendationCache(
        places: quietPlaces,
        createdAt: DateTime.now(),
      );

      print('💾 이번주 추천 캐시 저장: ${quietPlaces.length}개');
      return quietPlaces;

    } catch (e) {
      print('❌ 이번주 추천 조회 실패: $e');
      return _getFallbackWeeklyRecommendations(categoryTitle);
    }
  }

  /// 전체 장소 목록 가져오기 (페이지네이션)
  static Future<QuietPlacesResult> getAllPlaces(
      String categoryTitle, {
        int page = 1,
        int itemsPerPage = 10,
      }) async {
    try {
      print('📄 전체 장소 조회: $categoryTitle (페이지: $page)');

      final contentType = _mapCategoryToContentType(categoryTitle);

      List<NearbyPlace> apiPlaces = [];

      try {
        apiPlaces = await TourismApiService.fetchPlacesByCategory(
          category: contentType,
          areaCode: null, // 전국 검색
          page: page,
        );

        print('✅ API 조회 성공: ${apiPlaces.length}개');
      } catch (e) {
        print('❌ API 조회 실패, 기본 데이터 사용: $e');
        apiPlaces = _getFallbackPlaces(categoryTitle);
      }

      // 🔧 수정: 전체 설명 사용 (UI에서 줄 수 제한)
      final quietPlaces = apiPlaces.map((place) => QuietPlace(
        id: place.contentId,
        name: place.name,
        location: place.address,
        description: place.description.isNotEmpty
            ? _cleanDescription(place.description)
            : _generateDescription(place.name, categoryTitle),
        distance: 0.5 + (_random.nextDouble() * 9.5), // 0.5-10km (전체보기용 임시값)
        category: categoryTitle,
        isRecommended: false,
      )).toList();

      return QuietPlacesResult(
        places: quietPlaces,
        currentPage: page,
        hasNextPage: quietPlaces.length >= itemsPerPage,
        totalCount: quietPlaces.length,
      );

    } catch (e) {
      print('❌ 전체 장소 조회 실패: $e');
      return QuietPlacesResult(
        places: _getFallbackAllPlaces(categoryTitle),
        currentPage: page,
        hasNextPage: false,
        totalCount: 0,
      );
    }
  }

  /// 내 주변 장소 검색 (위치 기반)
  static Future<List<QuietPlace>> getNearbyPlaces(
      String categoryTitle, {
        required double latitude,
        required double longitude,
        double radiusKm = 2.0,
      }) async {
    try {
      print('📍 내 주변 장소 검색: $categoryTitle (반경: ${radiusKm}km)');

      final contentType = _mapCategoryToContentType(categoryTitle);

      List<NearbyPlace> apiPlaces = [];

      try {
        apiPlaces = await TourismApiService.fetchNearbyPlaces(
          latitude: latitude,
          longitude: longitude,
          category: contentType,
          radius: (radiusKm * 1000).round(), // km를 m로 변환
        );

        print('✅ 내 주변 API 조회 성공: ${apiPlaces.length}개');
      } catch (e) {
        print('❌ 내 주변 API 조회 실패, 기본 데이터 사용: $e');
        apiPlaces = _getFallbackNearbyPlaces(categoryTitle);
      }

      // 🔧 수정: 실제 거리 계산하여 QuietPlace로 변환
      final quietPlaces = <QuietPlace>[];

      for (final place in apiPlaces) {
        // 실제 거리 계산
        double calculatedDistance = 0.0;

        try {
          // NearbyPlace에서 좌표 정보 가져오기 (관광공사 API의 mapx, mapy)
          if (place.latitude != null && place.longitude != null) {
            calculatedDistance = Geolocator.distanceBetween(
                latitude,
                longitude,
                place.latitude!,
                place.longitude!
            ) / 1000; // 미터를 킬로미터로 변환
            print('✅ ${place.name} 좌표 기반 거리 계산: ${calculatedDistance.toStringAsFixed(2)}km');
          } else {
            // 좌표가 없으면 주소로 geocoding 시도
            try {
              final locations = await locationFromAddress(place.address);
              if (locations.isNotEmpty) {
                final location = locations.first;
                calculatedDistance = Geolocator.distanceBetween(
                    latitude,
                    longitude,
                    location.latitude,
                    location.longitude
                ) / 1000;
                print('✅ ${place.name} 주소 기반 거리 계산: ${calculatedDistance.toStringAsFixed(2)}km');
              }
            } catch (e) {
              print('⚠️ ${place.name} 주소 geocoding 실패: $e');
              calculatedDistance = 1.0 + _random.nextDouble() * 2.0; // 폴백 거리
            }
          }
        } catch (e) {
          print('⚠️ ${place.name} 거리 계산 실패: $e');
          calculatedDistance = 1.0 + _random.nextDouble() * 2.0; // 폴백 거리
        }

        final quietPlace = QuietPlace(
          id: place.contentId,
          name: place.name,
          location: place.address,
          description: place.description.isNotEmpty
              ? _cleanDescription(place.description)
              : _generateDescription(place.name, categoryTitle),
          distance: calculatedDistance,
          category: categoryTitle,
          isRecommended: false,
        );

        quietPlaces.add(quietPlace);
      }

      // 거리순 정렬
      quietPlaces.sort((a, b) => a.distance.compareTo(b.distance));

      return quietPlaces;

    } catch (e) {
      print('❌ 내 주변 장소 조회 실패: $e');
      return _getFallbackNearbyPlaces(categoryTitle).map((place) => QuietPlace(
        id: place.contentId,
        name: place.name,
        location: place.address,
        description: _generateDescription(place.name, categoryTitle),
        distance: 1.0 + (_random.nextDouble() * 1.0), // 1-2km
        category: categoryTitle,
        isRecommended: false,
      )).toList();
    }
  }

  // ==================== 유틸리티 메서드들 ====================

  /// 🔧 수정: HTML 태그만 제거하고 전체 설명 반환 (UI에서 줄 수 제한)
  static String _cleanDescription(String description) {
    if (description.isEmpty) return '';

    // HTML 태그와 특수문자만 제거하고 전체 텍스트 반환
    String cleaned = description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }

  /// 주차별 키 생성 (1주일마다 변경)
  static String _getWeekKey() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final weekNumber = ((now.difference(startOfYear).inDays) / 7).floor();
    return '${now.year}_$weekNumber';
  }

  /// 카테고리를 관광공사 API 카테고리로 매핑
  static String _mapCategoryToContentType(String categoryTitle) {
    switch (categoryTitle) {
      case '도서관 투어':
        return '문화시설';
      case '미술관 관람':
        return '문화시설';
      case '조용한 카페':
        return '음식점';
      case '산책로 걷기':
        return '관광지';
      case '명상 공간':
        return '문화시설';
      default:
        return '관광지';
    }
  }

  /// 랜덤 장소 선택
  static List<NearbyPlace> _selectRandomPlaces(List<NearbyPlace> places, int count) {
    if (places.length <= count) return places;

    final shuffled = List<NearbyPlace>.from(places);
    shuffled.shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// 설명 생성 (폴백용)
  static String _generateDescription(String placeName, String category) {
    switch (category) {
      case '도서관 투어':
        return '조용한 독서와 학습을 위한 완벽한 공간입니다. 편안한 환경에서 책과 함께하는 시간을 보내세요.';
      case '미술관 관람':
        return '예술과 문화를 감상할 수 있는 조용하고 아름다운 공간입니다. 마음의 여유를 찾아보세요.';
      case '조용한 카페':
        return '책이나 업무에 집중할 수 있는 조용하고 아늑한 분위기의 카페입니다.';
      case '산책로 걷기':
        return '자연 속에서 조용히 걸으며 마음의 평화를 찾을 수 있는 산책로입니다.';
      case '명상 공간':
        return '마음의 평안과 내적 고요를 위한 명상과 힐링이 가능한 공간입니다.';
      default:
        return '조용하고 평화로운 시간을 보낼 수 있는 특별한 공간입니다.';
    }
  }

  /// 거리 문자열 파싱
  static double _parseDistance(String distanceStr) {
    try {
      final match = RegExp(r'(\d+\.?\d*)').firstMatch(distanceStr);
      if (match != null) {
        return double.parse(match.group(1)!);
      }
    } catch (e) {
      print('거리 파싱 실패: $distanceStr');
    }
    return 1.0 + _random.nextDouble() * 2.0; // 기본값 1-3km
  }

  // ==================== 폴백 데이터 ====================

  static List<NearbyPlace> _getFallbackPlaces(String categoryTitle) {
    // API 실패시 기본 데이터
    return [
      NearbyPlace(
        contentId: 'fallback_1',
        name: '${categoryTitle} 기본 장소 1',
        address: '서울시 중구 명동',
        distance: '1.2km',
        category: 'culture',
        rating: 4.5,
        isOpen: true,
        description: _generateDescription('기본 장소 1', categoryTitle),
        reason: '조용한 환경',
        tip: '평일 방문 권장',
      ),
      NearbyPlace(
        contentId: 'fallback_2',
        name: '${categoryTitle} 기본 장소 2',
        address: '서울시 강남구 신사동',
        distance: '2.1km',
        category: 'culture',
        rating: 4.3,
        isOpen: true,
        description: _generateDescription('기본 장소 2', categoryTitle),
        reason: '접근성 좋음',
        tip: '오후 시간 추천',
      ),
    ];
  }

  static List<QuietPlace> _getFallbackWeeklyRecommendations(String categoryTitle) {
    return [
      QuietPlace(
        id: 'weekly_1',
        name: '이번주 추천 ${categoryTitle} 1',
        location: '서울시 종로구',
        description: _generateDescription('추천 장소 1', categoryTitle),
        distance: 1.5,
        category: categoryTitle,
        isRecommended: true,
      ),
      QuietPlace(
        id: 'weekly_2',
        name: '이번주 추천 ${categoryTitle} 2',
        location: '서울시 마포구',
        description: _generateDescription('추천 장소 2', categoryTitle),
        distance: 2.1,
        category: categoryTitle,
        isRecommended: true,
      ),
      QuietPlace(
        id: 'weekly_3',
        name: '이번주 추천 ${categoryTitle} 3',
        location: '서울시 강남구',
        description: _generateDescription('추천 장소 3', categoryTitle),
        distance: 1.8,
        category: categoryTitle,
        isRecommended: true,
      ),
    ];
  }

  static List<QuietPlace> _getFallbackAllPlaces(String categoryTitle) {
    return List.generate(5, (index) => QuietPlace(
      id: 'all_${index + 1}',
      name: '${categoryTitle} 장소 ${index + 1}',
      location: '서울시 ${['중구', '강남구', '마포구', '종로구', '서초구'][index]}',
      description: _generateDescription('장소 ${index + 1}', categoryTitle),
      distance: 1.0 + (_random.nextDouble() * 4.0),
      category: categoryTitle,
      isRecommended: false,
    ));
  }

  static List<NearbyPlace> _getFallbackNearbyPlaces(String categoryTitle) {
    return [
      NearbyPlace(
        contentId: 'nearby_1',
        name: '내 주변 ${categoryTitle} 1',
        address: '서울시 현재 위치 근처',
        distance: '0.8km',
        category: 'culture',
        rating: 4.7,
        isOpen: true,
        description: _generateDescription('근처 장소 1', categoryTitle),
        reason: '가까운 거리',
        tip: '도보 이용 가능',
      ),
    ];
  }
}

// ==================== 모델 클래스들 ====================

/// 조용한 활동 장소 모델
class QuietPlace {
  final String id;
  final String name;
  final String location;
  final String description;
  final double distance;
  final String category;
  final bool isRecommended;
  // 🔧 추가: 혼잡도 API용 지역코드
  final String? areaCode;
  final String? sigunguCode;

  const QuietPlace({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.distance,
    required this.category,
    required this.isRecommended,
    this.areaCode,
    this.sigunguCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'distance': distance,
      'areaCode': areaCode,
      'sigunguCode': sigunguCode,
    };
  }
}

/// 조용한 활동 장소 결과 (페이지네이션)
class QuietPlacesResult {
  final List<QuietPlace> places;
  final int currentPage;
  final bool hasNextPage;
  final int totalCount;

  const QuietPlacesResult({
    required this.places,
    required this.currentPage,
    required this.hasNextPage,
    required this.totalCount,
  });
}

/// 주간 추천 캐시
class WeeklyRecommendationCache {
  final List<QuietPlace> places;
  final DateTime createdAt;

  const WeeklyRecommendationCache({
    required this.places,
    required this.createdAt,
  });

  bool isValid() {
    final now = DateTime.now();
    final weeksDiff = now.difference(createdAt).inDays / 7;
    return weeksDiff < 1.0; // 1주일 미만이면 유효
  }
}
