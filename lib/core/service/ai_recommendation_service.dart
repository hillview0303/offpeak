import 'dart:convert';
import 'dart:math';
import '../../features/home/presentation/providers/recommendation_model.dart';
import 'unified_laas_api_service.dart';

/// LaaS 데이터와 AI를 결합한 스마트 추천 서비스
class AIRecommendationService {

  /// LaaS 데이터 기반 AI 추천 (메인 메서드)
  static Future<List<RecommendationCard>> fetchRecommendations({
    String? areaCode,
    String? sigunguCode,
    String? contentType,
    String? categoryCode,
    Map<String, dynamic>? userPreferences,
  }) async {
    try {
      print('🤖 AI 추천 서비스 시작');
      print('📍 필터: area=$areaCode, sigungu=$sigunguCode, content=$contentType, category=$categoryCode');

      // 1단계: LaaS에서 실제 관광지 데이터 조회
      final laasData = await _fetchLaaSData(
        areaCode: areaCode,
        sigunguCode: sigunguCode,
        contentType: contentType,
        categoryCode: categoryCode,
      );

      if (laasData.isEmpty) {
        throw AIServiceException('조건에 맞는 관광지 데이터를 찾을 수 없습니다. 다른 조건으로 시도해주세요.');
      }

      print('📊 LaaS에서 ${laasData.length}개 데이터 조회 완료');

      // 2단계: AI에게 실제 데이터를 분석하여 추천 요청
      final aiRecommendations = await _getAIAnalysis(
        laasData: laasData,
        userPreferences: userPreferences,
        areaCode: areaCode,
        contentType: contentType,
      );

      if (aiRecommendations.isEmpty) {
        // AI 실패시 LaaS 데이터를 직접 추천카드로 변환
        print('⚠️ AI 분석 실패, LaaS 데이터로 추천 생성');
        return await _convertLaaSToRecommendations(laasData);
      }

      print('✅ AI 추천 완료: ${aiRecommendations.length}개');
      return aiRecommendations;

    } catch (e) {
      print('❌ AI 추천 서비스 실패: $e');

      if (e is AIServiceException) {
        rethrow;
      }

      // 네트워크 오류 체크
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException')) {
        throw AIServiceException('인터넷 연결을 확인해주세요. 네트워크 상태가 불안정합니다.');
      }

      throw AIServiceException('AI 추천 서비스에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// LaaS에서 관광지 데이터 조회
  static Future<List<Map<String, dynamic>>> _fetchLaaSData({
    String? areaCode,
    String? sigunguCode,
    String? contentType,
    String? categoryCode,
  }) async {
    try {
      final response = await UnifiedLaaSAPIService.getAreaBasedList(
        numOfRows: 30, // 충분한 데이터 확보
        areaCode: areaCode,
        sigunguCode: sigunguCode,
        contentTypeId: contentType,
        cat1: (categoryCode?.length ?? 0) >= 3 ? categoryCode!.substring(0, 3) : null,
        cat2: (categoryCode?.length ?? 0) >= 5 ? categoryCode!.substring(0, 5) : null,
        cat3: categoryCode,
        arrange: 'C', // 수정시간순 (최신 데이터)
      );

      final items = UnifiedLaaSAPIService.extractItems(response);
      if (items == null || items.isEmpty) {
        print('📭 LaaS에서 조건에 맞는 데이터가 없습니다');
        return [];
      }

      // 데이터 품질 필터링 (제목과 주소가 있는 것만)
      final filteredItems = items.where((item) {
        final title = item['title']?.toString().trim();
        final addr = item['addr1']?.toString().trim();
        return title != null && title.isNotEmpty &&
            addr != null && addr.isNotEmpty;
      }).toList();

      return List<Map<String, dynamic>>.from(filteredItems);
    } catch (e) {
      print('❌ LaaS 데이터 조회 실패: $e');
      return [];
    }
  }

  /// AI에게 LaaS 데이터 분석 요청
  static Future<List<RecommendationCard>> _getAIAnalysis({
    required List<Map<String, dynamic>> laasData,
    Map<String, dynamic>? userPreferences,
    String? areaCode,
    String? contentType,
  }) async {
    try {
      // AI 프롬프트 생성
      final prompt = _buildAIPrompt(
        laasData: laasData,
        userPreferences: userPreferences,
        areaCode: areaCode,
        contentType: contentType,
      );

      // UnifiedLaaSAPIService를 통해 AI API 호출
      final aiResponse = await UnifiedLaaSAPIService.callAI(prompt);

      if (!UnifiedLaaSAPIService.validateAIResponse(aiResponse)) {
        print('⚠️ AI 응답이 올바르지 않습니다. 폴백 모드로 전환');
        return [];
      }

      // AI 응답을 추천카드로 파싱
      final recommendations = await _parseAIRecommendations(aiResponse, laasData);

      return recommendations;
    } catch (e) {
      print('❌ AI 분석 실패: $e');
      return [];
    }
  }

  /// AI 프롬프트 생성 (LaaS 실제 데이터 포함)
  static String _buildAIPrompt({
    required List<Map<String, dynamic>> laasData,
    Map<String, dynamic>? userPreferences,
    String? areaCode,
    String? contentType,
  }) {
    final locationInfo = areaCode != null ? _getAreaName(areaCode) : '전국';
    final typeInfo = contentType != null ? _getContentTypeName(contentType) : '모든 유형';
    final preferences = _analyzeUserPreferences(userPreferences);

    // LaaS 데이터를 텍스트로 변환
    final dataText = StringBuffer();
    for (int i = 0; i < laasData.length && i < 15; i++) { // 최대 15개
      final item = laasData[i];
      dataText.writeln('${i + 1}. ${item['title']} - ${item['addr1']} (ID: ${item['contentid']})');
    }

    return '''
당신은 한국의 조용하고 한적한 여행지 전문 AI입니다.

다음은 $locationInfo 지역의 실제 $typeInfo 관광지 데이터입니다:

$dataText

사용자 선호도: $preferences

위 실제 데이터 중에서 조용하고 한적한 여행지 3-5곳을 엄선해서 추천해주세요.
각 추천지에 대해 반드시 아래 형식을 정확히 따라 답변해주세요:

1. 장소명: [위 데이터의 정확한 장소명]
2. 데이터ID: [위 데이터의 contentid]
3. 추천순위: [1-5 사이 숫자]
4. 조용한이유: [이 장소가 조용하고 한적한 이유 1-2문장]
5. 추천활동: [이 장소에서 할 수 있는 조용한 활동]
6. 방문팁: [방문시 유용한 팁이나 주의사항]
7. 매칭률: [85-99 사이 숫자]%

---

반드시 위 실제 데이터에 있는 장소만 추천하고, 데이터ID를 정확히 기재해주세요.
''';
  }

  /// AI 응답을 추천카드로 파싱
  static Future<List<RecommendationCard>> _parseAIRecommendations(
      String aiResponse,
      List<Map<String, dynamic>> laasData
      ) async {
    final recommendations = <RecommendationCard>[];

    try {
      final lines = aiResponse.split('\n');
      Map<String, dynamic>? currentRec;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed == '---') continue;

        if (trimmed.contains('장소명:')) {
          if (currentRec != null && currentRec['title'] != null) {
            final card = await _createRecommendationFromAI(currentRec, laasData);
            if (card != null) recommendations.add(card);
          }
          currentRec = <String, dynamic>{};
          currentRec['title'] = trimmed.split('장소명:')[1].trim();
        }
        else if (trimmed.contains('데이터ID:') && currentRec != null) {
          currentRec['contentId'] = trimmed.split('데이터ID:')[1].trim();
        }
        else if (trimmed.contains('추천순위:') && currentRec != null) {
          final rankMatch = RegExp(r'(\d+)').firstMatch(trimmed);
          if (rankMatch != null) {
            currentRec['rank'] = int.tryParse(rankMatch.group(1)!) ?? 1;
          }
        }
        else if (trimmed.contains('조용한이유:') && currentRec != null) {
          currentRec['quietReason'] = trimmed.split('조용한이유:')[1].trim();
        }
        else if (trimmed.contains('추천활동:') && currentRec != null) {
          currentRec['activity'] = trimmed.split('추천활동:')[1].trim();
        }
        else if (trimmed.contains('방문팁:') && currentRec != null) {
          currentRec['tip'] = trimmed.split('방문팁:')[1].trim();
        }
        else if (trimmed.contains('매칭률:') && currentRec != null) {
          final match = RegExp(r'(\d+)%').firstMatch(trimmed);
          if (match != null) {
            currentRec['matchRate'] = int.tryParse(match.group(1)!) ?? 90;
          }
        }
      }

      // 마지막 추천 처리
      if (currentRec != null && currentRec['title'] != null) {
        final card = await _createRecommendationFromAI(currentRec, laasData);
        if (card != null) recommendations.add(card);
      }

    } catch (e) {
      print('❌ AI 응답 파싱 실패: $e');
    }

    return recommendations;
  }

