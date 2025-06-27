import 'package:offpeak/core/service/tourism_api_service.dart';

/// 교통편별 여행지 추천 서비스
class TransportationTravelService {

  /// 교통수단별 여행지 조회
  static Future<List<NearbyPlace>> fetchPlacesByTransportation({
    required String transportation,
    String? areaCode = '6', // 기본값: 부산
    int maxResults = 8,
  }) async {
    try {
      print('🚗 $transportation 여행지 조회 시작');

      final config = _getTransportationConfig(transportation);
      final allPlaces = <NearbyPlace>[];

      // 1단계: 메인 카테고리로 조회
      for (final category in config.categories) {
        try {
          final places = await TourismApiService.fetchPlacesByCategory(
            category: category,
            areaCode: areaCode,
            page: 1,
          );

          // 중복 제거하며 추가
          for (final place in places) {
            if (!allPlaces.any((p) => p.contentId == place.contentId)) {
              allPlaces.add(place);
            }
          }

          if (allPlaces.length >= maxResults) break;
        } catch (e) {
          print('⚠️ 카테고리 $category 조회 실패: $e');
        }
      }

      // 2단계: 키워드 검색으로 보완
      if (allPlaces.length < maxResults) {
        for (final keyword in config.keywords) {
          try {
            final searchResults = await TourismApiService.searchPlaces(
              keyword: keyword,
              areaCode: areaCode,
              page: 1,
            );

            for (final place in searchResults) {
              if (!allPlaces.any((p) => p.contentId == place.contentId)) {
                allPlaces.add(place);
                if (allPlaces.length >= maxResults * 2) break; // 필터링 전 여유분
              }
            }

            if (allPlaces.length >= maxResults * 2) break;
          } catch (e) {
            print('⚠️ 키워드 $keyword 검색 실패: $e');
          }
        }
      }

      // 3단계: 교통수단별 스마트 필터링
      final filteredPlaces = _filterPlacesByTransportation(allPlaces, transportation);

      // 4단계: 점수 기반 정렬
      final scoredPlaces = _scorePlacesForTransportation(filteredPlaces, transportation);

      final result = scoredPlaces.take(maxResults).toList();

      print('✅ $transportation: ${result.length}개 여행지 조회 완료');
      return result;

    } catch (e) {
      print('❌ $transportation 여행지 조회 실패: $e');
      return _getDefaultPlaces(transportation);
    }
  }

  /// 교통수단별 설정 조회
  static _TransportationConfig _getTransportationConfig(String transportation) {
    switch (transportation) {
      case '도보':
        return _TransportationConfig(
          categories: ['관광지', '문화시설'],
          keywords: ['공원', '거리', '산책로', '보행로', '도보', '걷기', '광장'],
          includeKeywords: ['공원', '거리', '길', '산책', '보행', '광장', '마을', '올레', '둘레'],
          excludeKeywords: ['캠핑', '서핑', '스키', '골프', '낚시', '자동차', '오토바이'],
          preferredTypes: ['tourist_spot', 'culture'],
        );

      case '대중교통':
        return _TransportationConfig(
          categories: ['문화시설', '관광지', '쇼핑'],
          keywords: ['지하철', '버스', '역', '박물관', '미술관', '전시관'],
          includeKeywords: ['역', '터미널', '박물관', '미술관', '전시', '문화', '쇼핑', '백화점'],
          excludeKeywords: ['캠핑', '서핑', '낚시', '등산', '해수욕', '드라이브'],
          preferredTypes: ['culture', 'tourist_spot', 'shopping'],
        );

      case '드라이브':
        return _TransportationConfig(
          categories: ['관광지', '레포츠'],
          keywords: ['드라이브', '전망', '해안도로', '산길', '코스', '경치'],
          includeKeywords: ['드라이브', '전망', '해안', '산', '고개', '길', '코스', '경치', '풍경'],
          excludeKeywords: ['도보', '걷기', '산책', '지하철', '버스'],
          preferredTypes: ['tourist_spot', 'leisure'],
        );

      case '자전거':
        return _TransportationConfig(
          categories: ['관광지'], // 레포츠 카테고리 제외 (구기종목 때문에)
          keywords: ['자전거길', '강변길', '둘레길', '공원'], // 더 구체적인 키워드만
          includeKeywords: ['자전거길', '자전거도로', '자전거코스', '사이클링', '라이딩코스', '강변길', '둘레길', '자전거공원'],
          excludeKeywords: [
            '서핑', '캠핑', '스키', '골프', '낚시', '등산',
            '야구', '축구', '농구', '배구', '테니스', '배드민턴',
            '인라인', '롤러', '스케이트', '볼링', '당구', '탁구',
            '수영', '헬스', '클라이밍', '암벽', '스쿼시', '요가',
            '구장', '경기장', '체육관', '운동장', '코트'
          ],
          preferredTypes: ['tourist_spot'], // leisure 타입 제외
        );

      default:
        return _TransportationConfig(
          categories: ['관광지'],
          keywords: ['여행'],
          includeKeywords: [],
          excludeKeywords: [],
          preferredTypes: ['tourist_spot'],
        );
    }
  }

