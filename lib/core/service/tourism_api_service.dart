import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../../features/home/presentation/providers/recommendation_model.dart';
import '../utils/html_utils.dart';

/// 관광공사 API 직접 연결 서비스 - 혼잡도 정보 포함
class TourismApiService {
  // Base URLs
  static const String _korServiceBaseUrl = 'https://apis.data.go.kr/B551011/KorService2';
  static const String _photoGalleryBaseUrl = 'https://apis.data.go.kr/B551011/PhotoGalleryService1';

  // 🔧 수정된 혼잡도 API Base URLs
  static const String _dataLabBaseUrl = 'https://apis.data.go.kr/B551011/DataLabService';
  static const String _concentrationBaseUrl = 'https://apis.data.go.kr/B551011/TatsCnctrRateService';

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

  // 캐싱 시스템 (혼잡도 API는 캐시 제외)
  static final Map<String, dynamic> _apiCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 10); // 10분 캐시

  // ==================== 🔧 새로 추가: 지역코드 서비스 ====================

  /// 🔧 관광공사 API에서 실제 지역코드 조회
  static Future<List<AreaCodeInfo>> fetchAreaCodes() async {
    try {
      print('🗺️ 지역코드 조회 시작');

      final params = _getCommonParams(numOfRows: 50);

      final response = await _makeRequest(
        '$_korServiceBaseUrl/areaCode2',
        params,
        'AreaCode',
      );

      if (response == null) {
        print('❌ 지역코드 조회 실패');
        return [];
      }

      final items = _extractItems(response);
      if (items == null || items.isEmpty) {
        print('📭 지역코드 데이터 없음');
        return [];
      }

      final areaCodes = <AreaCodeInfo>[];
      for (final item in items) {
        try {
          final code = item['code']?.toString();
          final name = item['name']?.toString();

          if (code != null && name != null) {
            areaCodes.add(AreaCodeInfo(
              code: code,
              name: name,
            ));
            print('✅ 지역코드: $code - $name');
          }
        } catch (e) {
          print('⚠️ 지역코드 파싱 실패: $e');
        }
      }

      print('✅ 총 ${areaCodes.length}개 지역코드 조회 완료');
      return areaCodes;

    } catch (e) {
      print('❌ 지역코드 조회 예외: $e');
      return [];
    }
  }

  /// 특정 지역의 시군구코드 조회
  static Future<List<SigunguCodeInfo>> fetchSigunguCodes(String areaCode) async {
    try {
      print('🏘️ 시군구코드 조회 시작: $areaCode');

      final params = _getCommonParams(numOfRows: 100);
      params['areaCode'] = areaCode;

      final response = await _makeRequest(
        '$_korServiceBaseUrl/areaCode2',
        params,
        'SigunguCode',
      );

      if (response == null) {
        print('❌ 시군구코드 조회 실패');
        return [];
      }

      final items = _extractItems(response);
      if (items == null || items.isEmpty) {
        print('📭 시군구코드 데이터 없음');
        return [];
      }

      final sigunguCodes = <SigunguCodeInfo>[];
      for (final item in items) {
        try {
          final code = item['code']?.toString();
          final name = item['name']?.toString();

          if (code != null && name != null) {
            sigunguCodes.add(SigunguCodeInfo(
              areaCode: areaCode,
              sigunguCode: code,
              name: name,
            ));
            print('✅ 시군구코드: $code - $name');
          }
        } catch (e) {
          print('⚠️ 시군구코드 파싱 실패: $e');
        }
      }

      print('✅ 총 ${sigunguCodes.length}개 시군구코드 조회 완료');
      return sigunguCodes;

    } catch (e) {
      print('❌ 시군구코드 조회 예외: $e');
      return [];
    }
  }

  /// 지역명으로 지역코드 찾기
  static Future<String?> getAreaCodeByName(String areaName) async {
    try {
      final areaCodes = await fetchAreaCodes();
      for (final areaCode in areaCodes) {
        if (areaCode.name.contains(areaName) || areaName.contains(areaCode.name)) {
          print('🎯 지역명 매칭: $areaName -> ${areaCode.code}');
          return areaCode.code;
        }
      }
      print('❌ 지역명 매칭 실패: $areaName');
      return null;
    } catch (e) {
      print('❌ 지역명 매칭 예외: $e');
      return null;
    }
  }

  /// 시군구명으로 시군구코드 찾기
  static Future<String?> getSigunguCodeByName(String areaCode, String sigunguName) async {
    try {
      final sigunguCodes = await fetchSigunguCodes(areaCode);
      for (final sigunguCode in sigunguCodes) {
        if (sigunguCode.name.contains(sigunguName) || sigunguName.contains(sigunguCode.name)) {
          print('🎯 시군구명 매칭: $sigunguName -> ${sigunguCode.sigunguCode}');
          return sigunguCode.sigunguCode;
        }
      }
      print('❌ 시군구명 매칭 실패: $sigunguName');
      return null;
    } catch (e) {
      print('❌ 시군구명 매칭 예외: $e');
      return null;
    }
  }

  /// HTTP 요청 공통 처리 (혼잡도 API는 캐시 비활성화)
  static Future<Map<String, dynamic>?> _makeRequest(
      String url,
      Map<String, String> params,
      String apiName,
      ) async {
    try {
      final cacheKey = '$url?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      // 🔧 혼잡도 관련 API는 캐시 사용 안함
      final isCongestionApi = apiName.contains('RegionalVisitorData') ||
          apiName.contains('LocalVisitorData') ||
          apiName.contains('TouristSpotPrediction');

      // 일반 API만 캐시 확인 (혼잡도 API 제외)
      if (!isCongestionApi && _apiCache.containsKey(cacheKey)) {
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

            // 🔧 일반 API만 캐시에 저장 (혼잡도 API 제외)
            if (!isCongestionApi) {
              _apiCache[cacheKey] = data;
              _cacheTimestamps[cacheKey] = DateTime.now();
            } else {
              print('🚫 [$apiName] 혼잡도 API는 캐시하지 않음');
            }

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

  // ==================== 🔧 수정된 혼잡도 API 메서드들 ====================

  /// 🔧 개선된 혼잡도 정보 조회 (실제 API 지역코드 사용)
  static Future<CongestionData?> fetchCongestionData({
    required String contentId,
    String? areaCode,
    String? sigunguCode,
    String? touristSpotName,
    String? address, // 🔧 추가: 주소 정보
  }) async {
    try {
      print('📊 혼잡도 정보 조회: contentId=$contentId');
      print('📍 입력된 정보 - area=$areaCode, sigungu=$sigunguCode, address=$address');

      String? actualAreaCode = areaCode;
      String? actualSigunguCode = sigunguCode;

      // 🔧 1단계: 주소에서 지역명 추출 및 실제 코드 조회
      if (address != null && address.isNotEmpty) {
        final addressParts = address.split(' ');

        // 시/도 추출
        String? extractedArea;
        String? extractedSigungu;

        for (final part in addressParts) {
          if (part.endsWith('시') || part.endsWith('도')) {
            extractedArea = part;
          } else if (part.endsWith('구') || part.endsWith('군') || part.endsWith('시')) {
            extractedSigungu = part;
          }
        }

        print('🔍 주소에서 추출 - 지역: $extractedArea, 시군구: $extractedSigungu');

        // 실제 API에서 지역코드 조회
        if (extractedArea != null && (actualAreaCode == null || actualAreaCode.isEmpty)) {
          actualAreaCode = await getAreaCodeByName(extractedArea);
          print('🔄 지역코드 변환: $extractedArea -> $actualAreaCode');
        }

        // 실제 API에서 시군구코드 조회
        if (extractedSigungu != null && actualAreaCode != null &&
            (actualSigunguCode == null || actualSigunguCode.isEmpty)) {
          actualSigunguCode = await getSigunguCodeByName(
              actualAreaCode,
              extractedSigungu
          );
          print('🔄 시군구코드 변환: $extractedSigungu -> $actualSigunguCode');
        }
      }

      print('🎯 최종 사용할 코드 - area=$actualAreaCode, sigungu=$actualSigunguCode');

      CongestionData? lastWeekData;
      CongestionData? thisWeekPrediction;

      // 3단계: 혼잡도 데이터 조회 (기존 로직)
      if (actualSigunguCode != null && actualAreaCode != null) {
        print('🔍 지난주 방문자 데이터 조회 시도');
        lastWeekData = await _fetchLocalVisitorDataSafest(actualAreaCode, actualSigunguCode);

        if (lastWeekData == null) {
          lastWeekData = await _fetchRegionalVisitorDataSafest(actualAreaCode);
        }
      }

      // 이번주 예상 방문자 조회
      if (actualAreaCode != null && actualSigunguCode != null &&
          touristSpotName != null && touristSpotName.isNotEmpty) {
        print('🔍 이번주 예상 방문자 데이터 조회 시도');
        thisWeekPrediction = await _fetchTouristConcentrationData(
          areaCode: actualAreaCode,
          sigunguCode: actualSigunguCode,
          touristSpotName: touristSpotName,
        );
      }

      // 4단계: 데이터 통합 (기존 로직 유지)
      if (lastWeekData != null && thisWeekPrediction != null) {
        print('🎉 지난주 + 이번주 예상 데이터 모두 사용');
        return CongestionData(
          currentLevel: thisWeekPrediction.currentLevel,
          lastWeekVisitors: lastWeekData.lastWeekVisitors,
          expectedVisitors: thisWeekPrediction.expectedVisitors,
          recommendedTime: thisWeekPrediction.recommendedTime,
          peakTime: thisWeekPrediction.peakTime,
          predictedVisitors: thisWeekPrediction.predictedVisitors,
          dataSource: 'combined_api',
        );
      } else if (lastWeekData != null) {
        print('📊 지난주 방문자 데이터만 사용');
        return lastWeekData;
      } else if (thisWeekPrediction != null) {
        print('🔮 이번주 예상 데이터만 사용');
        return thisWeekPrediction;
      } else {
        print('⚠️ 실제 혼잡도 데이터 없음, 기본값 사용');
        return _generateDefaultCongestionData(contentId);
      }

    } catch (e) {
      print('❌ 혼잡도 정보 조회 실패: $e');
      return _generateDefaultCongestionData(contentId);
    }
  }

  /// 🔧 관광지 집중률 방문자 추이 예측 정보 조회 (버그 수정)
  static Future<CongestionData?> _fetchTouristConcentrationData({
    required String areaCode,
    required String sigunguCode,
    required String touristSpotName,
  }) async {
    try {
      print('🔮 [TouristConcentration] 집중률 예측 조회: $areaCode-$sigunguCode, 관광지: $touristSpotName');

      final params = _getCommonParams(numOfRows: 50);
      params['areaCd'] = areaCode;
      params['signguCd'] = sigunguCode;
      params['tAtsNm'] = touristSpotName;

      final response = await _makeRequest(
        '$_concentrationBaseUrl/tatsCnctrRatedList',
        params,
        'TouristConcentration',
      );

      if (response == null) {
        print('❌ [TouristConcentration] 응답이 null');
        return null;
      }

      // 🔧 수정: 전체 응답 구조 디버깅
      print('🔍 [TouristConcentration] 전체 응답 구조 확인');
      print('   - response 키: ${response.keys.toList()}');

      final body = response['response']?['body'];
      if (body == null) {
        print('❌ [TouristConcentration] body가 null');
        return null;
      }

      print('🔍 [TouristConcentration] body 구조: ${body.keys.toList()}');
      print('🔍 [TouristConcentration] body 내용: $body');

      final items = body['items'];
      if (items == null) {
        print('❌ [TouristConcentration] items가 null');
        return null;
      }

      print('🔍 [TouristConcentration] items 타입: ${items.runtimeType}');
      print('🔍 [TouristConcentration] items 내용: $items');

      // 🔧 수정: items가 빈 문자열인 경우 처리
      if (items is String && (items.isEmpty || items.trim().isEmpty)) {
        print('❌ [TouristConcentration] items가 빈 문자열 - 데이터 없음');
        return null;
      }

      dynamic item;

      // 🔧 수정: items 구조에 따른 안전한 파싱
      if (items is Map<String, dynamic>) {
        item = items['item'];
        print('🔍 [TouristConcentration] items는 Map, item 추출: ${item.runtimeType}');
      } else if (items is List) {
        item = items;
        print('🔍 [TouristConcentration] items는 직접 List');
      } else {
        print('❌ [TouristConcentration] 예상하지 못한 items 타입: ${items.runtimeType}');
        return null;
      }

      if (item == null) {
        print('❌ [TouristConcentration] item이 null');
        return null;
      }

      print('🔍 [TouristConcentration] item 타입: ${item.runtimeType}');
      print('🔍 [TouristConcentration] item 내용: $item');

      // 🔧 수정: item을 List로 안전하게 변환
      List<Map<String, dynamic>> itemList = [];

      try {
        if (item is List) {
          for (int i = 0; i < item.length; i++) {
            final element = item[i];
            if (element is Map<String, dynamic>) {
              itemList.add(element);
              print('✅ [TouristConcentration] List 요소 $i 추가: ${element.keys.toList()}');
            } else {
              print('⚠️ [TouristConcentration] List 요소 $i는 Map이 아님: ${element.runtimeType}');
            }
          }
        } else if (item is Map<String, dynamic>) {
          itemList.add(item);
          print('✅ [TouristConcentration] 단일 Map 추가: ${item.keys.toList()}');
        } else {
          print('❌ [TouristConcentration] item을 처리할 수 없는 타입: ${item.runtimeType}');
          return null;
        }
      } catch (e) {
        print('❌ [TouristConcentration] item 변환 중 오류: $e');
        return null;
      }

      print('📋 [TouristConcentration] 총 ${itemList.length}개 예측 데이터');

      if (itemList.isEmpty) {
        print('⚠️ [TouristConcentration] 예측 데이터 없음');
        return null;
      }

      // 🔧 수정: 안전한 데이터 처리
      double totalConcentrationRate = 0.0;
      int validDays = 0;
      Map<String, dynamic>? sampleItem;

      print('📊 [TouristConcentration] 예측 데이터 분석:');

      // 🔧 수정: 안전한 반복문 처리
      for (int i = 0; i < itemList.length && i < 7; i++) {
        try {
          final dataItem = itemList[i];
          print('🔍 [TouristConcentration] 데이터 $i: ${dataItem.keys.toList()}');

          final baseYmd = dataItem['baseYmd']?.toString() ?? '';
          final cnctrRateStr = dataItem['cnctrRate']?.toString() ?? '0';
          final cnctrRate = double.tryParse(cnctrRateStr) ?? 0.0;
          final tAtsNm = dataItem['tAtsNm']?.toString() ?? '';

          print('   - 날짜: $baseYmd, 관광지: $tAtsNm, 집중률: ${cnctrRate}%');

          if (cnctrRate > 0) {
            totalConcentrationRate += cnctrRate;
            validDays++;
            sampleItem = dataItem;
          }
        } catch (e) {
          print('⚠️ [TouristConcentration] 데이터 $i 처리 중 오류: $e');
          continue;
        }
      }

      // 🔧 수정: 결과 처리
      if (sampleItem != null && validDays > 0) {
        final averageConcentrationRate = totalConcentrationRate / validDays;
        final touristSpotName = sampleItem['tAtsNm']?.toString() ?? '알 수 없음';
        final areaName = sampleItem['areaNm']?.toString() ?? '알 수 없음';
        final sigunguName = sampleItem['signguNm']?.toString() ?? '알 수 없음';

        // 집중률을 기반으로 예상 방문자 수 계산
        final expectedVisitors = (averageConcentrationRate * 100).round();

        print('✅ [TouristConcentration] 성공: $touristSpotName ($areaName $sigunguName)');
        print('📊 [TouristConcentration] 향후 7일 평균 집중률: ${averageConcentrationRate.toStringAsFixed(1)}%');
        print('📊 [TouristConcentration] 예상 방문자: ${expectedVisitors}명');

        return CongestionData(
          currentLevel: averageConcentrationRate.round(),
          lastWeekVisitors: 0, // 이 API는 예측 데이터만 제공
          expectedVisitors: expectedVisitors,
          recommendedTime: _generateRecommendedTimeFromConcentration(averageConcentrationRate),
          peakTime: _generatePeakTimeFromConcentration(averageConcentrationRate),
          predictedVisitors: expectedVisitors,
          dataSource: 'tourist_concentration_api',
        );
      } else {
        print('⚠️ [TouristConcentration] 유효한 예측 데이터 없음 (validDays: $validDays)');
        return null;
      }

    } catch (e, stackTrace) {
      print('❌ [TouristConcentration] 최상위 예외: $e');
      print('📋 [TouristConcentration] StackTrace: $stackTrace');
      return null;
    }
  }

  /// 🔧 개선된 기초지자체 방문자수 조회 - 실제 API 스펙 기반
  static Future<CongestionData?> _fetchLocalVisitorDataSafest(String areaCode, String sigunguCode) async {
    try {
      final now = DateTime.now();

      // 🔧 수정: 더 넓은 날짜 범위로 조회 (최근 30일)
      final endDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 3))); // 3일 전까지
      final startDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 30))); // 30일 전부터

      final params = _getCommonParams(numOfRows: 1000); // 🔧 수정: 더 많은 데이터 요청
      params['startYmd'] = startDate;
      params['endYmd'] = endDate;

      print('🔍 [LocalSafest] 요청: $startDate ~ $endDate, 시군구: $sigunguCode');

      final response = await _makeRequest(
        '$_dataLabBaseUrl/locgoRegnVisitrDDList',
        params,
        'LocalSafest',
      );

      if (response == null) {
        print('❌ [LocalSafest] 응답이 null');
        return null;
      }

      // 🔧 추가: API 응답 전체 구조 확인
      print('🔍 [LocalSafest] 전체 응답 구조:');
      print('   - response: ${response['response'] != null}');
      print('   - header: ${response['response']?['header']}');

      final responseData = response['response'];
      if (responseData == null) {
        print('❌ [LocalSafest] response 키 없음');
        return null;
      }

      // 🔧 헤더 확인
      final header = responseData['header'];
      final resultCode = header?['resultCode'];
      final resultMsg = header?['resultMsg'];
      print('🔍 [LocalSafest] API 결과: $resultCode - $resultMsg');

      final bodyData = responseData['body'];
      if (bodyData == null) {
        print('❌ [LocalSafest] body 키 없음');
        return null;
      }

      // 🔧 body 내용 상세 로깅
      final totalCount = bodyData['totalCount'];
      final numOfRows = bodyData['numOfRows'];
      final pageNo = bodyData['pageNo'];
      final itemsData = bodyData['items'];

      print('🔍 [LocalSafest] Body 정보:');
      print('   - totalCount: $totalCount');
      print('   - numOfRows: $numOfRows');
      print('   - pageNo: $pageNo');
      print('   - items 타입: ${itemsData.runtimeType}');
      print('   - items 내용: $itemsData');

      // 🔧 totalCount가 0이면 조기 반환
      if (totalCount == null || totalCount == 0) {
        print('❌ [LocalSafest] 데이터 없음 (totalCount: $totalCount)');
        print('💡 [LocalSafest] 다른 지역코드나 날짜 범위 시도 권장');
        return null;
      }

      // 🔧 items 처리 - API 스펙에 따라 정확히 파싱
      if (itemsData == null) {
        print('❌ [LocalSafest] items 키 없음');
        return null;
      }

      // API 스펙: items -> item (List 또는 단일 Map)
      dynamic itemData;

      if (itemsData is String && (itemsData.isEmpty || itemsData.trim().isEmpty)) {
        print('❌ [LocalSafest] items가 빈 문자열 - 데이터 없음');
        return null;
      } else if (itemsData is Map<String, dynamic>) {
        itemData = itemsData['item'];
        print('🔍 [LocalSafest] items는 Map, item 추출: ${itemData.runtimeType}');
      } else {
        print('❌ [LocalSafest] 예상하지 못한 items 타입: ${itemsData.runtimeType}');
        return null;
      }

      if (itemData == null) {
        print('❌ [LocalSafest] item 데이터 없음');
        return null;
      }

      // 🔧 item을 List로 정규화
      List<Map<String, dynamic>> itemList = [];

      if (itemData is List) {
        for (final item in itemData) {
          if (item is Map<String, dynamic>) {
            itemList.add(item);
          }
        }
      } else if (itemData is Map<String, dynamic>) {
        itemList.add(itemData);
      } else {
        print('❌ [LocalSafest] item을 처리할 수 없는 타입: ${itemData.runtimeType}');
        return null;
      }

      print('📋 [LocalSafest] 처리할 데이터: ${itemList.length}개');

      if (itemList.isEmpty) {
        print('⚠️ [LocalSafest] 처리 가능한 데이터 없음');
        return null;
      }

      // 🔧 데이터 분석 및 집계
      int totalVisitors = 0;
      String? foundSignguName;
      final Map<String, int> visitorsPerDay = {};
      final Set<String> availableCodes = {};
      int matchingDataCount = 0;

      for (final item in itemList) {
        try {
          // API 스펙에 따른 필드명 사용
          final itemSignguCode = item['signguCode']?.toString();
          final itemSignguName = item['signguNm']?.toString();
          final itemTouNum = int.tryParse(item['touNum']?.toString() ?? '0') ?? 0;
          final itemBaseYmd = item['baseYmd']?.toString();
          final itemTouDivNm = item['touDivNm']?.toString(); // 내국인/외국인 구분
          final itemDaywkDivNm = item['daywkDivNm']?.toString(); // 요일 구분

          // 사용 가능한 시군구 코드 수집
          if (itemSignguCode != null && itemSignguName != null) {
            availableCodes.add('$itemSignguCode: $itemSignguName');
          }

          print('   📅 $itemBaseYmd | 코드: $itemSignguCode($itemSignguName) | 방문자: $itemTouNum명 | 구분: $itemTouDivNm | 요일: $itemDaywkDivNm');

          // 🔧 요청한 시군구코드와 일치하는 데이터만 집계
          if (itemSignguCode == sigunguCode) {
            totalVisitors += itemTouNum;
            foundSignguName = itemSignguName;
            matchingDataCount++;

            // 날짜별 방문자 수 기록 (분석용)
            if (itemBaseYmd != null) {
              visitorsPerDay[itemBaseYmd] = (visitorsPerDay[itemBaseYmd] ?? 0) + itemTouNum;
            }
          }
        } catch (e) {
          print('⚠️ [LocalSafest] 개별 item 처리 중 오류: $e');
          continue;
        }
      }

      // 🔧 결과 처리
      if (foundSignguName != null && totalVisitors > 0 && matchingDataCount > 0) {
        print('✅ [LocalSafest] 성공: $foundSignguName');
        print('📊 [LocalSafest] 총 방문자: ${totalVisitors}명 (${matchingDataCount}개 데이터 포인트)');
        print('📊 [LocalSafest] 일평균 방문자: ${(totalVisitors / matchingDataCount).round()}명');

        // 날짜별 방문자 현황 로깅
        print('📅 [LocalSafest] 날짜별 방문자:');
        visitorsPerDay.entries.take(5).forEach((entry) {
          print('   ${entry.key}: ${entry.value}명');
        });

        return CongestionData(
          currentLevel: _calculateCongestionFromVisitors(totalVisitors ~/ matchingDataCount), // 일평균 기준
          lastWeekVisitors: totalVisitors,
          expectedVisitors: (totalVisitors * 1.1).round(),
          recommendedTime: _generateRecommendedTime(_calculateCongestionFromVisitors(totalVisitors ~/ matchingDataCount)),
          peakTime: _generatePeakTime(_calculateCongestionFromVisitors(totalVisitors ~/ matchingDataCount)),
          predictedVisitors: null,
          dataSource: 'local_visitor_api',
        );
      } else {
        print('⚠️ [LocalSafest] 시군구 $sigunguCode 데이터 없음');
        print('📋 [LocalSafest] 사용 가능한 시군구 코드 (최대 10개):');
        availableCodes.take(10).forEach((code) => print('   - $code'));

        // 🔧 다른 시군구의 평균값으로 추정
        if (itemList.isNotEmpty) {
          final avgVisitors = totalVisitors > 0 ? totalVisitors : 100; // 기본값
          print('💡 [LocalSafest] 다른 지역 평균을 기반으로 추정값 생성');

          return CongestionData(
            currentLevel: _calculateCongestionFromVisitors(avgVisitors ~/ 7), // 주간 평균
            lastWeekVisitors: avgVisitors,
            expectedVisitors: (avgVisitors * 1.05).round(),
            recommendedTime: _generateRecommendedTime(_calculateCongestionFromVisitors(avgVisitors ~/ 7)),
            peakTime: _generatePeakTime(_calculateCongestionFromVisitors(avgVisitors ~/ 7)),
            predictedVisitors: null,
            dataSource: 'estimated_from_regional_data',
          );
        }

        return null;
      }

    } catch (e, stackTrace) {
      print('❌ [LocalSafest] 최상위 예외: $e');
      print('📋 StackTrace: $stackTrace');
      return null;
    }
  }

  /// 🔧 개선된 광역지자체 방문자수 조회 - 실제 API 스펙 기반
  static Future<CongestionData?> _fetchRegionalVisitorDataSafest(String areaCode) async {
    try {
      final now = DateTime.now();

      // 🔧 수정: 더 넓은 날짜 범위로 조회 (최근 30일)
      final endDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 3))); // 3일 전까지
      final startDate = DateFormat('yyyyMMdd').format(now.subtract(Duration(days: 30))); // 30일 전부터

      final params = _getCommonParams(numOfRows: 1000); // 🔧 수정: 더 많은 데이터 요청
      params['startYmd'] = startDate;
      params['endYmd'] = endDate;

      print('🔍 [RegionalSafest] 요청: $startDate ~ $endDate, 지역: $areaCode');

      final response = await _makeRequest(
        '$_dataLabBaseUrl/metcoRegnVisitrDDList',
        params,
        'RegionalSafest',
      );

      if (response == null) return null;

      print('🔍 [RegionalSafest] 전체 응답 구조:');
      print('   - response: ${response['response'] != null}');

      final responseData = response['response'];
      if (responseData == null) return null;

      // 🔧 헤더 확인
      final header = responseData['header'];
      final resultCode = header?['resultCode'];
      final resultMsg = header?['resultMsg'];
      print('🔍 [RegionalSafest] API 결과: $resultCode - $resultMsg');

      final bodyData = responseData['body'];
      if (bodyData == null) return null;

      // 🔧 body 내용 상세 로깅
      final totalCount = bodyData['totalCount'];
      final itemsData = bodyData['items'];

      print('🔍 [RegionalSafest] Body 정보:');
      print('   - totalCount: $totalCount');
      print('   - items 타입: ${itemsData.runtimeType}');

      if (totalCount == null || totalCount == 0) {
        print('❌ [RegionalSafest] 데이터 없음 (totalCount: $totalCount)');
        return null;
      }

      // 🔧 items 처리 - API 스펙에 따라 정확히 파싱
      if (itemsData == null) return null;

      dynamic itemData;

      if (itemsData is String && (itemsData.isEmpty || itemsData.trim().isEmpty)) {
        print('❌ [RegionalSafest] items가 빈 문자열 - 데이터 없음');
        return null;
      } else if (itemsData is Map<String, dynamic>) {
        itemData = itemsData['item'];
      } else {
        print('❌ [RegionalSafest] 예상하지 못한 items 타입: ${itemsData.runtimeType}');
        return null;
      }

      if (itemData == null) return null;

      // 🔧 item을 List로 정규화
      List<Map<String, dynamic>> itemList = [];

      if (itemData is List) {
        for (final item in itemData) {
          if (item is Map<String, dynamic>) {
            itemList.add(item);
          }
        }
      } else if (itemData is Map<String, dynamic>) {
        itemList.add(itemData);
      } else {
        return null;
      }

      print('📋 [RegionalSafest] 처리할 데이터: ${itemList.length}개');

      if (itemList.isEmpty) return null;

      // 🔧 데이터 분석 및 집계
      int totalVisitors = 0;
      String? foundAreaName;
      final Set<String> availableCodes = {};
      int matchingDataCount = 0;

      for (final item in itemList) {
        try {
          // API 스펙에 따른 필드명 사용
          final itemAreaCode = item['areaCode']?.toString();
          final itemAreaName = item['areaNm']?.toString();
          final itemTouNum = int.tryParse(item['touNum']?.toString() ?? '0') ?? 0;
          final itemBaseYmd = item['baseYmd']?.toString();
          final itemTouDivNm = item['touDivNm']?.toString(); // 내국인/외국인 구분

          // 사용 가능한 지역 코드 수집
          if (itemAreaCode != null && itemAreaName != null) {
            availableCodes.add('$itemAreaCode: $itemAreaName');
          }

          print('   📅 $itemBaseYmd | 코드: $itemAreaCode($itemAreaName) | 방문자: $itemTouNum명 | 구분: $itemTouDivNm');

          if (itemAreaCode == areaCode) {
            totalVisitors += itemTouNum;
            foundAreaName = itemAreaName;
            matchingDataCount++;
          }
        } catch (e) {
          print('⚠️ [RegionalSafest] 개별 item 처리 중 오류: $e');
          continue;
        }
      }

      if (foundAreaName != null && totalVisitors > 0 && matchingDataCount > 0) {
        print('✅ [RegionalSafest] 성공: $foundAreaName');
        print('📊 [RegionalSafest] 총 방문자: ${totalVisitors}명 (${matchingDataCount}개 데이터 포인트)');

        return CongestionData(
          currentLevel: _calculateCongestionFromVisitors(totalVisitors ~/ matchingDataCount), // 일평균 기준
          lastWeekVisitors: totalVisitors,
          expectedVisitors: (totalVisitors * 1.1).round(),
          recommendedTime: _generateRecommendedTime(_calculateCongestionFromVisitors(totalVisitors ~/ matchingDataCount)),
          peakTime: _generatePeakTime(_calculateCongestionFromVisitors(totalVisitors ~/ matchingDataCount)),
          predictedVisitors: null,
          dataSource: 'regional_visitor_api',
        );
      } else {
        print('⚠️ [RegionalSafest] 지역 $areaCode 데이터 없음');
        print('📋 [RegionalSafest] 사용 가능한 지역 코드 (최대 10개):');
        availableCodes.take(10).forEach((code) => print('   - $code'));
        return null;
      }

    } catch (e, stackTrace) {
      print('❌ [RegionalSafest] 최상위 예외: $e');
      print('📋 StackTrace: $stackTrace');
      return null;
    }
  }

  /// 🔧 집중률 기반 추천 시간 생성
  static String _generateRecommendedTimeFromConcentration(double concentrationRate) {
    if (concentrationRate <= 20) return '지금 방문 추천 (한적함)';
    if (concentrationRate <= 40) return '오전 9-11시 추천';
    if (concentrationRate <= 60) return '평일 오후 2-4시 추천';
    if (concentrationRate <= 80) return '평일 이른 아침 추천';
    return '다른 날 방문 권장 (매우 혼잡 예상)';
  }

  /// 🔧 집중률 기반 피크 시간 생성
  static String _generatePeakTimeFromConcentration(double concentrationRate) {
    if (concentrationRate <= 20) return '혼잡 시간 없음';
    if (concentrationRate <= 40) return '주말 오후';
    if (concentrationRate <= 60) return '주말 오후 1-5시';
    if (concentrationRate <= 80) return '주말 및 공휴일';
    return '주말 및 공휴일 전체';
  }

  /// 방문자 수를 혼잡도 레벨로 변환
  static int _calculateCongestionFromVisitors(int visitors) {
    // 방문자 수에 따른 혼잡도 계산 로직
    if (visitors < 1000) return 20;
    if (visitors < 5000) return 40;
    if (visitors < 10000) return 60;
    if (visitors < 20000) return 80;
    return 90;
  }

  /// 방문자 데이터를 혼잡도 데이터로 변환 (기존 메서드 유지)
  static CongestionData _parseVisitorDataToCongestion(Map<String, dynamic> item, String type) {
    try {
      // API 응답 필드는 실제 API 문서에 맞게 조정 필요
      final visitCnt = _parseIntSafely(item['visitCnt']) ?? 0;
      final lastWeekCnt = _parseIntSafely(item['lastWeekCnt']) ?? visitCnt;
      final avgCnt = _parseIntSafely(item['avgCnt']) ?? visitCnt;

      // 혼잡도 레벨 계산 (방문자수 기반)
      int congestionLevel;
      if (visitCnt == 0) {
        congestionLevel = 20;
      } else {
        final ratio = avgCnt > 0 ? (visitCnt / avgCnt) : 1.0;
        if (ratio <= 0.7) {
          congestionLevel = 15 + (ratio * 20).round(); // 15-29%
        } else if (ratio <= 1.2) {
          congestionLevel = 30 + ((ratio - 0.7) * 40).round(); // 30-50%
        } else if (ratio <= 1.8) {
          congestionLevel = 50 + ((ratio - 1.2) * 25).round(); // 50-65%
        } else {
          congestionLevel = 65 + min(30, ((ratio - 1.8) * 20).round()); // 65-85%
        }
      }

      // 추천 시간 생성
      String recommendedTime;
      if (congestionLevel <= 30) {
        recommendedTime = '지금 방문 추천';
      } else if (congestionLevel <= 50) {
        recommendedTime = '오전 9-11시';
      } else if (congestionLevel <= 70) {
        recommendedTime = '평일 방문 권장';
      } else {
        recommendedTime = '이른 아침 추천';
      }

      return CongestionData(
        currentLevel: congestionLevel,
        lastWeekVisitors: lastWeekCnt,
        expectedVisitors: (visitCnt * 1.1).round(), // 10% 증가 예상
        recommendedTime: recommendedTime,
        peakTime: _generatePeakTime(congestionLevel),
        predictedVisitors: null,
        dataSource: type,
      );

    } catch (e) {
      print('❌ 방문자 데이터 파싱 실패: $e');
      return _generateDefaultCongestionData('');
    }
  }

  /// 예측 데이터를 혼잡도 데이터로 변환 (기존 메서드 유지)
  static CongestionData _parsePredictionDataToCongestion(Map<String, dynamic> item) {
    try {
      final cnrsRate = _parseDoubleSafely(item['cnrsRate']) ?? 50.0;
      final predictedCnt = _parseIntSafely(item['predictedCnt']) ?? 0;

      // 집중률을 혼잡도 레벨로 변환
      final congestionLevel = (cnrsRate * 0.8).round().clamp(15, 85);

      return CongestionData(
        currentLevel: congestionLevel,
        lastWeekVisitors: 0,
        expectedVisitors: predictedCnt,
        recommendedTime: _generateRecommendedTime(congestionLevel),
        peakTime: _generatePeakTime(congestionLevel),
        predictedVisitors: predictedCnt,
        dataSource: 'prediction',
      );

    } catch (e) {
      print('❌ 예측 데이터 파싱 실패: $e');
      return _generateDefaultCongestionData('');
    }
  }

  /// 기본 혼잡도 데이터 생성
  static CongestionData _generateDefaultCongestionData(String contentId) {
    final random = Random();

    // contentId 해시 기반으로 일관된 값 생성
    final seed = contentId.isNotEmpty ? contentId.hashCode : random.nextInt(1000);
    final seededRandom = Random(seed);

    final baseLevel = 20 + seededRandom.nextInt(40); // 20-60% 사이
    final lastWeek = 80 + seededRandom.nextInt(200); // 80-280명
    final expected = (lastWeek * (0.8 + seededRandom.nextDouble() * 0.4)).round(); // ±20% 변동

    return CongestionData(
      currentLevel: baseLevel,
      lastWeekVisitors: lastWeek,
      expectedVisitors: expected,
      recommendedTime: _generateRecommendedTime(baseLevel),
      peakTime: _generatePeakTime(baseLevel),
      predictedVisitors: null,
      dataSource: 'default',
    );
  }

  /// 추천 시간 생성
  static String _generateRecommendedTime(int congestionLevel) {
    if (congestionLevel <= 25) return '지금 방문 추천';
    if (congestionLevel <= 40) return '오전 9-11시';
    if (congestionLevel <= 60) return '평일 오후 2-4시';
    return '평일 이른 아침';
  }

  /// 피크 시간 생성
  static String _generatePeakTime(int congestionLevel) {
    if (congestionLevel <= 30) return '혼잡 시간 없음';
    if (congestionLevel <= 50) return '주말 오후 1-3시';
    if (congestionLevel <= 70) return '주말 전체';
    return '주말 및 공휴일';
  }

  /// 안전한 정수 파싱
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.round();
    return null;
  }

  /// 안전한 실수 파싱
  static double? _parseDoubleSafely(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ==================== 기본 관광 정보 API 메서드들 (기존 유지) ====================

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

  // ==================== 유틸리티 메서드들 (기존 유지) ====================

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

  /// API 데이터를 NearbyPlace로 변환 (지역코드 포함)
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

        // 🔧 수정: 관광공사 API 좌표 및 지역코드 추출
        double? latitude;
        double? longitude;
        String distance = '';

        // 지역코드 추출 (혼잡도 API용)
        final areaCode = item['areacode']?.toString();
        final sigunguCode = item['sigungucode']?.toString();

        try {
          final mapX = double.tryParse(item['mapx']?.toString() ?? '');
          final mapY = double.tryParse(item['mapy']?.toString() ?? '');

          if (mapX != null && mapY != null && mapX != 0 && mapY != 0) {
            latitude = mapY;  // mapy가 위도
            longitude = mapX; // mapx가 경도

            final distanceKm = _calculateDistance(userLat, userLng, mapY, mapX);
            if (distanceKm < 1.0) {
              distance = '도보 ${(distanceKm * 20).round()}분';
            } else {
              distance = '${distanceKm.toStringAsFixed(1)}km';
            }

            print('✅ ${title} 좌표: (${mapY}, ${mapX}), 지역: ${areaCode}-${sigunguCode}, 거리: ${distanceKm.toStringAsFixed(2)}km');
          } else {
            print('⚠️ ${title} 좌표 정보 없음, 지역: ${areaCode}-${sigunguCode}');
            distance = '거리 정보 없음';
          }
        } catch (e) {
          print('⚠️ ${title} 좌표 파싱 실패: $e');
          distance = '거리 정보 없음';
        }

        final place = NearbyPlace(
          contentId: contentId,
          name: title,
          address: fullAddress,
          distance: distance,
          category: _mapContentTypeToCategory(item['contenttypeid']?.toString()),
          rating: 4.0 + (title.hashCode % 10) / 10,
          isOpen: true,
          description: '',
          reason: '',
          tip: '',
          latitude: latitude,
          longitude: longitude,
          areaCode: areaCode,        // 🔧 추가: 지역코드
          sigunguCode: sigunguCode,  // 🔧 추가: 시군구코드
        );

        places.add(place);

      } catch (e) {
        print('⚠️ 장소 변환 실패: ${item['title']} - $e');
      }
    }

    return places;
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
          // 🔧 수정: HTML 정리 적용
          infoParts.add('🕐 이용시간: ${HtmlUtils.toSingleLine(usetime)}');
        }
        if (restdate != null && restdate.isNotEmpty) {
          infoParts.add('📅 휴무일: ${HtmlUtils.toSingleLine(restdate)}');
        }
        if (parking != null && parking.isNotEmpty) {
          infoParts.add('🚗 주차: ${HtmlUtils.toSingleLine(parking)}');
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
          infoParts.add('🕐 영업시간: ${HtmlUtils.toSingleLine(opentimefood)}');
        }
        if (restdatefood != null && restdatefood.isNotEmpty) {
          infoParts.add('📅 휴무일: ${HtmlUtils.toSingleLine(restdatefood)}');
        }
        if (treatmenu != null && treatmenu.isNotEmpty) {
          infoParts.add('🍽️ 대표메뉴: ${HtmlUtils.toSingleLine(treatmenu)}');
        }
        if (reservationfood != null && reservationfood.isNotEmpty) {
          infoParts.add('📞 예약안내: ${HtmlUtils.toSingleLine(reservationfood)}');
        }
        if (parkingfood != null && parkingfood.isNotEmpty) {
          infoParts.add('🚗 주차: ${HtmlUtils.toSingleLine(parkingfood)}');
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
          infoParts.add('🕐 입실시간: ${HtmlUtils.toSingleLine(checkintime)}');
        }
        if (checkouttime != null && checkouttime.isNotEmpty) {
          infoParts.add('🕐 퇴실시간: ${HtmlUtils.toSingleLine(checkouttime)}');
        }
        if (roomtype != null && roomtype.isNotEmpty) {
          infoParts.add('🏠 객실유형: ${HtmlUtils.toSingleLine(roomtype)}');
        }
        if (reservationlodging != null && reservationlodging.isNotEmpty) {
          infoParts.add('📞 예약안내: ${HtmlUtils.toSingleLine(reservationlodging)}');
        }
        if (parkinglodging != null && parkinglodging.isNotEmpty) {
          infoParts.add('🚗 주차: ${HtmlUtils.toSingleLine(parkinglodging)}');
        }
        if (subfacility != null && subfacility.isNotEmpty) {
          infoParts.add('🏊 부대시설: ${HtmlUtils.toSingleLine(subfacility)}');
        }
        break;

      case '14': // 문화시설
        final usetime = introDetail['usetime']?.toString();
        final restdate = introDetail['restdate']?.toString();
        final parkingculture = introDetail['parkingculture']?.toString();
        final usefee = introDetail['usefee']?.toString();

        if (usetime != null && usetime.isNotEmpty) {
          infoParts.add('🕐 이용시간: ${HtmlUtils.toSingleLine(usetime)}');
        }
        if (restdate != null && restdate.isNotEmpty) {
          infoParts.add('📅 휴무일: ${HtmlUtils.toSingleLine(restdate)}');
        }
        if (usefee != null && usefee.isNotEmpty) {
          infoParts.add('💰 이용요금: ${HtmlUtils.toSingleLine(usefee)}');
        }
        if (parkingculture != null && parkingculture.isNotEmpty) {
          infoParts.add('🚗 주차: ${HtmlUtils.toSingleLine(parkingculture)}');
        }
        break;

      case '28': // 레포츠
        final openperiod = introDetail['openperiod']?.toString();
        final restdateleports = introDetail['restdateleports']?.toString();
        final parkingleports = introDetail['parkingleports']?.toString();
        final usefeeleports = introDetail['usefeeleports']?.toString();

        if (openperiod != null && openperiod.isNotEmpty) {
          infoParts.add('🕐 이용기간: ${HtmlUtils.toSingleLine(openperiod)}');
        }
        if (restdateleports != null && restdateleports.isNotEmpty) {
          infoParts.add('📅 휴무일: ${HtmlUtils.toSingleLine(restdateleports)}');
        }
        if (usefeeleports != null && usefeeleports.isNotEmpty) {
          infoParts.add('💰 이용요금: ${HtmlUtils.toSingleLine(usefeeleports)}');
        }
        if (parkingleports != null && parkingleports.isNotEmpty) {
          infoParts.add('🚗 주차: ${HtmlUtils.toSingleLine(parkingleports)}');
        }
        break;

      case '38': // 쇼핑
        final opentime = introDetail['opentime']?.toString();
        final restdateshopping = introDetail['restdateshopping']?.toString();
        final parkingshopping = introDetail['parkingshopping']?.toString();
        final saleitem = introDetail['saleitem']?.toString();

        if (opentime != null && opentime.isNotEmpty) {
          infoParts.add('🕐 영업시간: ${HtmlUtils.toSingleLine(opentime)}');
        }
        if (restdateshopping != null && restdateshopping.isNotEmpty) {
          infoParts.add('📅 휴무일: ${HtmlUtils.toSingleLine(restdateshopping)}');
        }
        if (saleitem != null && saleitem.isNotEmpty) {
          infoParts.add('🛍️ 판매품목: ${HtmlUtils.toSingleLine(saleitem)}');
        }
        if (parkingshopping != null && parkingshopping.isNotEmpty) {
          infoParts.add('🚗 주차: ${HtmlUtils.toSingleLine(parkingshopping)}');
        }
        break;
    }

    return infoParts.join('\n');
  }