  /// AI 분석 결과와 LaaS 데이터를 결합하여 추천카드 생성
  static Future<RecommendationCard?> _createRecommendationFromAI(
      Map<String, dynamic> aiRec,
      List<Map<String, dynamic>> laasData,
      ) async {
    try {
      // contentId로 LaaS 데이터 찾기
      final contentId = aiRec['contentId'];
      final laasItem = laasData.firstWhere(
            (item) => item['contentid'] == contentId,
        orElse: () => <String, dynamic>{},
      );

      if (laasItem.isEmpty) {
        print('⚠️ LaaS 데이터를 찾을 수 없음: $contentId');
        return null;
      }

      // 주소 구성
      final addr1 = laasItem['addr1'] ?? '';
      final addr2 = laasItem['addr2'] ?? '';
      final fullAddress = addr2.isNotEmpty ? '$addr1 $addr2' : addr1;

      // 실제 관광지 설명 가져오기
      String description = aiRec['tip'] ?? '추천 관광지입니다.';
      try {
        final detailResponse = await UnifiedLaaSAPIService.getDetailCommon(
          contentId: contentId ?? '',
        );
        final detailItems = UnifiedLaaSAPIService.extractItems(detailResponse);
        if (detailItems != null && detailItems.isNotEmpty) {
          final overview = detailItems.first['overview'] ?? '';
          if (overview.isNotEmpty) {
            description = _cleanDescription(overview);
          }
        }
      } catch (e) {
        print('⚠️ 상세 정보 조회 실패 (AI 추천): ${laasItem['title']} - $e');
        // AI 팁 또는 기본 설명 유지
      }

      return RecommendationCard(
        contentId: contentId ?? '',
        title: laasItem['title'] ?? aiRec['title'] ?? '관광지',
        location: fullAddress,
        description: description,
        rating: 4.2 + (contentId.hashCode % 8) / 10, // 4.2-4.9
        matchPercentage: aiRec['matchRate'] ?? 90,
        congestionLevel: 15 + (contentId.hashCode % 25), // 15-40%
        reason: 'AI가 LaaS 실제 데이터를 분석하여 추천',
        imageUrl: laasItem['firstimage'] ?? '',
        contentTypeId: laasItem['contenttypeid'] ?? '12',
        transportation: _generateTransportationInfo(fullAddress),
        quietReason: aiRec['quietReason'] ?? '한적하고 조용한 환경',
        recommendedActivity: aiRec['activity'] ?? '휴식과 사색에 적합',
        weatherSuitability: _generateWeatherSuitability(laasItem['contenttypeid']),
      );
    } catch (e) {
      print('❌ 추천카드 생성 실패: $e');
      return null;
    }
  }