  /// 교통수단별 스마트 필터링
  static List<NearbyPlace> _filterPlacesByTransportation(
      List<NearbyPlace> places,
      String transportation
      ) {
    final config = _getTransportationConfig(transportation);

    return places.where((place) {
      final name = place.name.toLowerCase();
      final address = place.address.toLowerCase();
      final description = place.description.toLowerCase();
      final searchText = '$name $address $description';

      // 🔧 자전거의 경우 더 엄격한 필터링
      if (transportation == '자전거') {
        // 명시적으로 제외할 키워드들 (우선 체크)
        for (final excludeKeyword in config.excludeKeywords) {
          if (searchText.contains(excludeKeyword.toLowerCase())) {
            print('🚫 자전거 제외: ${place.name} (키워드: $excludeKeyword)');
            return false;
          }
        }

        // 자전거 관련 키워드가 명시적으로 포함된 경우만 허용
        bool hasValidKeyword = false;
        for (final includeKeyword in config.includeKeywords) {
          if (searchText.contains(includeKeyword.toLowerCase())) {
            hasValidKeyword = true;
            print('✅ 자전거 포함: ${place.name} (키워드: $includeKeyword)');
            break;
          }
        }

        // 자전거 관련 키워드가 없으면서 공원이라는 단어만 있는 경우도 허용 (단, 다른 스포츠 시설이 아닌 경우)
        if (!hasValidKeyword && name.contains('공원')) {
          // 하지만 스포츠 관련 키워드가 있으면 제외
          final sportsKeywords = ['경기장', '체육', '운동장', '구장', '코트', '클럽', '센터'];
          bool hasSportsKeyword = false;
          for (final sportsKeyword in sportsKeywords) {
            if (searchText.contains(sportsKeyword)) {
              hasSportsKeyword = true;
              break;
            }
          }

          if (!hasSportsKeyword) {
            hasValidKeyword = true;
            print('✅ 자전거 공원 허용: ${place.name}');
          } else {
            print('🚫 자전거 스포츠시설 제외: ${place.name}');
          }
        }

        return hasValidKeyword;
      }

      // 다른 교통수단들은 기존 로직 유지
      // 제외 키워드가 포함된 경우 필터링
      for (final excludeKeyword in config.excludeKeywords) {
        if (searchText.contains(excludeKeyword.toLowerCase())) {
          print('🚫 제외: ${place.name} (키워드: $excludeKeyword)');
          return false;
        }
      }

      // 포함 키워드가 있는 경우 우선 선택
      for (final includeKeyword in config.includeKeywords) {
        if (searchText.contains(includeKeyword.toLowerCase())) {
          print('✅ 포함: ${place.name} (키워드: $includeKeyword)');
          return true;
        }
      }

      // 선호 카테고리인 경우 포함
      if (config.preferredTypes.contains(place.category)) {
        print('✅ 카테고리: ${place.name} (${place.category})');
        return true;
      }

      // 특별한 조건이 없으면 포함 (기본적으로 허용)
      return true;
    }).toList();
  }

