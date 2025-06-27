// lib/core/utils/html_utils.dart

/// HTML 태그 및 엔티티 처리 유틸리티
class HtmlUtils {

  /// HTML 태그와 엔티티를 제거하고 깔끔한 텍스트로 변환
  ///
  /// [html] - 정리할 HTML 문자열
  /// [preserveLineBreaks] - 줄바꿈 유지 여부 (기본값: true)
  /// [maxLength] - 최대 길이 제한 (null이면 제한 없음)
  ///
  /// Returns: 정리된 텍스트
  static String cleanHtml(
      String html, {
        bool preserveLineBreaks = true,
        int? maxLength,
      }) {
    if (html.isEmpty) return '';

    try {
      String cleaned = html;

      if (preserveLineBreaks) {
        // HTML 태그를 적절한 줄바꿈으로 변환
        cleaned = cleaned
            .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n') // <br> → 줄바꿈
            .replaceAll(RegExp(r'<BR\s*/?>', caseSensitive: false), '\n') // <BR> → 줄바꿈 (명시적 추가)
            .replaceAll(RegExp(r'<p\s*/?>', caseSensitive: false), '\n') // <p> → 줄바꿈
            .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n') // </p> → 줄바꿈
            .replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '\n') // <div> → 줄바꿈
            .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n') // </div> → 줄바꿈
            .replaceAll(RegExp(r'<h[1-6][^>]*>', caseSensitive: false), '\n') // <h1-6> → 줄바꿈
            .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n') // </h1-6> → 줄바꿈
            .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ') // <li> → 불릿
            .replaceAll(RegExp(r'</li>', caseSensitive: false), '') // </li> 제거
            .replaceAll(RegExp(r'<ul[^>]*>|</ul>', caseSensitive: false), '\n') // <ul> → 줄바꿈
            .replaceAll(RegExp(r'<ol[^>]*>|</ol>', caseSensitive: false), '\n'); // <ol> → 줄바꿈
      }

      // 모든 HTML 태그 제거 (대소문자 구분하지 않음)
      cleaned = cleaned.replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), '');

      // HTML 엔티티 변환
      cleaned = cleaned
          .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ') // &nbsp; → 공백
          .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<') // &lt; → <
          .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>') // &gt; → >
          .replaceAll(RegExp(r'&amp;', caseSensitive: false), '&') // &amp; → &
          .replaceAll(RegExp(r'&quot;', caseSensitive: false), '"') // &quot; → "
          .replaceAll(RegExp(r'&apos;', caseSensitive: false), "'") // &apos; → '
          .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
        // 숫자 HTML 엔티티 변환 (예: &#8211; → –)
        try {
          final charCode = int.parse(match.group(1)!);
          return String.fromCharCode(charCode);
        } catch (e) {
          return match.group(0)!;
        }
      })
          .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), ''); // 기타 HTML 엔티티 제거

      if (preserveLineBreaks) {
        // 연속된 줄바꿈과 공백 정리
        cleaned = cleaned
            .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n') // 3개 이상 줄바꿈 → 2개로
            .replaceAll(RegExp(r'^\s+|\s+$'), '') // 앞뒤 공백 제거
            .replaceAll(RegExp(r'[ \t]+'), ' '); // 연속된 공백을 하나로
      } else {
        // 줄바꿈도 공백으로 변환
        cleaned = cleaned
            .replaceAll(RegExp(r'\s+'), ' ') // 모든 공백문자를 하나의 공백으로
            .trim();
      }

      // 길이 제한 적용
      if (maxLength != null && cleaned.length > maxLength) {
        cleaned = '${cleaned.substring(0, maxLength).trim()}...';
      }

      return cleaned.trim();
    } catch (e) {
      print('⚠️ HTML 정리 중 오류: $e');
      return html; // 실패 시 원본 반환
    }
  }

  /// HTML 텍스트를 한 줄 요약으로 변환 (줄바꿈 제거)
  ///
  /// [html] - 정리할 HTML 문자열
  /// [maxLength] - 최대 길이 (기본값: 100)
  ///
  /// Returns: 한 줄 요약 텍스트
  static String toSingleLine(String html, {int maxLength = 100}) {
    return cleanHtml(
      html,
      preserveLineBreaks: false,
      maxLength: maxLength,
    );
  }

  /// HTML 텍스트를 여러 줄 텍스트로 변환 (줄바꿈 유지)
  ///
  /// [html] - 정리할 HTML 문자열
  /// [maxLength] - 최대 길이 (null이면 제한 없음)
  ///
  /// Returns: 여러 줄 텍스트
  static String toMultiLine(String html, {int? maxLength}) {
    return cleanHtml(
      html,
      preserveLineBreaks: true,
      maxLength: maxLength,
    );
  }

  /// 간단한 HTML 태그만 제거 (빠른 처리용)
  ///
  /// [html] - 정리할 HTML 문자열
  ///
  /// Returns: 태그만 제거된 텍스트
  static String removeTagsOnly(String html) {
    if (html.isEmpty) return '';

    return html
        .replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'&[a-zA-Z0-9#]+;'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// HTML 엔티티만 디코딩
  ///
  /// [text] - 디코딩할 텍스트
  ///
  /// Returns: 디코딩된 텍스트
  static String decodeEntities(String text) {
    if (text.isEmpty) return '';

    return text
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<')
        .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>')
        .replaceAll(RegExp(r'&amp;', caseSensitive: false), '&')
        .replaceAll(RegExp(r'&quot;', caseSensitive: false), '"')
        .replaceAll(RegExp(r'&apos;', caseSensitive: false), "'")
        .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      try {
        final charCode = int.parse(match.group(1)!);
        return String.fromCharCode(charCode);
      } catch (e) {
        return match.group(0)!;
      }
    });
  }

  /// 텍스트가 HTML을 포함하는지 확인
  ///
  /// [text] - 확인할 텍스트
  ///
  /// Returns: HTML 포함 여부
  static bool containsHtml(String text) {
    if (text.isEmpty) return false;

    return RegExp(r'<[^>]+>').hasMatch(text) ||
        RegExp(r'&[a-zA-Z0-9#]+;').hasMatch(text);
  }
}