  /// LaaS 데이터를 직접 추천카드로 변환 (AI 실패시 폴백)
  static Future<List<RecommendationCard>> _convertLaaSToRecommendations(
      List<Map<String, dynamic>> laasData
      ) async {
    final recommendations = <RecommendationCard>[];
    final random = Random();

    // 상위 5개만 추천카드로 변환
    final itemsToConvert = laasData.take(5).toList();

    for (final item in itemsToConvert) {
      try {
        final addr1 = item['addr1'] ?? '';
        final addr2 = item['addr2'] ?? '';
        final fullAddress = addr2.isNotEmpty ? '$addr1 $addr2' : addr1;

        // 상세 정보 가져오기 (overview 포함)
        String description = '멋진 관광지입니다.';
        try {
          final detailResponse = await UnifiedLaaSAPIService.getDetailCommon(
            contentId: item['contentid'] ?? '',
          );
          final detailItems = UnifiedLaaSAPIService.extractItems(detailResponse);
          if (detailItems != null && detailItems.isNotEmpty) {
            final overview = detailItems.first['overview'] ?? '';
            if (overview.isNotEmpty) {
              // HTML 태그 제거 및 길이 제한
              description = _cleanDescription(overview);
            }
          }
        } catch (e) {
          print('⚠️ 상세 정보 조회 실패: ${item['title']} - $e');
          // 기본 설명 유지
        }

        recommendations.add(RecommendationCard(
          contentId: item['contentid'] ?? '',
          title: item['title'] ?? '관광지',
          location: fullAddress,
          description: description,
          rating: 4.0 + random.nextDouble(),
          matchPercentage: 80 + random.nextInt(20),
          congestionLevel: 20 + random.nextInt(30),
          reason: 'LaaS 실제 데이터 기반 추천',
          imageUrl: item['firstimage'] ?? '',
          contentTypeId: item['contenttypeid'] ?? '12',
          transportation: _generateTransportationInfo(fullAddress),
          quietReason: _generateQuietReason(item['contenttypeid']),
          recommendedActivity: _generateRecommendedActivity(item['contenttypeid']),
          weatherSuitability: _generateWeatherSuitability(item['contenttypeid']),
        ));
      } catch (e) {
        print('❌ LaaS 데이터 변환 실패: ${item['title']} - $e');
      }
    }

    return recommendations;
  }

