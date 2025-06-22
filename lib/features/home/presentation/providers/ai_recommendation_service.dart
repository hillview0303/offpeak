import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'recommendation_model.dart';

class AIRecommendationService {
  static Future<List<RecommendationCard>> fetchRecommendations({
    String? areaCode,
    String? contentType,
  }) async {
    try {
      final aiResponse = await _fetchAIRecommendations(areaCode, contentType);
      final recommendations = _parseAIRecommendationsToCards(aiResponse);
      return recommendations;
    } catch (e) {
      print('Error in fetchRecommendations: $e');
      throw e;
    }
  }

  static Future<String> _fetchAIRecommendations(String? areaCode, String? contentType) async {
    try {
      final projectCode = dotenv.env['LAAS_PROJECT_CODE'];
      final apiKey = dotenv.env['LAAS_API_KEY'];
      final hash = dotenv.env['LAAS_HASH'];

      if (projectCode == null || apiKey == null || hash == null) {
        throw Exception('.env 파일 설정을 확인해주세요.');
      }

      const String apiUrl = 'https://api-laas.wanted.co.kr/api/preset/v2/chat/completions';
      final url = Uri.parse(apiUrl);

      String locationFilter = areaCode != null ? _getAreaName(areaCode) : '전국';
      String typeFilter = contentType != null ? _getContentTypeName(contentType) : '모든 유형';

      // 컨텐츠 타입에 따라 다른 프롬프트 사용
      String prompt = _buildPrompt(locationFilter, typeFilter, contentType);

      final headers = {
        'project': projectCode,
        'apiKey': apiKey,
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': 'Flutter App',
        'Accept': 'application/json',
      };

      final requestBody = {
        'hash': hash,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ]
      };

      final client = http.Client();

      try {
        final response = await client.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            final choice = data['choices'][0];
            if (choice['message'] != null && choice['message']['content'] != null) {
              return choice['message']['content'];
            }
          }
        }

