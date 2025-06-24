import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 관광공사 API 직접 연결 서비스 - 빠른 데이터 조회
class TourismApiService {
  // Base URLs
  static const String _korServiceBaseUrl = 'https://apis.data.go.kr/B551011/KorService2';
  static const String _photoGalleryBaseUrl = 'https://apis.data.go.kr/B551011/PhotoGalleryService1';

  // Timeout 설정
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// 관광공사 API 서비스키
  static String get _serviceKey {
    final key = dotenv.env['TOUR_API_SERVICE_KEY'];
    if (key == null || key.isEmpty) {
      throw TourismApiException('TOUR_API_SERVICE_KEY가 .env 파일에 설정되지 않았습니다.');
    }
    return key;
  }

  // 캐싱 시스템
  static final Map<String, dynamic> _apiCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 10); // 10분 캐시

  /// HTTP 요청 공통 처리
  static Future<Map<String, dynamic>?> _makeRequest(
      String url,
      Map<String, String> params,
      String apiName,
      ) async {
    try {
      // 캐시 키 생성
      final cacheKey = '$url?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      // 캐시 확인
      if (_apiCache.containsKey(cacheKey)) {
        final timestamp = _cacheTimestamps[cacheKey];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheExpiration) {
          print('🗄️ [$apiName] 캐시에서 응답 반환');
          return _apiCache[cacheKey];
        }
      }

      final uri = Uri.parse(url).replace(queryParameters: params);
      print('🌐 [$apiName] 요청: $url');

      final headers = {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Flutter App)',
      };

      final response = await http.get(uri, headers: headers)
          .timeout(_requestTimeout);

      print('📡 [$apiName] 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        // UTF-8 디코딩 보장
        final responseBody = utf8.decode(response.bodyBytes);

        // API 한도 초과 체크
        if (responseBody.contains('LIMITED_NUMBER_OF_SERVICE_REQUESTS_EXCEEDS_ERROR')) {
          print('❌ [$apiName] API 호출 한도 초과');
          throw TourismApiException('API 호출 한도가 초과되었습니다. 잠시 후 다시 시도해주세요.');
        }

        try {
          final data = jsonDecode(responseBody);
          final header = data['response']?['header'];

          if (header?['resultCode'] == '0000') {
            print('✅ [$apiName] 성공');

            // 캐시에 저장
            _apiCache[cacheKey] = data;
            _cacheTimestamps[cacheKey] = DateTime.now();

            return data;
          } else {
            print('❌ [$apiName] API 오류: ${header?['resultMsg']}');
            return null;
          }
        } catch (e) {
          print('❌ [$apiName] JSON 파싱 실패: $e');
          return null;
        }
      } else {
        print('❌ [$apiName] HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is TourismApiException) {
        rethrow;
      }
      print('❌ [$apiName] 요청 실패: $e');
      return null;
    }
  }

  /// 공통 파라미터 생성
  static Map<String, String> _getCommonParams({
    int numOfRows = 20,
    int pageNo = 1,
    String type = 'json',
  }) {
    return {
      'serviceKey': _serviceKey,
      'numOfRows': numOfRows.toString(),
      'pageNo': pageNo.toString(),
      'MobileOS': 'ETC',
      'MobileApp': 'Offpeak',
      '_type': type,
    };
  }

  // ==================== 내 주변 기능용 API 메서드들 ====================

  /// 위치기반 관광정보 조회 (내 주변 장소용)
  static Future<List<NearbyPlace>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    String? category,
    int page = 1,
    int radius = 5000, // 5km 기본값
  }) async {
    try {
      print('🔍 위치기반 장소 검색: 반경 ${radius}m, 페이지 $page');

      final params = _getCommonParams(numOfRows: 20, pageNo: page);

      // 필수 파라미터
      params['mapX'] = longitude.toString();
      params['mapY'] = latitude.toString();
      params['radius'] = radius.toString();
      params['arrange'] = 'E'; // 거리순 정렬

      // 카테고리가 있으면 추가
      final contentTypeId = _mapCategoryToContentTypeId(category);
      if (contentTypeId != null) {
        params['contentTypeId'] = contentTypeId;
      }

      final response = await _makeRequest(
        '$_korServiceBaseUrl/locationBasedList2',
        params,
        'NearbyPlaces',
      );

      if (response == null) {
        throw TourismApiException('주변 장소 정보를 가져올 수 없습니다.');
      }

      final items = _extractItems(response);
      if (items == null || items.isEmpty) {
        print('📭 주변에 장소가 없습니다');
        return [];
      }

      // NearbyPlace 객체로 변환
      final nearbyPlaces = await _convertToNearbyPlaces(
        items,
        latitude,
        longitude,
      );

      print('✅ ${nearbyPlaces.length}개 주변 장소 조회 완료');
      return nearbyPlaces;

    } catch (e) {
      print('❌ 주변 장소 조회 실패: $e');
      if (e is TourismApiException) rethrow;
      throw TourismApiException('주변 장소 검색 중 오류가 발생했습니다.');
    }
  }

  /// 지역기반 관광정보 조회 (카테고리별 조회용)
  static Future<List<NearbyPlace>> fetchPlacesByCategory({
    required String category,
    String? areaCode,
    int page = 1,
  }) async {
    try {
      print('🔍 카테고리별 장소 검색: $category, 지역: $areaCode');

      final params = _getCommonParams(numOfRows: 20, pageNo: page);
      params['arrange'] = 'D'; // 거리순 또는 제목순

      final contentTypeId = _mapCategoryToContentTypeId(category);
      if (contentTypeId != null) {
        params['contentTypeId'] = contentTypeId;
      }

      if (areaCode != null) {
        params['areaCode'] = areaCode;
      }

      final response = await _makeRequest(
        '$_korServiceBaseUrl/areaBasedList2',
        params,
        'CategoryPlaces',
      );

      if (response == null) {
        throw TourismApiException('$category 정보를 가져올 수 없습니다.');
      }

      final items = _extractItems(response);
      if (items == null || items.isEmpty) {
        return [];
      }

      // 기본 위치 (부산 중심)
      const defaultLat = 35.1796;
      const defaultLng = 129.0756;

      final places = await _convertToNearbyPlaces(
        items,
        defaultLat,
        defaultLng,
      );

      print('✅ $category ${places.length}개 장소 조회 완료');
      return places;

    } catch (e) {
      print('❌ 카테고리 장소 조회 실패: $e');
      if (e is TourismApiException) rethrow;
      throw TourismApiException('$category 검색 중 오류가 발생했습니다.');
    }
  }

  /// 장소 상세 정보 조회 (소개정보 포함)
  static Future<PlaceDetail?> fetchPlaceDetail(String contentId) async {
    try {
      print('📋 장소 상세 정보 조회: $contentId');

      final params = _getCommonParams();
      params['contentId'] = contentId;

      // 1단계: 기본 정보 조회 (detailCommon2)
      final commonResponse = await _makeRequest(
        '$_korServiceBaseUrl/detailCommon2',
        params,
        'PlaceDetail-Common',
      );

      if (commonResponse == null) return null;

      final commonItems = _extractItems(commonResponse);
      if (commonItems == null || commonItems.isEmpty) return null;

      final commonDetail = commonItems.first;
      final contentTypeId = commonDetail['contenttypeid']?.toString();

      // 2단계: 소개 정보 조회 (detailIntro2) - 더 자세한 정보
      String additionalInfo = '';
      if (contentTypeId != null) {
        final introParams = _getCommonParams();
        introParams['contentId'] = contentId;
        introParams['contentTypeId'] = contentTypeId;

        final introResponse = await _makeRequest(
          '$_korServiceBaseUrl/detailIntro2',
          introParams,
          'PlaceDetail-Intro',
        );

        if (introResponse != null) {
          final introItems = _extractItems(introResponse);
          if (introItems != null && introItems.isNotEmpty) {
            additionalInfo = _extractAdditionalInfo(introItems.first, contentTypeId);
          }
        }
      }

      return _convertToPlaceDetail(commonDetail, additionalInfo);

    } catch (e) {
      print('❌ 장소 상세 정보 조회 실패: $e');
      return null;
    }
  }

  /// contentTypeId별 추가 정보 추출
  static String _extractAdditionalInfo(Map<String, dynamic> introDetail, String contentTypeId) {
    final infoParts = <String>[];

    switch (contentTypeId) {
      case '12': // 관광지
        final usetime = introDetail['usetime']?.toString();
        final parking = introDetail['parking']?.toString();
        final restdate = introDetail['restdate']?.toString();
        final chkpet = introDetail['chkpet']?.toString();
        final chkcreditcard = introDetail['chkcreditcard']?.toString();

        if (usetime != null && usetime.isNotEmpty) {
          infoParts.add('🕐 이용시간: $usetime');
        }
        if (restdate != null && restdate.isNotEmpty) {
          infoParts.add('📅 휴무일: $restdate');
        }
        if (parking != null && parking.isNotEmpty) {
          infoParts.add('🚗 주차: $parking');
        }
        if (chkpet == '1') {
          infoParts.add('🐕 반려동물 동반 가능');
        }
        if (chkcreditcard == '1') {
          infoParts.add('💳 신용카드 사용 가능');
        }
        break;

      case '39': // 음식점
        final opentimefood = introDetail['opentimefood']?.toString();
        final restdatefood = introDetail['restdatefood']?.toString();
        final parkingfood = introDetail['parkingfood']?.toString();
        final treatmenu = introDetail['treatmenu']?.toString();
        final reservationfood = introDetail['reservationfood']?.toString();

        if (opentimefood != null && opentimefood.isNotEmpty) {
          infoParts.add('🕐 영업시간: $opentimefood');
        }
        if (restdatefood != null && restdatefood.isNotEmpty) {
          infoParts.add('📅 휴무일: $restdatefood');
        }
        if (treatmenu != null && treatmenu.isNotEmpty) {
          infoParts.add('🍽️ 대표메뉴: $treatmenu');
        }
        if (reservationfood != null && reservationfood.isNotEmpty) {
          infoParts.add('📞 예약안내: $reservationfood');
        }
        if (parkingfood != null && parkingfood.isNotEmpty) {
          infoParts.add('🚗 주차: $parkingfood');
        }
        break;

      case '32': // 숙박
        final checkintime = introDetail['checkintime']?.toString();
        final checkouttime = introDetail['checkouttime']?.toString();
        final parkinglodging = introDetail['parkinglodging']?.toString();
        final reservationlodging = introDetail['reservationlodging']?.toString();
        final roomtype = introDetail['roomtype']?.toString();
        final subfacility = introDetail['subfacility']?.toString();

        if (checkintime != null && checkintime.isNotEmpty) {
          infoParts.add('🕐 입실시간: $checkintime');
        }
        if (checkouttime != null && checkouttime.isNotEmpty) {
          infoParts.add('🕐 퇴실시간: $checkouttime');
        }
        if (roomtype != null && roomtype.isNotEmpty) {
          infoParts.add('🏠 객실유형: $roomtype');
        }
        if (reservationlodging != null && reservationlodging.isNotEmpty) {
          infoParts.add('📞 예약안내: $reservationlodging');
        }
        if (parkinglodging != null && parkinglodging.isNotEmpty) {
          infoParts.add('🚗 주차: $parkinglodging');
        }
        if (subfacility != null && subfacility.isNotEmpty) {
          infoParts.add('🏊 부대시설: $subfacility');
        }
        break;

      case '14': // 문화시설
        final usetime = introDetail['usetime']?.toString();
        final restdate = introDetail['restdate']?.toString();
        final parkingculture = introDetail['parkingculture']?.toString();
        final usefee = introDetail['usefee']?.toString();

        if (usetime != null && usetime.isNotEmpty) {
          infoParts.add('🕐 이용시간: $usetime');
        }
        if (restdate != null && restdate.isNotEmpty) {
          infoParts.add('📅 휴무일: $restdate');
        }
        if (usefee != null && usefee.isNotEmpty) {
          infoParts.add('💰 이용요금: $usefee');
        }
        if (parkingculture != null && parkingculture.isNotEmpty) {
          infoParts.add('🚗 주차: $parkingculture');
        }
        break;

      case '28': // 레포츠
        final openperiod = introDetail['openperiod']?.toString();
        final restdateleports = introDetail['restdateleports']?.toString();
        final parkingleports = introDetail['parkingleports']?.toString();
        final usefeeleports = introDetail['usefeeleports']?.toString();

        if (openperiod != null && openperiod.isNotEmpty) {
          infoParts.add('🕐 이용기간: $openperiod');
        }
        if (restdateleports != null && restdateleports.isNotEmpty) {
          infoParts.add('📅 휴무일: $restdateleports');
        }
        if (usefeeleports != null && usefeeleports.isNotEmpty) {
          infoParts.add('💰 이용요금: $usefeeleports');
        }
        if (parkingleports != null && parkingleports.isNotEmpty) {
          infoParts.add('🚗 주차: $parkingleports');
        }
        break;

      case '38': // 쇼핑
        final opentime = introDetail['opentime']?.toString();
        final restdateshopping = introDetail['restdateshopping']?.toString();
        final parkingshopping = introDetail['parkingshopping']?.toString();
        final saleitem = introDetail['saleitem']?.toString();

        if (opentime != null && opentime.isNotEmpty) {
          infoParts.add('🕐 영업시간: $opentime');
        }
        if (restdateshopping != null && restdateshopping.isNotEmpty) {
          infoParts.add('📅 휴무일: $restdateshopping');
        }
        if (saleitem != null && saleitem.isNotEmpty) {
          infoParts.add('🛍️ 판매품목: $saleitem');
        }
        if (parkingshopping != null && parkingshopping.isNotEmpty) {
          infoParts.add('🚗 주차: $parkingshopping');
        }
        break;
    }

    return infoParts.join('\n');
  }

  /// 장소 이미지 정보 조회
  static Future<List<String>> fetchPlaceImages(String contentId) async {
    try {
      print('🖼️ 장소 이미지 조회: $contentId');

      // 1단계: 기본 이미지 (detailCommon2)
      final images = <String>[];

      final commonParams = _getCommonParams();
      commonParams['contentId'] = contentId;

      final commonResponse = await _makeRequest(
        '$_korServiceBaseUrl/detailCommon2',
        commonParams,
        'PlaceImages-Common',
      );

      if (commonResponse != null) {
        final commonItems = _extractItems(commonResponse);
        if (commonItems != null && commonItems.isNotEmpty) {
          final item = commonItems.first;

          final firstImage = item['firstimage']?.toString();
          final firstImage2 = item['firstimage2']?.toString();

          if (_isValidImageUrl(firstImage)) {
            images.add(firstImage!);
          }
          if (_isValidImageUrl(firstImage2) && firstImage2 != firstImage) {
            images.add(firstImage2!);
          }
        }
      }

      // 2단계: 추가 이미지 (detailImage2)
      final imageParams = _getCommonParams(numOfRows: 10);
      imageParams['contentId'] = contentId;
      imageParams['imageYN'] = 'Y';
      imageParams['subImageYN'] = 'Y';

      final imageResponse = await _makeRequest(
        '$_korServiceBaseUrl/detailImage2',
        imageParams,
        'PlaceImages-Detail',
      );

      if (imageResponse != null) {
        final imageItems = _extractItems(imageResponse);
        if (imageItems != null && imageItems.isNotEmpty) {
          for (final item in imageItems) {
            final originUrl = item['originimgurl']?.toString();
            final smallUrl = item['smallimageurl']?.toString();

            String? selectedUrl;
            if (_isValidImageUrl(originUrl)) {
              selectedUrl = originUrl;
            } else if (_isValidImageUrl(smallUrl)) {
              selectedUrl = smallUrl;
            }

            if (selectedUrl != null && !images.contains(selectedUrl) && images.length < 5) {
              images.add(selectedUrl);
            }
          }
        }
      }

      print('✅ ${images.length}개 이미지 조회 완료');
      return images;

    } catch (e) {
      print('❌ 이미지 조회 실패: $e');
      return [];
    }
  }

  /// 키워드 검색
  static Future<List<NearbyPlace>> searchPlaces({
    required String keyword,
    String? areaCode,
    int page = 1,
  }) async {
    try {
      print('🔍 키워드 검색: $keyword');

      final params = _getCommonParams(numOfRows: 20, pageNo: page);
      params['keyword'] = keyword;
      params['arrange'] = 'A'; // 제목순

      if (areaCode != null) {
        params['areaCode'] = areaCode;
      }

      final response = await _makeRequest(
        '$_korServiceBaseUrl/searchKeyword2',
        params,
        'SearchPlaces',
      );

      if (response == null) {
        throw TourismApiException('검색 결과를 가져올 수 없습니다.');
      }

      final items = _extractItems(response);
      if (items == null || items.isEmpty) {
        return [];
      }

      const defaultLat = 35.1796;
      const defaultLng = 129.0756;

      final places = await _convertToNearbyPlaces(
        items,
        defaultLat,
        defaultLng,
      );

      print('✅ "$keyword" 검색 결과 ${places.length}개');
      return places;

    } catch (e) {
      print('❌ 키워드 검색 실패: $e');
      if (e is TourismApiException) rethrow;
      throw TourismApiException('검색 중 오류가 발생했습니다.');
    }
  }

  // ==================== 유틸리티 메서드들 ====================

  /// API 응답에서 items 추출
  static List<dynamic>? _extractItems(Map<String, dynamic>? response) {
    if (response == null) return null;

    final body = response['response']?['body'];
    if (body == null) return null;

    final items = body['items']?['item'];
    if (items == null) return [];

    if (items is Map) return [items];
    if (items is List) return items;
    return [];
  }

  /// 총 개수 추출
  static int? _extractTotalCount(Map<String, dynamic>? response) {
    return response?['response']?['body']?['totalCount'];
  }

  /// 카테고리를 contentTypeId로 변환
  static String? _mapCategoryToContentTypeId(String? category) {
    if (category == null) return null;

    switch (category) {
      case '관광지':
        return '12';
      case '문화시설':
        return '14';
      case '축제공연행사':
        return '15';
      case '여행코스':
        return '25';
      case '레포츠':
        return '28';
      case '숙박':
        return '32';
      case '쇼핑':
        return '38';
      case '음식점':
        return '39';
      case '전체':
      default:
        return null;
    }
  }

  /// contentTypeId를 카테고리로 변환
  static String _mapContentTypeToCategory(String? contentTypeId) {
    switch (contentTypeId) {
      case '12':
        return 'tourist_spot';
      case '14':
        return 'culture';
      case '15':
        return 'festival';
      case '25':
        return 'course';
      case '28':
        return 'leisure';
      case '32':
        return 'accommodation';
      case '38':
        return 'shopping';
      case '39':
        return 'restaurant';
      default:
        return 'general';
    }
  }

  /// 이미지 URL 유효성 검증
  static bool _isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;

    final lower = imageUrl.toLowerCase();
    return lower.startsWith('http') &&
        (lower.contains('.jpg') || lower.contains('.jpeg') ||
            lower.contains('.png') || lower.contains('.gif') ||
            lower.contains('.webp'));
  }

  /// 두 좌표 간 거리 계산 (km)
  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  /// API 데이터를 NearbyPlace로 변환
  static Future<List<NearbyPlace>> _convertToNearbyPlaces(
      List<dynamic> items,
      double userLat,
      double userLng,
      ) async {
    final places = <NearbyPlace>[];

    for (final item in items) {
      try {
        final title = item['title']?.toString().trim();
        final contentId = item['contentid']?.toString() ?? '';

        if (title == null || title.isEmpty) continue;

        final addr1 = item['addr1']?.toString() ?? '';
        final addr2 = item['addr2']?.toString() ?? '';
        final fullAddress = addr2.isNotEmpty ? '$addr1 $addr2' : addr1;

        // 거리 계산
        String distance = '';
        try {
          final mapX = double.tryParse(item['mapx']?.toString() ?? '');
          final mapY = double.tryParse(item['mapy']?.toString() ?? '');

          if (mapX != null && mapY != null && mapX != 0 && mapY != 0) {
            final distanceKm = _calculateDistance(userLat, userLng, mapY, mapX);
            if (distanceKm < 1.0) {
              distance = '도보 ${(distanceKm * 20).round()}분';
            } else {
              distance = '${distanceKm.toStringAsFixed(1)}km';
            }
          }
        } catch (e) {
          distance = '거리 정보 없음';
        }

        // 상세 설명 가져오기 (선택사항)
        String description = '';
        if (contentId.isNotEmpty) {
          try {
            final detailResponse = await fetchPlaceDetail(contentId);
            if (detailResponse != null && detailResponse.description.isNotEmpty) {
              description = detailResponse.description;
            }
          } catch (e) {
            // 상세 정보 조회 실패해도 계속 진행
          }
        }

        final place = NearbyPlace(
          contentId: contentId,
          name: title,
          address: fullAddress,
          distance: distance,
          category: _mapContentTypeToCategory(item['contenttypeid']?.toString()),
          rating: 4.0 + (title.hashCode % 10) / 10,
          isOpen: true,
          description: description,
          reason: '',
          tip: '',
        );

        places.add(place);

      } catch (e) {
        print('⚠️ 장소 변환 실패: ${item['title']} - $e');
      }
    }

    return places;
  }

  /// API 데이터를 PlaceDetail로 변환 (추가 정보 포함)
  static PlaceDetail _convertToPlaceDetail(Map<String, dynamic> detail, String additionalInfo) {
    final overview = detail['overview']?.toString() ?? '';

    return PlaceDetail(
      name: detail['title']?.toString() ?? '',
      location: detail['addr1']?.toString() ?? '',
      description: _cleanDescription(overview),
      phone: detail['tel']?.toString() ?? '',
      hours: '운영시간 정보 없음',
      facilities: additionalInfo.isNotEmpty ? additionalInfo : '시설 정보 없음',
      fee: '요금 정보 없음',
      parking: '주차 정보 없음',
      transport: '교통 정보 없음',
      special: overview.isNotEmpty ? _cleanDescription(overview) : '',
      recommendedTime: '언제든지',
    );
  }

  /// HTML 태그 제거 및 설명 정리 - 전체 내용 유지
  static String _cleanDescription(String overview) {
    if (overview.isEmpty) return '';

    try {
      String cleaned = overview
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      return cleaned.isNotEmpty ? cleaned : '';
    } catch (e) {
      return '';
    }
  }

  /// 캐시 클리어
  static void clearCache() {
    _apiCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ 관광공사 API 캐시가 클리어되었습니다');
  }
}

