import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:offpeak/core/service/tourism_api_service.dart';

/// 통합 LaaS API 서비스 - 관광공사 API와 LaaS AI API 통합 관리
class UnifiedLaaSAPIService {
  // Base URLs
  static const String _korServiceBaseUrl = 'https://apis.data.go.kr/B551011/KorService2';
  static const String _photoGalleryBaseUrl = 'https://apis.data.go.kr/B551011/PhotoGalleryService1';
  static const String _dataLabBaseUrl = 'https://apis.data.go.kr/B551011/DataLabService';
  static const String _tarRlteBaseUrl = 'https://apis.data.go.kr/B551011/TarRlteTarService1';
  static const String _tatsCnctrBaseUrl = 'https://apis.data.go.kr/B551011/TatsCnctrRateService';

  // LaaS AI API URL (Java 문서 기준)
  static const String _laasApiUrl = 'https://api-laas.wanted.co.kr/api/preset/v2/chat/completions';

  // Timeout 설정
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _aiTimeout = Duration(seconds: 45);
  static const Duration _imageTimeout = Duration(seconds: 20);

  // ==================== 환경변수 Getters ====================

  /// 관광공사 API 서비스키
  static String get _tourApiServiceKey {
    final key = dotenv.env['TOUR_API_SERVICE_KEY'];
    if (key == null || key.isEmpty) {
      throw LaaSException('TOUR_API_SERVICE_KEY가 .env 파일에 설정되지 않았습니다.');
    }
    return key;
  }

  /// LaaS 프로젝트 코드
  static String get _laasProjectCode {
    final code = dotenv.env['LAAS_PROJECT_CODE'];
    if (code == null || code.isEmpty) {
      throw LaaSException('LAAS_PROJECT_CODE가 .env 파일에 설정되지 않았습니다.');
    }
    return code;
  }

  /// LaaS API 키
  static String get _laasApiKey {
    final key = dotenv.env['LAAS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw LaaSException('LAAS_API_KEY가 .env 파일에 설정되지 않았습니다.');
    }
    return key;
  }

  /// LaaS 해시값
  static String get _laasHash {
    final hash = dotenv.env['LAAS_HASH'];
    if (hash == null || hash.isEmpty) {
      throw LaaSException('LAAS_HASH가 .env 파일에 설정되지 않았습니다.');
    }
    return hash;
  }

  // ==================== LaaS AI API ====================