        throw Exception('AI 응답을 받을 수 없습니다.');

      } finally {
        client.close();
      }

    } catch (e) {
      throw e;
    }
  }

  static String _buildPrompt(String locationFilter, String typeFilter, String? contentType) {
    if (contentType == '39') { // 음식점
      return '''
당신은 한국의 맛집 전문 AI입니다. $locationFilter 지역의 조용하고 분위기 좋은 음식점을 추천해주세요.

3곳에서 5곳 사이로 추천해주세요. 각 추천지에 대해 반드시 아래 형식을 정확히 따라 답변해주세요:

1. 장소명: [정확한 음식점 이름]
2. 상세주소: [전체 주소 - 예: 서울특별시 종로구 사직로 161]
3. 혼잡도: [20-60% 사이 숫자]%
4. 조용한이유: [분위기가 좋고 조용한 이유 1-2문장]
5. 설명: [음식 종류, 대표 메뉴, 분위기 등 2-3문장]
6. 추천활동: [조용한 식사, 대화, 데이트 등 구체적 활동]
7. 가는방법: [대중교통/자가용 기준 소요시간 포함하여 1-2문장]
8. 날씨영향: [실내/야외 좌석, 날씨별 적합성]
9. 매칭률: [85-99 사이 숫자]%

---

실제 존재하는 $locationFilter의 분위기 좋은 음식점만 추천해주세요.
''';
    } else if (contentType == '32') { // 숙박
      return '''
당신은 한국의 조용한 숙박시설 전문 AI입니다. $locationFilter 지역의 한적하고 편안한 숙박시설을 추천해주세요.

3곳에서 5곳 사이로 추천해주세요. 각 추천지에 대해 반드시 아래 형식을 정확히 따라 답변해주세요:

1. 장소명: [정확한 숙박시설 이름]
2. 상세주소: [전체 주소]
3. 혼잡도: [15-50% 사이 숫자]%
4. 조용한이유: [한적하고 조용한 이유 1-2문장]
5. 설명: [숙박시설 종류, 특징, 시설 등 2-3문장]
6. 추천활동: [휴식, 독서, 온천, 산책 등 구체적 활동]
7. 가는방법: [대중교통/자가용 기준 소요시간 포함하여 1-2문장]
8. 날씨영향: [실내 시설, 날씨별 적합성]
9. 매칭률: [85-99 사이 숫자]%

---

실제 존재하는 $locationFilter의 조용하고 편안한 숙박시설만 추천해주세요.
''';
    } else { // 기본 - 조용한 여행지
      return '''
당신은 한국의 조용하고 한적한 여행지 전문 AI입니다.

사용자는 조용하고 한적한 여행지를 찾고 있습니다.
주변 소음이 적고, 혼잡도가 낮으며, 접근성이 좋은 여행지를 추천해주세요.

지역 조건: $locationFilter
여행 유형: $typeFilter

3곳에서 5곳 사이로 추천해주세요. 각 추천지에 대해 반드시 아래 형식을 정확히 따라 답변해주세요:

1. 장소명: [정확한 관광지 이름]
2. 상세주소: [전체 주소 - 예: 서울특별시 종로구 사직로 161]
3. 혼잡도: [10-40% 사이 낮은 숫자]%
4. 조용한이유: [혼잡도가 낮고 조용한 이유 1-2문장]
5. 설명: [풍경, 분위기, 방문 추천 시기 등 2-3문장]
6. 추천활동: [조용한 산책로, 독서 가능한 공간, 명상 등 구체적 활동]
7. 가는방법: [대중교통/자가용 기준 소요시간 포함하여 1-2문장]
8. 날씨영향: [비/눈/바람 등 날씨 조건에서의 적합성]
9. 매칭률: [85-99 사이 숫자]%

---

실제 존재하는 한국의 조용하고 한적한 여행지만 추천해주세요.
''';
    }
  }

  static List<RecommendationCard> _parseAIRecommendationsToCards(String aiResponse) {
    final recommendations = <RecommendationCard>[];

    try {
      final lines = aiResponse.split('\n');
      Map<String, dynamic>? currentPlace;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed == '---') continue;

        // 새로운 장소 시작 감지
        if (trimmed.contains('장소명:')) {
          if (currentPlace != null && currentPlace['name'] != null) {
            recommendations.add(_createRecommendationCard(currentPlace));
          }
          currentPlace = <String, dynamic>{};
          currentPlace['name'] = trimmed.split('장소명:')[1].trim();
        }
        else if ((trimmed.contains('위치:') || trimmed.contains('상세주소:')) && currentPlace != null) {
          final addressPart = trimmed.contains('상세주소:')
              ? trimmed.split('상세주소:')[1].trim()
              : trimmed.split('위치:')[1].trim();
          currentPlace!['location'] = addressPart;
        }
        else if (trimmed.contains('설명:') && currentPlace != null) {
          currentPlace!['description'] = trimmed.split('설명:')[1].trim();
        }
        else if (trimmed.contains('추천이유:') && currentPlace != null) {
          currentPlace!['reason'] = trimmed.split('추천이유:')[1].trim();
        }
        else if (trimmed.contains('가는방법:') && currentPlace != null) {
          currentPlace!['transportation'] = trimmed.split('가는방법:')[1].trim();
        }
        else if (trimmed.contains('조용한이유:') && currentPlace != null) {
          currentPlace!['quietReason'] = trimmed.split('조용한이유:')[1].trim();
        }
        else if (trimmed.contains('추천활동:') && currentPlace != null) {
          currentPlace!['recommendedActivity'] = trimmed.split('추천활동:')[1].trim();
        }
        else if (trimmed.contains('날씨영향:') && currentPlace != null) {
          currentPlace!['weatherSuitability'] = trimmed.split('날씨영향:')[1].trim();
        }
        else if (trimmed.contains('혼잡도:') && currentPlace != null) {
          final match = RegExp(r'(\d+)%').firstMatch(trimmed);
          if (match != null) {
            currentPlace!['congestionLevel'] = int.tryParse(match.group(1)!) ?? 25;
          }
        }
        else if (trimmed.contains('매칭률:') && currentPlace != null) {
          final match = RegExp(r'(\d+)%').firstMatch(trimmed);
          if (match != null) {
            currentPlace!['matchRate'] = int.tryParse(match.group(1)!) ?? 90;
          }
        }
      }

      // 마지막 장소 추가
      if (currentPlace != null && currentPlace['name'] != null) {
        recommendations.add(_createRecommendationCard(currentPlace));
      }

    } catch (e) {
      print('Error parsing AI recommendations: $e');
    }

    return recommendations;
  }

  static RecommendationCard _createRecommendationCard(Map<String, dynamic> place) {
    final random = Random();

    return RecommendationCard(
      contentId: random.nextInt(1000000).toString(),
      title: place['name'] ?? '추천 장소',
      location: place['location'] ?? '',
      description: place['description'] ?? '멋진 여행지입니다.',
      rating: 4.0 + random.nextDouble(),
      matchPercentage: place['matchRate'] ?? (75 + random.nextInt(25)),
      congestionLevel: place['congestionLevel'] ?? (30 + random.nextInt(40)),
      reason: place['reason'] ?? 'AI가 선별한 특별한 장소',
      imageUrl: '',
      contentTypeId: '12',
      transportation: place['transportation'] ?? '대중교통으로 접근 가능',
      quietReason: place['quietReason'] ?? '한적하고 조용한 환경',
      recommendedActivity: place['recommendedActivity'] ?? '휴식과 사색에 적합',
      weatherSuitability: place['weatherSuitability'] ?? '날씨 무관하게 방문 가능',
    );
  }

  static String _getAreaName(String areaCode) {
    const areaNames = {
      '1': '서울', '2': '인천', '3': '대전', '4': '대구', '5': '광주',
      '6': '부산', '7': '울산', '8': '세종', '31': '경기도', '32': '강원도',
      '33': '충청북도', '34': '충청남도', '35': '경상북도', '36': '경상남도',
      '37': '전라북도', '38': '전라남도', '39': '제주도',
    };
    return areaNames[areaCode] ?? '전국';
  }

  static String _getContentTypeName(String contentTypeId) {
    const typeNames = {
      '12': '관광지', '14': '문화시설', '15': '축제공연행사', '25': '여행코스',
      '28': '레포츠', '32': '숙박', '39': '음식점',
    };
    return typeNames[contentTypeId] ?? '모든 유형';
  }
}