  /// 교통수단별 점수 계산 및 정렬
  static List<NearbyPlace> _scorePlacesForTransportation(
      List<NearbyPlace> places,
      String transportation
      ) {
    final config = _getTransportationConfig(transportation);

    // 각 장소에 점수 부여
    final scoredPlaces = places.map((place) {
      double score = 0.0;
      final name = place.name.toLowerCase();
      final address = place.address.toLowerCase();
      final description = place.description.toLowerCase();
      final searchText = '$name $address $description';

      // 기본 점수 (거리 기반으로 변경)
      if (place.distance.contains('도보')) {
        score += 40.0;
      } else if (place.distance.contains('km')) {
        final distanceText = place.distance.replaceAll(RegExp(r'[^0-9.]'), '');
        final distance = double.tryParse(distanceText) ?? 10.0;
        score += (10.0 - distance).clamp(0.0, 30.0);
      } else {
        score += 20.0; // 기본 점수
      }

      // 포함 키워드 점수 (높은 가중치)
      for (final keyword in config.includeKeywords) {
        if (searchText.contains(keyword.toLowerCase())) {
          score += 50.0;
          // 이름에 직접 포함된 경우 추가 점수
          if (name.contains(keyword.toLowerCase())) {
            score += 30.0;
          }
        }
      }

      // 선호 카테고리 점수
      if (config.preferredTypes.contains(place.category)) {
        score += 20.0;
      }

      // 거리 점수 (가까울수록 높은 점수)
      if (place.distance.contains('도보')) {
        score += 15.0;
      } else if (place.distance.contains('km')) {
        final distanceText = place.distance.replaceAll(RegExp(r'[^0-9.]'), '');
        final distance = double.tryParse(distanceText) ?? 10.0;
        score += (10.0 - distance).clamp(0.0, 10.0);
      }

      // 교통수단별 특별 점수
      score += _getSpecialScore(place, transportation);

      return MapEntry(place, score);
    }).toList();

    // 점수 기준으로 정렬
    scoredPlaces.sort((a, b) => b.value.compareTo(a.value));

    // 점수 로깅 (상위 10개)
    print('📊 $transportation 점수 순위:');
    for (int i = 0; i < scoredPlaces.length && i < 10; i++) {
      final entry = scoredPlaces[i];
      print('   ${i+1}. ${entry.key.name}: ${entry.value.toStringAsFixed(1)}점');
    }

    return scoredPlaces.map((entry) => entry.key).toList();
  }

  /// 교통수단별 특별 점수
  static double _getSpecialScore(NearbyPlace place, String transportation) {
    final name = place.name.toLowerCase();
    final address = place.address.toLowerCase();

    switch (transportation) {
      case '도보':
      // 공원, 문화시설, 관광지 우대
        if (name.contains('공원') || name.contains('정원')) return 25.0;
        if (name.contains('박물관') || name.contains('미술관')) return 20.0;
        if (name.contains('거리') || name.contains('광장')) return 20.0;
        if (name.contains('마을') || name.contains('골목')) return 15.0;
        break;

      case '대중교통':
      // 역 근처, 문화시설 우대
        if (address.contains('역') || name.contains('역')) return 25.0;
        if (name.contains('박물관') || name.contains('미술관')) return 20.0;
        if (name.contains('쇼핑') || name.contains('백화점')) return 15.0;
        if (name.contains('터미널')) return 15.0;
        break;

      case '드라이브':
      // 경치 좋은 곳, 전망대 우대
        if (name.contains('전망') || name.contains('뷰')) return 25.0;
        if (name.contains('해안') || name.contains('바다')) return 20.0;
        if (name.contains('산') || name.contains('고개')) return 20.0;
        if (name.contains('길') && name.contains('드라이브')) return 25.0;
        break;

      case '자전거':
      // 자전거 도로, 강변, 공원 우대
        if (name.contains('자전거') && (name.contains('길') || name.contains('도로') || name.contains('코스'))) return 30.0;
        if (name.contains('라이딩') || name.contains('사이클')) return 25.0;
        if (name.contains('강') && name.contains('길')) return 25.0;
        if (name.contains('둘레길') || name.contains('산책로')) return 20.0;
        if (name.contains('공원') && !name.contains('놀이') && !name.contains('체육') && !name.contains('운동')) return 15.0;
        // 스포츠 시설이면 감점
        if (name.contains('경기장') || name.contains('체육관') || name.contains('구장')) return -50.0;
        break;
    }

    return 0.0;
  }

