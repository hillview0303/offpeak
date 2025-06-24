import 'package:flutter/material.dart';

class QuietActivitiesUtils {
  QuietActivitiesUtils._();

  static const List<String> _titles = [
    '도서관 투어',
    '미술관 관람',
    '조용한 카페',
    '산책로 걷기',
    '명상 공간',
  ];

  static const List<String> _subtitles = [
    'Indoor',
    'Indoor',
    'Indoor',
    'Outdoor',
    'Indoor',
  ];

  static const List<LinearGradient> _gradients = [
    // 차분한 올리브 그린
    LinearGradient(
      colors: [Color(0xFF8FA68E), Color(0xFFA4BAA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 부드러운 베이지
    LinearGradient(
      colors: [Color(0xFFB8A082), Color(0xFFC8B299)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 차분한 라벤더 그레이
    LinearGradient(
      colors: [Color(0xFF9B96A6), Color(0xFFAFA9B8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 따뜻한 더스티 로즈
    LinearGradient(
      colors: [Color(0xFFA08A8A), Color(0xFFB39C9C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // 은은한 세이지 그린
    LinearGradient(
      colors: [Color(0xFF8B9A8B), Color(0xFF9FAD9F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static const List<IconData> _icons = [
    Icons.library_books,
    Icons.palette,
    Icons.coffee,
    Icons.nature_people,
    Icons.self_improvement,
  ];

  /// 인덱스에 해당하는 활동 제목을 반환합니다.
  static String getActivityTitle(int index) {
    return _titles[index % _titles.length];
  }

  /// 인덱스에 해당하는 활동 부제목을 반환합니다.
  static String getActivitySubtitle(int index) {
    return _subtitles[index % _subtitles.length];
  }

  /// 인덱스에 해당하는 활동 그라디언트를 반환합니다.
  static LinearGradient getActivityGradient(int index) {
    return _gradients[index % _gradients.length];
  }

  /// 인덱스에 해당하는 활동 아이콘을 반환합니다.
  static IconData getActivityIcon(int index) {
    return _icons[index % _icons.length];
  }

  /// 제목으로 인덱스를 찾습니다.
  static int getIndexByTitle(String title) {
    return _titles.indexOf(title);
  }

  /// 전체 활동 개수를 반환합니다.
  static int get activityCount => _titles.length;

  /// 활동 데이터 모델을 반환합니다.
  static QuietActivityData getActivityData(int index) {
    return QuietActivityData(
      title: getActivityTitle(index),
      subtitle: getActivitySubtitle(index),
      gradient: getActivityGradient(index),
      icon: getActivityIcon(index),
    );
  }
}

/// 조용한 활동 데이터 모델
class QuietActivityData {
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;

  const QuietActivityData({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });
}
