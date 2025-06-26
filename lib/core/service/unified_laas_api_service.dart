import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// LaaS AI API 전용 서비스 - 핵심 기능만
class UnifiedLaaSAPIService {
  // LaaS AI API URL
  static const String _laasApiUrl = 'https://api-laas.wanted.co.kr/api/preset/v2/chat/completions';

  // Timeout 설정
  static const Duration _aiTimeout = Duration(seconds: 45);

  // ==================== 환경변수 Getters ====================

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

  // ==================== 핵심 LaaS API 메서드들 ====================

  /// 기본 LaaS AI API 호출
  static Future<String> callAI(String prompt) async {
    print('🤖 LaaS AI API 호출: $prompt');

    try {
      final projectCode = _laasProjectCode;
      final apiKey = _laasApiKey;
      final hash = _laasHash;

      // 헤더 설정
      final headers = {
        'project': projectCode,
        'apiKey': apiKey,
        'Content-Type': 'application/json; charset=utf-8',
      };

      // 요청 본문
      final requestBody = {
        'hash': hash,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ],
      };

      // HTTP 요청 실행
      final response = await http.post(
        Uri.parse(_laasApiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(_aiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 응답 파싱
        String? content;

        // OpenAI 스타일 응답 파싱
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          final message = choice['message'];
          if (message != null && message['content'] != null) {
            content = message['content'].toString();
          }
        }

        // 다른 형식 확인
        content ??= data['result']?.toString() ??
            data['response']?.toString() ??
            data['content']?.toString();

        if (content != null && content.isNotEmpty) {
          print('✅ AI 응답 성공');
          return content;
        }

        throw LaaSException('빈 응답을 받았습니다.');

      } else {
        throw LaaSException('AI API 오류: ${response.statusCode} - ${response.body}');
      }

    } catch (e) {
      print('❌ AI API 호출 실패: $e');
      rethrow;
    }
  }

  /// 최초 인사 메시지 받아오기
  static Future<String> getWelcomeMessage() async {
    print('👋 환영 메시지 요청 중...');

    try {
      final welcomeMessage = await callAI('안녕하세요! 처음 만나는 사용자에게 인사해주세요.');
      print('✅ 환영 메시지 받아옴');
      return welcomeMessage;
    } catch (e) {
      print('❌ 환영 메시지 실패, 기본 메시지 사용: $e');
      // 기본 메시지 반환
      return '안녕하세요! 조용한 여행지를 추천해드리는 AI 여행 챗봇입니다. 궁금하신 조용한 여행지나 다른 정보가 있다면 언제든지 말씀해 주세요! 😊\n\n위치 기반 추천을 원하시면 "내 주변 맛집 추천해줘" 같이 물어보세요!';
    }
  }

  /// 컨텍스트와 함께 AI 호출 (외부 데이터 포함)
  static Future<String> callAIWithContext({
    required String userMessage,
    String? additionalContext,
  }) async {
    print('🤖 컨텍스트 기반 AI API 호출');

    try {
      // 프롬프트 구성
      String prompt = userMessage;

      // 추가 컨텍스트가 있으면 포함
      if (additionalContext != null && additionalContext.isNotEmpty) {
        print('📍 추가 컨텍스트 포함');

        prompt = '''사용자 질문: $userMessage

추가 정보:
$additionalContext

위 정보를 참고해서 사용자의 질문에 구체적이고 실용적인 답변을 해주세요.''';
      }

      return await callAI(prompt);

    } catch (e) {
      print('❌ 컨텍스트 기반 AI API 호출 실패: $e');
      rethrow;
    }
  }

  /// AI API 연결 테스트
  static Future<bool> checkConnection() async {
    try {
      print('🔍 AI 연결 확인...');
      final result = await callAI('테스트');
      return result.isNotEmpty;
    } catch (e) {
      print('❌ AI 연결 실패: $e');
      return false;
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