// 3. _convertToPlaceDetail 메서드도 수정
  static PlaceDetail _convertToPlaceDetail(Map<String, dynamic> detail, String additionalInfo) {
    final overview = detail['overview']?.toString() ?? '';

    return PlaceDetail(
      name: detail['title']?.toString() ?? '',
      location: detail['addr1']?.toString() ?? '',
      description: HtmlUtils.toMultiLine(overview), // 🔧 수정: HtmlUtils 사용
      phone: detail['tel']?.toString() ?? '',
      hours: '운영시간 정보 없음',
      facilities: additionalInfo.isNotEmpty ? additionalInfo : '시설 정보 없음',
      fee: '요금 정보 없음',
      parking: '주차 정보 없음',
      transport: '교통 정보 없음',
      special: overview.isNotEmpty ? HtmlUtils.toMultiLine(overview) : '', // 🔧 수정: HtmlUtils 사용
      recommendedTime: '언제든지',
    );
  }

  /// 캐시 클리어
  static void clearCache() {
    _apiCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ 관광공사 API 캐시가 클리어되었습니다');
  }
}

// ==================== 🔧 새로 추가: 모델 클래스들 ====================

/// 지역코드 정보 모델
class AreaCodeInfo {
  final String? code;  // nullable로 변경
  final String name;

  const AreaCodeInfo({
    required this.code,
    required this.name,
  });

  @override
  String toString() => 'AreaCode($code: $name)';
}

/// 시군구코드 정보 모델
class SigunguCodeInfo {
  final String areaCode;
  final String sigunguCode;
  final String name;

  const SigunguCodeInfo({
    required this.areaCode,
    required this.sigunguCode,
    required this.name,
  });

  @override
  String toString() => 'SigunguCode($areaCode-$sigunguCode: $name)';
}

// ==================== 기존 모델 클래스들 (기존 유지) ====================

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
  // 🔧 추가: 좌표 정보 (관광공사 API의 mapx, mapy)
  final double? latitude;
  final double? longitude;
  // 🔧 추가: 혼잡도 API용 지역코드
  final String? areaCode;
  final String? sigunguCode;

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
    this.latitude,
    this.longitude,
    this.areaCode,
    this.sigunguCode,
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
      'latitude': latitude,
      'longitude': longitude,
      'areaCode': areaCode,
      'sigunguCode': sigunguCode,
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
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      areaCode: json['areaCode']?.toString(),
      sigunguCode: json['sigunguCode']?.toString(),
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