// ==================== 모델 클래스들 ====================

/// 주변 장소 모델
class NearbyPlace {
  final String contentId;
  final String name;
  final String address;
  final String distance;
  final String category;
  final double rating;
  final bool isOpen;
  final String description;
  final String reason;
  final String tip;

  const NearbyPlace({
    this.contentId = '',
    required this.name,
    required this.address,
    required this.distance,
    required this.category,
    required this.rating,
    required this.isOpen,
    required this.description,
    required this.reason,
    required this.tip,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'name': name,
      'address': address,
      'distance': distance,
      'category': category,
      'rating': rating,
      'isOpen': isOpen,
      'description': description,
      'reason': reason,
      'tip': tip,
    };
  }

  factory NearbyPlace.fromJson(Map<String, dynamic> json) {
    return NearbyPlace(
      contentId: json['contentId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      distance: json['distance'] ?? '',
      category: json['category'] ?? 'general',
      rating: (json['rating'] ?? 4.0).toDouble(),
      isOpen: json['isOpen'] ?? true,
      description: json['description'] ?? '',
      reason: json['reason'] ?? '',
      tip: json['tip'] ?? '',
    );
  }
}

/// 장소 상세 정보 모델
class PlaceDetail {
  final String name;
  final String location;
  final String description;
  final String phone;
  final String hours;
  final String facilities;
  final String fee;
  final String parking;
  final String transport;
  final String special;
  final String recommendedTime;

  const PlaceDetail({
    required this.name,
    required this.location,
    required this.description,
    required this.phone,
    required this.hours,
    required this.facilities,
    required this.fee,
    required this.parking,
    required this.transport,
    required this.special,
    required this.recommendedTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'phone': phone,
      'hours': hours,
      'facilities': facilities,
      'fee': fee,
      'parking': parking,
      'transport': transport,
      'special': special,
      'recommendedTime': recommendedTime,
    };
  }
}

/// 관광공사 API 예외 클래스
class TourismApiException implements Exception {
  final String message;
  TourismApiException(this.message);

  @override
  String toString() => message;
}
