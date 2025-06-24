import 'package:flutter/material.dart';

/// 카테고리 관련 유틸리티 클래스
class CategoryUtils {

  /// 카테고리별 색상 매핑
  static Map<String, Color> getCategoryColors(String category) {
    switch (category) {
      case 'tourist_spot':
        return {
          'background': Color(0xFFE8F5E8), // 연한 녹색 배경
          'icon': Color(0xFF4CAF50),       // 녹색 아이콘
          'tag': Color(0xFFE8F5E8),        // 연한 녹색 태그 배경
          'tagText': Color(0xFF2E7D32),    // 진한 녹색 텍스트
        };
      case 'culture':
        return {
          'background': Color(0xFFF3E5F5), // 연한 보라색 배경
          'icon': Color(0xFF9C27B0),       // 보라색 아이콘
          'tag': Color(0xFFF3E5F5),        // 연한 보라색 태그 배경
          'tagText': Color(0xFF6A1B9A),    // 진한 보라색 텍스트
        };
      case 'cafe':
        return {
          'background': Color(0xFFFFF3E0), // 연한 오렌지 배경
          'icon': Color(0xFFFF9800),       // 오렌지 아이콘
          'tag': Color(0xFFFFF3E0),        // 연한 오렌지 태그 배경
          'tagText': Color(0xFFE65100),    // 진한 오렌지 텍스트
        };
      case 'restaurant':
        return {
          'background': Color(0xFFFFEBEE), // 연한 빨간색 배경
          'icon': Color(0xFFF44336),       // 빨간색 아이콘
          'tag': Color(0xFFFFEBEE),        // 연한 빨간색 태그 배경
          'tagText': Color(0xFFC62828),    // 진한 빨간색 텍스트
        };
      case 'accommodation':
        return {
          'background': Color(0xFFE3F2FD), // 연한 파란색 배경
          'icon': Color(0xFF2196F3),       // 파란색 아이콘
          'tag': Color(0xFFE3F2FD),        // 연한 파란색 태그 배경
          'tagText': Color(0xFF1565C0),    // 진한 파란색 텍스트
        };
      case 'leisure':
        return {
          'background': Color(0xFFF1F8E9), // 연한 라이트 그린 배경
          'icon': Color(0xFF8BC34A),       // 라이트 그린 아이콘
          'tag': Color(0xFFF1F8E9),        // 연한 라이트 그린 태그 배경
          'tagText': Color(0xFF558B2F),    // 진한 라이트 그린 텍스트
        };
      case 'shopping':
        return {
          'background': Color(0xFFFCE4EC), // 연한 핑크 배경
          'icon': Color(0xFFE91E63),       // 핑크 아이콘
          'tag': Color(0xFFFCE4EC),        // 연한 핑크 태그 배경
          'tagText': Color(0xFFC2185B),    // 진한 핑크 텍스트
        };
      case 'festival':
        return {
          'background': Color(0xFFFFF8E1), // 연한 노란색 배경
          'icon': Color(0xFFFFC107),       // 노란색 아이콘
          'tag': Color(0xFFFFF8E1),        // 연한 노란색 태그 배경
          'tagText': Color(0xFFF57F17),    // 진한 노란색 텍스트
        };
      case 'course':
        return {
          'background': Color(0xFFEDE7F6), // 연한 인디고 배경
          'icon': Color(0xFF673AB7),       // 인디고 아이콘
          'tag': Color(0xFFEDE7F6),        // 연한 인디고 태그 배경
          'tagText': Color(0xFF4527A0),    // 진한 인디고 텍스트
        };
      default:
        return {
          'background': Color(0xFFF5F5F5), // 연한 회색 배경
          'icon': Color(0xFF757575),       // 회색 아이콘
          'tag': Color(0xFFF5F5F5),        // 연한 회색 태그 배경
          'tagText': Color(0xFF424242),    // 진한 회색 텍스트
        };
    }
  }

  /// 카테고리별 아이콘 매핑
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'tourist_spot':
        return Icons.landscape;
      case 'culture':
        return Icons.museum;
      case 'cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'accommodation':
        return Icons.hotel;
      case 'leisure':
        return Icons.sports_soccer;
      case 'shopping':
        return Icons.shopping_bag;
      case 'festival':
        return Icons.celebration;
      case 'course':
        return Icons.route;
      default:
        return Icons.place;
    }
  }

  /// 카테고리별 이모지 매핑
  static String getCategoryEmoji(String category) {
    switch (category) {
      case 'tourist_spot':
        return '🏔️';
      case 'culture':
        return '🎭';
      case 'cafe':
        return '☕';
      case 'restaurant':
        return '🍽️';
      case 'accommodation':
        return '🏨';
      case 'leisure':
        return '🏃';
      case 'shopping':
        return '🛍️';
      case 'festival':
        return '🎉';
      case 'course':
        return '🗺️';
      default:
        return '📍';
    }
  }

  /// 카테고리별 표시 텍스트 매핑
  static String getCategoryDisplayText(String category) {
    switch (category) {
      case 'tourist_spot':
        return '관광지';
      case 'culture':
        return '문화시설';
      case 'cafe':
        return '카페';
      case 'restaurant':
        return '음식점';
      case 'accommodation':
        return '숙박';
      case 'leisure':
        return '레포츠';
      case 'shopping':
        return '쇼핑';
      case 'festival':
        return '축제/행사';
      case 'course':
        return '여행코스';
      default:
        return '기타';
    }
  }

  /// 카테고리 필터용 데이터 생성
  static List<Map<String, String>> getCategoryFilterData() {
    return [
      {'value': '전체', 'label': '전체', 'icon': '🗺️'},
      {'value': '관광지', 'label': '관광지', 'icon': '🏔️'},
      {'value': '문화시설', 'label': '문화시설', 'icon': '🎭'},
      {'value': '카페', 'label': '카페', 'icon': '☕'},
      {'value': '음식점', 'label': '음식점', 'icon': '🍽️'},
      {'value': '숙박', 'label': '숙박', 'icon': '🏨'},
      {'value': '레포츠', 'label': '레포츠', 'icon': '🏃'},
      {'value': '쇼핑', 'label': '쇼핑', 'icon': '🛍️'},
    ];
  }
}