  /// 기본 데이터 (API 실패시 사용)
  static List<NearbyPlace> _getDefaultPlaces(String transportation) {
    switch (transportation) {
      case '도보':
        return [
          NearbyPlace(
            name: '해운대 해수욕장',
            address: '부산 해운대구 우동',
            distance: '도보 15분',
            category: 'tourist_spot',
            rating: 4.5,
            isOpen: true,
            description: '부산 대표 해수욕장',
            reason: '산책하기 좋은 해변',
            tip: '이른 아침이나 저녁 산책 추천',
          ),
          NearbyPlace(
            name: '광안리 해변',
            address: '부산 수영구 광안동',
            distance: '도보 20분',
            category: 'tourist_spot',
            rating: 4.0, // 고정값
            isOpen: true,
            description: '야경이 아름다운 해변',
            reason: '도보 관광에 적합',
            tip: '광안대교 야경 감상',
          ),
          NearbyPlace(
            name: '용두산공원',
            address: '부산 중구 광복동',
            distance: '도보 10분',
            category: 'tourist_spot',
            rating: 4.0, // 고정값
            isOpen: true,
            description: '부산타워가 있는 도심 공원',
            reason: '도심 속 산책 코스',
            tip: '부산타워에서 시내 전망 감상',
          ),
        ];

      case '대중교통':
        return [
          NearbyPlace(
            name: '부산시립미술관',
            address: '부산 해운대구 우동',
            distance: '지하철 5분',
            category: 'culture',
            rating: 4.0, // 고정값
            isOpen: true,
            description: '현대미술 전시관',
            reason: '지하철 접근 용이',
            tip: '2호선 해운대역 하차',
          ),
          NearbyPlace(
            name: '서면 롯데백화점',
            address: '부산 부산진구 서면',
            distance: '지하철 직결',
            category: 'shopping',
            rating: 4.0,
            isOpen: true,
            description: '부산 최대 쇼핑몰',
            reason: '지하철역 직결',
            tip: '1, 2호선 환승역',
          ),
          NearbyPlace(
            name: '부산박물관',
            address: '부산 남구 대연동',
            distance: '지하철 10분',
            category: 'culture',
            rating: 4.3,
            isOpen: true,
            description: '부산 역사 문화 박물관',
            reason: '대중교통 접근성 좋음',
            tip: '2호선 대연역 도보 5분',
          ),
        ];

      case '드라이브':
        return [
          NearbyPlace(
            name: '태종대',
            address: '부산 영도구 전망로',
            distance: '차량 30분',
            category: 'tourist_spot',
            rating: 0.0, // 별점 제거
            isOpen: true,
            description: '부산 최고의 전망 명소',
            reason: '드라이브 코스 최적',
            tip: '해안 절벽 드라이브 코스',
          ),
          NearbyPlace(
            name: '금정산',
            address: '부산 금정구 금정산동',
            distance: '차량 25분',
            category: 'tourist_spot',
            rating: 0.0, // 별점 제거
            isOpen: true,
            description: '부산의 명산',
            reason: '산악 드라이브 가능',
            tip: '범어사까지 드라이브',
          ),
          NearbyPlace(
            name: '갈맷길 해안도로',
            address: '부산 기장군 일광면',
            distance: '차량 40분',
            category: 'tourist_spot',
            rating: 0.0, // 별점 제거
            isOpen: true,
            description: '동해안 드라이브 코스',
            reason: '해안 경치 드라이브',
            tip: '일광해수욕장까지 연결',
          ),
        ];

      case '자전거':
        return [
          NearbyPlace(
            name: '낙동강 자전거길',
            address: '부산 강서구 대저동',
            distance: '자전거 40분',
            category: 'leisure',
            rating: 4.3,
            isOpen: true,
            description: '국가하천 자전거 전용도로',
            reason: '안전한 자전거 전용 구간',
            tip: '강변 경치와 함께 라이딩',
          ),
          NearbyPlace(
            name: '수영강 자전거길',
            address: '부산 수영구 망미동',
            distance: '자전거 20분',
            category: 'leisure',
            rating: 4.1,
            isOpen: true,
            description: '도심 속 강변 자전거길',
            reason: '도심에서 접근하기 쉬운 자전거길',
            tip: '수영교~광안대교 구간 추천',
          ),
          NearbyPlace(
            name: '화명생태공원',
            address: '부산 북구 화명동',
            distance: '자전거 25분',
            category: 'tourist_spot',
            rating: 4.2,
            isOpen: true,
            description: '자전거도로가 잘 조성된 생태공원',
            reason: '자연 속에서 안전한 라이딩',
            tip: '생태 탐방과 라이딩을 함께',
          ),
        ];

      default:
        return [];
    }
  }
}

/// 교통수단별 설정 클래스
class _TransportationConfig {
  final List<String> categories;      // API 조회용 카테고리
  final List<String> keywords;        // 검색 키워드
  final List<String> includeKeywords; // 포함되어야 할 키워드
  final List<String> excludeKeywords; // 제외할 키워드
  final List<String> preferredTypes;  // 선호 카테고리 타입

  const _TransportationConfig({
    required this.categories,
    required this.keywords,
    required this.includeKeywords,
    required this.excludeKeywords,
    required this.preferredTypes,
  });
}