  // ==================== 유틸리티 메서드들 ====================

  static String _getAreaName(String? areaCode) {
    const areaNames = {
      '1': '서울', '2': '인천', '3': '대전', '4': '대구', '5': '광주',
      '6': '부산', '7': '울산', '8': '세종', '31': '경기도', '32': '강원도',
      '33': '충청북도', '34': '충청남도', '35': '경상북도', '36': '경상남도',
      '37': '전라북도', '38': '전라남도', '39': '제주도',
    };
    return areaNames[areaCode] ?? '전국';
  }

  static String _getContentTypeName(String? contentTypeId) {
    const typeNames = {
      '12': '관광지', '14': '문화시설', '15': '축제공연행사', '25': '여행코스',
      '28': '레포츠', '32': '숙박', '38': '쇼핑', '39': '음식점',
    };
    return typeNames[contentTypeId] ?? '모든 유형';
  }

  static String _analyzeUserPreferences(Map<String, dynamic>? preferences) {
    if (preferences == null || preferences.isEmpty) {
      return '조용하고 한적한 장소 선호';
    }

    final List<String> prefList = [];
    preferences.forEach((key, value) {
      if (value != null) prefList.add('$key: $value');
    });

    return prefList.isEmpty ? '조용하고 한적한 장소 선호' : prefList.join(', ');
  }