  /// 원티드 LaaS AI API 호출 (Java 방식 기준)
  static Future<String> callAI(String prompt) async {
    print('🤖 =================================');
    print('🤖 LaaS AI API 호출 시작');
    print('🤖 =================================');

    try {
      // 환경변수 확인 및 출력
      print('🤖 환경변수 확인:');
      print('   - LAAS_PROJECT_CODE: ${dotenv.env['LAAS_PROJECT_CODE'] ?? 'NULL'}');
      print('   - LAAS_API_KEY 존재: ${dotenv.env['LAAS_API_KEY'] != null}');
      print('   - LAAS_HASH: ${dotenv.env['LAAS_HASH'] ?? 'NULL'}');

      final projectCode = _laasProjectCode;
      final apiKey = _laasApiKey;
      final hash = _laasHash;

      print('🤖 실제 사용값:');
      print('   - 프로젝트: $projectCode');
      print('   - API키 앞 10자리: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
      print('   - 해시: $hash');

      // Java 방식과 동일한 헤더 설정
      final headers = {
        'project': projectCode,
        'apiKey': apiKey,
        'Content-Type': 'application/json; charset=utf-8',
      };

      // Java 방식과 동일한 요청 본문
      final requestBody = {
        'hash': hash,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      };

      print('🤖 요청 정보:');
      print('   - URL: $_laasApiUrl');
      print('   - 헤더: $headers');
      print('   - 본문: ${jsonEncode(requestBody)}');

      // HTTP 요청 실행
      final response = await http.post(
        Uri.parse(_laasApiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(_aiTimeout);

      print('🤖 응답 정보:');
      print('   - 상태 코드: ${response.statusCode}');
      print('   - 응답 헤더: ${response.headers}');
      print('   - 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // OpenAI 스타일 응답 파싱 (choices 배열)
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          final message = choice['message'];
          if (message != null && message['content'] != null) {
            final content = message['content'].toString();
            print('✅ AI 응답 성공: $content');
            return content;
          }
        }

        // 다른 응답 형식 fallback
        final fallbackResult = data['result']?.toString() ??
            data['response']?.toString() ??
            data['content']?.toString() ??
            jsonEncode(data);

        print('✅ AI 응답 성공 (fallback): $fallbackResult');
        return fallbackResult;

      } else {
        print('❌ AI API HTTP 오류:');
        print('   - 상태: ${response.statusCode}');
        print('   - 메시지: ${response.reasonPhrase}');
        print('   - 본문: ${response.body}');
        throw LaaSException('AI API 오류: ${response.statusCode} - ${response.body}');
      }

    } catch (e, stackTrace) {
      print('❌ =================================');
      print('❌ AI API 호출 예외 발생');
      print('❌ =================================');
      print('❌ 예외: $e');
      print('❌ 스택트레이스: $stackTrace');
      print('❌ =================================');
      rethrow;
    }
  }

  /// AI API 연결 테스트
  static Future<bool> checkAIConnection() async {
    print('🔍 =================================');
    print('🔍 AI 연결 상태 확인 시작');
    print('🔍 =================================');

    try {
      // 환경변수 존재 여부 먼저 확인
      print('🔍 환경변수 존재 확인:');
      print('   - LAAS_PROJECT_CODE: ${dotenv.env.containsKey('LAAS_PROJECT_CODE')}');
      print('   - LAAS_API_KEY: ${dotenv.env.containsKey('LAAS_API_KEY')}');
      print('   - LAAS_HASH: ${dotenv.env.containsKey('LAAS_HASH')}');

      if (!dotenv.env.containsKey('LAAS_PROJECT_CODE') ||
          !dotenv.env.containsKey('LAAS_API_KEY') ||
          !dotenv.env.containsKey('LAAS_HASH')) {
        print('❌ 필수 환경변수가 누락됨');
        return false;
      }

      print('🔍 AI API 테스트 호출 시작...');
      final result = await callAI('테스트');

      if (result.isNotEmpty) {
        print('✅ AI 연결 성공: $result');
        return true;
      } else {
        print('❌ AI 연결 실패: 빈 응답');
        return false;
      }
    } catch (e) {
      print('❌ AI 연결 확인 실패: $e');
      return false;
    }
  }

  /// AI 응답 유효성 검증
  static bool validateAIResponse(String response) {
    if (response.isEmpty) return false;

    // AI 추천 응답의 필수 키워드 확인
    return response.contains('장소명:') ||
        response.contains('데이터ID:') ||
        response.contains('추천') ||
        response.length >= 10; // 최소 길이 확인
  }

  // ==================== 관광공사 API 공통 메서드 ====================

  /// 공통 파라미터 생성
  static Map<String, String> _getCommonParams({
    int numOfRows = 10,
    int pageNo = 1,
    String type = 'json',
  }) {
    return {
      'serviceKey': _tourApiServiceKey,
      'numOfRows': numOfRows.toString(),
      'pageNo': pageNo.toString(),
      'MobileOS': 'ETC',
      'MobileApp': 'Offpeak',
      '_type': type,
    };
  }

  // 캐싱 시스템 추가
  static final Map<String, dynamic> _apiCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(hours: 1);

  /// HTTP 요청 공통 처리 (캐싱 추가)
  static Future<Map<String, dynamic>?> _makeRequest(
      String url,
      Map<String, String> params,
      String apiName, {
        Duration? timeout,
      }) async {
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
          .timeout(timeout ?? _requestTimeout);

      print('📡 [$apiName] 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        // API 한도 초과 체크 (XML 응답)
        if (response.body.contains('LIMITED_NUMBER_OF_SERVICE_REQUESTS_EXCEEDS_ERROR')) {
          print('❌ [$apiName] API 호출 한도 초과');
          throw LaaSException('API 호출 한도가 초과되었습니다. 잠시 후 다시 시도해주세요.');
        }

        // JSON 파싱 시도
        try {
          final data = jsonDecode(response.body);
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
          print('   응답 내용: ${response.body.substring(0, 200)}...');

          // XML 오류 메시지 확인
          if (response.body.contains('<returnReasonCode>22</returnReasonCode>')) {
            throw LaaSException('API 호출 한도가 초과되었습니다. 내일 다시 시도해주세요.');
          }

          return null;
        }
      } else {
        print('❌ [$apiName] HTTP 오류: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (e is LaaSException) {
        rethrow;
      }
      print('❌ [$apiName] 요청 실패: $e');
      return null;
    }
  }

  // ==================== 관광공사 API 메서드들 ====================

  /// 지역기반 관광정보 조회
  static Future<Map<String, dynamic>?> getAreaBasedList({
    int numOfRows = 10,
    int pageNo = 1,
    String? arrange,
    String? contentTypeId,
    String? areaCode,
    String? sigunguCode,
    String? cat1,
    String? cat2,
    String? cat3,
    String? modifiedtime,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    if (arrange != null) params['arrange'] = arrange;
    if (contentTypeId != null) params['contentTypeId'] = contentTypeId;
    if (areaCode != null) params['areaCode'] = areaCode;
    if (sigunguCode != null) params['sigunguCode'] = sigunguCode;
    if (cat1 != null) params['cat1'] = cat1;
    if (cat2 != null) params['cat2'] = cat2;
    if (cat3 != null) params['cat3'] = cat3;
    if (modifiedtime != null) params['modifiedtime'] = modifiedtime;

    return _makeRequest('$_korServiceBaseUrl/areaBasedList2', params, 'AreaBasedList');
  }

  /// 위치기반 관광정보 조회
  static Future<Map<String, dynamic>?> getLocationBasedList({
    int numOfRows = 10,
    int pageNo = 1,
    String? arrange,
    required String mapX,
    required String mapY,
    required String radius,
    String? contentTypeId,
    String? cat1,
    String? cat2,
    String? cat3,
    String? areaCode,
    String? signguCode,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    params['mapX'] = mapX;
    params['mapY'] = mapY;
    params['radius'] = radius;

    if (arrange != null) params['arrange'] = arrange;
    if (contentTypeId != null) params['contentTypeId'] = contentTypeId;
    if (cat1 != null) params['cat1'] = cat1;
    if (cat2 != null) params['cat2'] = cat2;
    if (cat3 != null) params['cat3'] = cat3;
    if (areaCode != null) params['areaCode'] = areaCode;
    if (signguCode != null) params['signguCode'] = signguCode;

    return _makeRequest('$_korServiceBaseUrl/locationBasedList2', params, 'LocationBasedList');
  }

  /// 키워드 검색 조회
  static Future<Map<String, dynamic>?> searchKeyword({
    int numOfRows = 10,
    int pageNo = 1,
    String? arrange,
    required String keyword,
    String? areaCode,
    String? signguCode,
    String? cat1,
    String? cat2,
    String? cat3,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    params['keyword'] = keyword;

    if (arrange != null) params['arrange'] = arrange;
    if (areaCode != null) params['areaCode'] = areaCode;
    if (signguCode != null) params['signguCode'] = signguCode;
    if (cat1 != null) params['cat1'] = cat1;
    if (cat2 != null) params['cat2'] = cat2;
    if (cat3 != null) params['cat3'] = cat3;

    return _makeRequest('$_korServiceBaseUrl/searchKeyword2', params, 'SearchKeyword');
  }

  /// 공통정보 조회
  static Future<Map<String, dynamic>?> getDetailCommon({
    required String contentId,
    int numOfRows = 10,
    int pageNo = 1,
  }) async {
    if (!isValidContentId(contentId)) {
      print('❌ [DetailCommon] 유효하지 않은 contentId: "$contentId"');
      return null;
    }

    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['contentId'] = contentId;

    return _makeRequest('$_korServiceBaseUrl/detailCommon2', params, 'DetailCommon');
  }

  /// 이미지정보 조회
  static Future<Map<String, dynamic>?> getDetailImage({
    required String contentId,
    int numOfRows = 10,
    int pageNo = 1,
    String imageYN = 'Y',
    String subImageYN = 'Y',
  }) async {
    if (!isValidContentId(contentId)) {
      print('❌ [DetailImage] 유효하지 않은 contentId: "$contentId"');
      return null;
    }

    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['contentId'] = contentId;
    params['imageYN'] = imageYN;
    params['subImageYN'] = subImageYN;

    print('🖼️ [DetailImage] contentId: $contentId, imageYN: $imageYN');

    return _makeRequest(
      '$_korServiceBaseUrl/detailImage2',
      params,
      'DetailImage',
      timeout: _imageTimeout,
    );
  }

  /// 소개정보 조회 (contentId 기반)
  static Future<Map<String, dynamic>?> getDetailIntroByContentId({
    required String contentId,
    required String contentTypeId,
    int numOfRows = 10,
    int pageNo = 1,
  }) async {
    if (!isValidContentId(contentId)) {
      print('❌ [DetailIntro] 유효하지 않은 contentId: "$contentId"');
      return null;
    }

    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['contentId'] = contentId;
    params['contentTypeId'] = contentTypeId;

    return _makeRequest('$_korServiceBaseUrl/detailIntro2', params, 'DetailIntro-ContentId');
  }

  /// 소개정보 조회 (카테고리 기반)
  static Future<Map<String, dynamic>?> getDetailIntroByCategory({
    required String contentTypeId,
    int numOfRows = 10,
    int pageNo = 1,
    String? cat1,
    String? cat2,
    String? cat3,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['contentTypeId'] = contentTypeId;

    if (cat1 != null) params['cat1'] = cat1;
    if (cat2 != null) params['cat2'] = cat2;
    if (cat3 != null) params['cat3'] = cat3;

    return _makeRequest('$_korServiceBaseUrl/detailIntro2', params, 'DetailIntro-Category');
  }

  /// 지역코드 조회
  static Future<Map<String, dynamic>?> getAreaCode({
    int numOfRows = 10,
    int pageNo = 1,
    String? areaCode,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    if (areaCode != null) params['areaCode'] = areaCode;

    return _makeRequest('$_korServiceBaseUrl/areaCode2', params, 'AreaCode');
  }

  /// 관광사진 갤러리 목록 조회
  static Future<Map<String, dynamic>?> getPhotoGalleryList({
    int numOfRows = 10,
    int pageNo = 1,
    String? arrange,
    String? baseYm,
    String? areaCd,
    String? signguCd,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    if (arrange != null) params['arrange'] = arrange;
    if (baseYm != null) params['baseYm'] = baseYm;
    if (areaCd != null) params['areaCd'] = areaCd;
    if (signguCd != null) params['signguCd'] = signguCd;

    return _makeRequest('$_photoGalleryBaseUrl/galleryList1', params, 'PhotoGalleryList');
  }

  /// 관광사진 갤러리 키워드 검색
  static Future<Map<String, dynamic>?> searchPhotoGallery({
    int numOfRows = 10,
    int pageNo = 1,
    required String keyword,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['keyword'] = keyword;

    return _makeRequest(_photoGalleryBaseUrl, params, 'SearchPhotoGallery');
  }

  /// 기초 지자체 지역방문자수 집계 데이터 조회
  static Future<Map<String, dynamic>?> getLocalVisitorStats({
    int numOfRows = 10,
    int pageNo = 1,
    required String startYmd,
    required String endYmd,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['startYmd'] = startYmd;
    params['endYmd'] = endYmd;

    return _makeRequest('$_dataLabBaseUrl/locgoRegnVisitrDDList', params, 'LocalVisitorStats');
  }

  /// 광역 지자체 지역방문자수 집계 데이터 조회
  static Future<Map<String, dynamic>?> getMetroVisitorStats({
    int numOfRows = 10,
    int pageNo = 1,
    required String startYmd,
    required String endYmd,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);
    params['startYmd'] = startYmd;
    params['endYmd'] = endYmd;

    return _makeRequest('$_dataLabBaseUrl/metcoRegnVisitrDDList', params, 'MetroVisitorStats');
  }

  /// 관광지별 연관 관광지정보 키워드 검색
  static Future<Map<String, dynamic>?> getTourismRelatedSearch({
    int numOfRows = 10,
    int pageNo = 1,
    String? baseYm,
    String? areaCd,
    String? signguCd,
    String? keyword,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    if (baseYm != null) params['baseYm'] = baseYm;
    if (areaCd != null) params['areaCd'] = areaCd;
    if (signguCd != null) params['signguCd'] = signguCd;
    if (keyword != null) params['keyword'] = keyword;

    return _makeRequest(_tarRlteBaseUrl, params, 'TourismRelatedSearch');
  }

  /// 관광지 집중률 방문자추이예측
  static Future<Map<String, dynamic>?> getTourismConcentrationRate({
    int numOfRows = 10,
    int pageNo = 1,
    String? areaCd,
    String? signguCd,
    String? tAtsNm,
  }) async {
    final params = _getCommonParams(numOfRows: numOfRows, pageNo: pageNo);

    if (areaCd != null) params['areaCd'] = areaCd;
    if (signguCd != null) params['signguCd'] = signguCd;
    if (tAtsNm != null) params['tAtsNm'] = tAtsNm;

    return _makeRequest('$_tatsCnctrBaseUrl/tatsCnctrRatedList', params, 'TourismConcentrationRate');
  }

  // ==================== 유틸리티 메서드 ====================

  /// API 응답에서 아이템 리스트 추출
  static List<dynamic>? extractItems(Map<String, dynamic>? response) {
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
  static int? extractTotalCount(Map<String, dynamic>? response) {
    return response?['response']?['body']?['totalCount'];
  }

  /// contentId 유효성 검증
  static bool isValidContentId(String? contentId) {
    if (contentId == null || contentId.isEmpty) return false;

    final trimmed = contentId.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == '0') return false;

    final numValue = int.tryParse(trimmed);
    return numValue != null && numValue > 0;
  }

  /// 이미지 URL 유효성 검증
  static bool isValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;

    final lower = imageUrl.toLowerCase();
    return lower.startsWith('http') &&
        (lower.contains('.jpg') || lower.contains('.jpeg') ||
            lower.contains('.png') || lower.contains('.gif') ||
            lower.contains('.webp'));
  }

  /// API 연결 상태 확인
  static Future<bool> checkAPIConnection() async {
    try {
      print('🔍 관광공사 API 연결 확인...');
      final result = await getAreaCode(numOfRows: 1);
      if (result != null) {
        print('✅ 관광공사 API 연결 성공');
        return true;
      } else {
        print('❌ 관광공사 API 연결 실패');
        return false;
      }
    } catch (e) {
      print('❌ 관광공사 API 연결 확인 실패: $e');
      return false;
    }
  }

  /// 환경변수 디버그 출력
  static void debugEnvironmentVariables() {
    print('🔍 =================================');
    print('🔍 환경변수 디버그 정보');
    print('🔍 =================================');

    final envKeys = ['LAAS_PROJECT_CODE', 'LAAS_API_KEY', 'LAAS_HASH', 'TOUR_API_SERVICE_KEY'];

    for (final key in envKeys) {
      final value = dotenv.env[key];
      if (value != null) {
        final displayValue = value.length > 20
            ? '${value.substring(0, 20)}...'
            : value;
        print('   - $key: $displayValue');
      } else {
        print('   - $key: NULL');
      }
    }

    print('🔍 =================================');
  }

  /// 캐시 클리어 (필요시 사용)
  static void clearCache() {
    _apiCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ API 캐시가 클리어되었습니다');
  }

  /// 폴백 이미지 URL 생성 (API 한도 초과시 사용)
  static List<String> generateFallbackImages(String contentId, String? category) {
    // 카테고리별 기본 이미지 URL들 (무료 이미지 서비스 활용)
    final categoryImages = {
      'festival': [
        'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800&h=600',
        'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=600',
      ],
      'tourist_spot': [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600',
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&h=600',
      ],
      'culture': [
        'https://images.unsplash.com/photo-1518998053901-5348d3961a04?w=800&h=600',
        'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&h=600',
      ],
      'accommodation': [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&h=600',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&h=600',
      ],
    };

    final images = categoryImages[category] ?? categoryImages['tourist_spot']!;

    // contentId 해시를 사용해 일관된 이미지 선택
    final index = contentId.hashCode.abs() % images.length;
    return [images[index]];
  }
  static Future<String> callAIWithContext({
    required String userMessage,
    List<NearbyPlace>? nearbyPlaces,
  }) async {
    print('🤖 =================================');
    print('🤖 컨텍스트 기반 AI API 호출 시작');
    print('🤖 =================================');

    try {
      // 프롬프트 구성
      String prompt = userMessage;

      // 주변 장소 정보가 있으면 컨텍스트 추가
      if (nearbyPlaces != null && nearbyPlaces.isNotEmpty) {
        print('📍 ${nearbyPlaces.length}개 주변 장소 정보로 프롬프트 구성');

        final contextBuffer = StringBuffer();
        contextBuffer.writeln('사용자 질문: $userMessage\n');
        contextBuffer.writeln('주변 장소 정보:');

        for (int i = 0; i < nearbyPlaces.length; i++) {
          final place = nearbyPlaces[i];
          contextBuffer.writeln('${i + 1}. ${place.name}');

          if (place.distance.isNotEmpty) {
            contextBuffer.writeln('   ${place.distance}');
          }
          if (place.address.isNotEmpty) {
            contextBuffer.writeln('   ${place.address}');
          }
          if (place.description.isNotEmpty && place.description.length > 10) {
            final shortDesc = place.description.length > 100
                ? '${place.description.substring(0, 100)}...'
                : place.description;
            contextBuffer.writeln('   설명: $shortDesc');
          }
          contextBuffer.writeln('   카테고리: ${_getCategoryDisplayName(place.category)}');
          contextBuffer.writeln('');
        }

        contextBuffer.writeln('''
위 주변 장소 정보를 참고해서 사용자의 질문에 구체적이고 실용적인 답변을 해주세요.
실제 장소명, 거리, 특징을 포함해서 추천해주세요.
한국어로 친근하고 자연스럽게 답변해주세요.''');

        prompt = contextBuffer.toString();
        print('✅ 컨텍스트 포함 프롬프트 구성 완료');
      } else {
        print('📝 일반 질문으로 처리');
      }

      // 기존 callAI 메서드 호출
      return await callAI(prompt);

    } catch (e, stackTrace) {
      print('❌ =================================');
      print('❌ 컨텍스트 기반 AI API 호출 예외 발생');
      print('❌ =================================');
      print('❌ 예외: $e');
      print('❌ 스택트레이스: $stackTrace');
      print('❌ =================================');
      rethrow;
    }
  }

  /// 카테고리 표시명 변환 (내부 유틸리티)
  static String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'tourist_spot':
        return '관광지';
      case 'culture':
        return '문화시설';
      case 'restaurant':
        return '음식점';
      case 'accommodation':
        return '숙박';
      case 'shopping':
        return '쇼핑';
      case 'leisure':
        return '레포츠';
      case 'festival':
        return '축제/행사';
      case 'course':
        return '여행코스';
      default:
        return '기타';
    }
  }
}

/// LaaS 서비스 예외 클래스
class LaaSException implements Exception {
  final String message;
  LaaSException(this.message);

  @override
  String toString() => message;
}