  static String _generateTransportationInfo(String address) {
    if (address.contains('서울')) return '지하철 및 버스로 접근 가능';
    if (address.contains('부산')) return '부산 지하철 및 시내버스 이용';
    if (address.contains('제주')) return '렌터카 또는 관광버스 이용 권장';
    return '대중교통 또는 자가용으로 접근 가능';
  }

  static String _generateQuietReason(String? contentTypeId) {
    switch (contentTypeId) {
      case '12': return '자연경관이 아름다워 조용한 사색이 가능합니다';
      case '14': return '문화시설로 정숙한 분위기가 유지됩니다';
      case '28': return '야외 활동 공간으로 개방감이 좋습니다';
      case '32': return '편안한 휴식을 위한 조용한 환경입니다';
      default: return '한적하고 평화로운 분위기의 장소입니다';
    }
  }

  static String _generateRecommendedActivity(String? contentTypeId) {
    switch (contentTypeId) {
      case '12': return '산책, 사진촬영, 자연감상';
      case '14': return '문화체험, 전시관람, 학습';
      case '28': return '레포츠 활동, 운동, 체험';
      case '32': return '휴식, 숙박, 재충전';
      case '39': return '맛집 탐방, 현지 음식 체험';
      default: return '관광, 체험, 휴식';
    }
  }

  static String _generateWeatherSuitability(String? contentTypeId) {
    switch (contentTypeId) {
      case '12': return '맑은 날 방문 권장, 우천시 실내 시설 이용';
      case '14': return '실내 시설로 날씨 무관하게 이용 가능';
      case '28': return '야외 활동시 날씨 확인 필요';
      case '32': return '실내 숙박으로 날씨 영향 없음';
      default: return '날씨에 따라 이용 방법 조정 가능';
    }
  }

  /// HTML 태그 제거 및 설명 정리
  static String _cleanDescription(String overview) {
    try {
      // HTML 태그 제거
      String cleaned = overview
          .replaceAll(RegExp(r'<[^>]*>'), '') // HTML 태그 제거
          .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '') // HTML 엔티티 제거
          .replaceAll(RegExp(r'\s+'), ' ') // 연속된 공백을 하나로
          .trim();

      // 길이 제한 (200자)
      if (cleaned.length > 200) {
        cleaned = cleaned.substring(0, 200);

        // 마지막 완전한 문장에서 자르기
        final lastPeriod = cleaned.lastIndexOf('.');
        final lastSpace = cleaned.lastIndexOf(' ');

        if (lastPeriod > 100) {
          cleaned = cleaned.substring(0, lastPeriod + 1);
        } else if (lastSpace > 100) {
          cleaned = cleaned.substring(0, lastSpace) + '...';
        } else {
          cleaned = cleaned + '...';
        }
      }

      return cleaned.isNotEmpty ? cleaned : '멋진 관광지입니다.';
    } catch (e) {
      print('⚠️ 설명 정리 실패: $e');
      return '멋진 관광지입니다.';
    }
  }
  static Stream<String> fetchRecommendationsStream({
    String? areaCode,
    String? sigunguCode,
    String? contentType,
    String? categoryCode,
    Map<String, dynamic>? userPreferences,
  }) async* {
    try {
      // LaaS 데이터 조회
      final laasData = await _fetchLaaSData(
        areaCode: areaCode,
        sigunguCode: sigunguCode,
        contentType: contentType,
        categoryCode: categoryCode,
      );

      if (laasData.isEmpty) {
        yield '조건에 맞는 관광지 데이터를 찾을 수 없습니다.';
        return;
      }

      // AI 프롬프트 생성
      final prompt = _buildAIPrompt(
        laasData: laasData,
        userPreferences: userPreferences,
        areaCode: areaCode,
        contentType: contentType,
      );

      // AI 응답 스트리밍
      final response = await UnifiedLaaSAPIService.callAI(prompt);
      yield response;

    } catch (e) {
      print('❌ 스트리밍 추천 실패: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        yield '네트워크 연결을 확인해주세요.';
      } else {
        yield 'AI 추천 서비스에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }
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
