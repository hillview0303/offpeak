import 'dart:convert';
import 'dart:math';
import '../../features/home/presentation/providers/recommendation_model.dart';
import 'tourism_api_service.dart'; // 새로운 서비스 import

/// 내 주변 장소 추천 서비스 - 관광공사 API 직접 사용으로 개선
class NearbyService {

  /// 카테고리별 주변 장소 추천 (거리순 20개씩) - 관광공사 API 직접 사용
  /// [latitude] - 위도
  /// [longitude] - 경도
  /// [category] - 카테고리 ('전체', '관광지', '문화시설', '카페', '음식점', '숙박', '레포츠', '쇼핑')
  /// [pages] - 페이지 번호 (1부터 시작)
  static Future<List<NearbyPlace>> fetchNearbyPlacesByCategory({
    required double latitude,
    required double longitude,
    String category = '전체',
    int page = 1,
  }) async {
    try {
      print('🔍 [NearbyService] 카테고리별 장소 검색: $category (페이지 $page)');

      // ⭐ TourismApiService 직접 사용 - 빠르고 안정적
      final places = await TourismApiService.fetchNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        category: category,
        page: page,
        radius: _getRadiusByPage(page), // 페이지별 반경 조정
      );

      // 거리순 정렬 (이미 API에서 정렬되지만 확실히)
      places.sort((a, b) {
        final distanceA = _parseDistanceKm(a.distance);
        final distanceB = _parseDistanceKm(b.distance);
        return distanceA.compareTo(distanceB);
      });

      print('✅ [NearbyService] $category 카테고리 ${places.length}개 장소 반환 (페이지 $page)');

      if (places.isNotEmpty) {
        final minDistance = _parseDistanceKm(places.first.distance);
        final maxDistance = _parseDistanceKm(places.last.distance);
        print('📏 거리 범위: ${minDistance.toStringAsFixed(1)}km ~ ${maxDistance.toStringAsFixed(1)}km');
      }

      return places;

    } catch (e) {
      print('❌ [NearbyService] 카테고리별 장소 조회 실패: $e');

      if (e is TourismApiException) {
        rethrow;
      }

      // 네트워크 오류 확인
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('ClientException')) {
        throw NearbyServiceException('인터넷 연결을 확인해주세요. 네트워크가 불안정합니다.');
      }

      throw NearbyServiceException('$category 장소 검색 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 초기 주변 장소 로딩 (카테고리별 첫 20개)
  static Future<List<NearbyPlace>> fetchInitialNearbyPlaces({
    required double latitude,
    required double longitude,
    String category = '전체',
  }) async {
    return fetchNearbyPlacesByCategory(
      latitude: latitude,
      longitude: longitude,
      category: category,
      page: 1,
    );
  }

  /// 추가 주변 장소 로딩 (무한 스크롤용)
  static Future<List<NearbyPlace>> fetchMoreNearbyPlaces({
    required double latitude,
    required double longitude,
    String category = '전체',
    required int nextPage,
  }) async {
    return fetchNearbyPlacesByCategory(
      latitude: latitude,
      longitude: longitude,
      category: category,
      page: nextPage,
    );
  }

  /// 카테고리별 추천 장소 (지역명 기반)
  static Future<List<NearbyPlace>> fetchPlacesByCategory({
    required String category,
    String location = '부산광역시',
  }) async {
    try {
      print('🔍 [NearbyService] 카테고리별 장소 검색: $category in $location');

      final areaCode = _getAreaCodeFromLocation(location);

      // ⭐ TourismApiService 사용
      final places = await TourismApiService.fetchPlacesByCategory(
        category: category,
        areaCode: areaCode,
      );

      if (places.isEmpty) {
        throw NearbyServiceException('$location에서 ${_getCategoryText(category)}를 찾을 수 없습니다.');
      }

      return places;
    } catch (e) {
      print('❌ [NearbyService] 카테고리별 장소 조회 실패: $e');

      if (e is NearbyServiceException || e is TourismApiException) {
        rethrow;
      }

      throw NearbyServiceException('$category 검색 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 장소 상세 정보 조회
  static Future<NearbyPlaceDetail> fetchPlaceDetail({
    required String placeName,
    required String contentId,
  }) async {
    try {
      print('📋 [NearbyService] 장소 상세 정보 조회: $placeName (ID: $contentId)');

      // ⭐ TourismApiService 사용
      final detail = await TourismApiService.fetchPlaceDetail(contentId);

      if (detail == null) {
        throw NearbyServiceException('$placeName의 상세 정보를 찾을 수 없습니다.');
      }

      return NearbyPlaceDetail(
        name: detail.name,
        location: detail.location,
        hours: detail.hours,
        phone: detail.phone,
        facilities: detail.facilities,
        fee: detail.fee,
        parking: detail.parking,
        transport: detail.transport,
        special: detail.special,
        recommendedTime: detail.recommendedTime,
      );

    } catch (e) {
      print('❌ [NearbyService] 장소 상세 정보 조회 실패: $e');

      if (e is NearbyServiceException || e is TourismApiException) {
        rethrow;
      }

      throw NearbyServiceException('$placeName의 상세 정보를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  /// 장소 이미지 조회
  static Future<List<String>> fetchPlaceImages(String contentId) async {
    try {
      print('🖼️ [NearbyService] 장소 이미지 조회: $contentId');

      // ⭐ TourismApiService 사용
      final images = await TourismApiService.fetchPlaceImages(contentId);

      print('✅ [NearbyService] ${images.length}개 이미지 조회 완료');
      return images;

    } catch (e) {
      print('❌ [NearbyService] 이미지 조회 실패: $e');
      return [];
    }
  }

  /// 🆕 장소 혼잡도 정보 조회
  static Future<CongestionData?> fetchPlaceCongestion({
    required String contentId,
    String? areaCode,
    String? sigunguCode,
  }) async {
    try {
      print('📊 [NearbyService] 혼잡도 정보 조회: $contentId');

      // ⭐ TourismApiService 사용
      final congestionData = await TourismApiService.fetchCongestionData(
        contentId: contentId,
        areaCode: areaCode,
        sigunguCode: sigunguCode,
      );

      if (congestionData != null) {
        print('✅ [NearbyService] 혼잡도 조회 완료: ${congestionData.currentLevel}%');
      }
      return congestionData;

    } catch (e) {
      print('❌ [NearbyService] 혼잡도 조회 실패: $e');
      return null;
    }
  }

  /// 키워드 검색
  static Future<List<NearbyPlace>> searchPlaces({
    required String keyword,
    String? location,
  }) async {
    try {
      print('🔍 [NearbyService] 키워드 검색: $keyword');

      final areaCode = location != null ? _getAreaCodeFromLocation(location) : null;

      // ⭐ TourismApiService 사용
      final places = await TourismApiService.searchPlaces(
        keyword: keyword,
        areaCode: areaCode,
      );

      print('✅ [NearbyService] "$keyword" 검색 결과 ${places.length}개');
      return places;

    } catch (e) {
      print('❌ [NearbyService] 키워드 검색 실패: $e');

      if (e is TourismApiException) {
        rethrow;
      }

      throw NearbyServiceException('검색 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // ==================== 유틸리티 메서드들 ====================

  /// 페이지별 검색 반경 조정 (점진적 확대)
  static int _getRadiusByPage(int page) {
    switch (page) {
      case 1:
        return 2000;   // 2km
      case 2:
        return 5000;   // 5km
      case 3:
        return 10000;  // 10km
      case 4:
        return 15000;  // 15km
      default:
        return 20000;  // 20km
    }
  }

  /// 위치명으로 지역코드 추정
  static String? _getAreaCodeFromLocation(String location) {
    if (location.contains('부산')) return '6';
    if (location.contains('서울')) return '1';
    if (location.contains('인천')) return '2';
    if (location.contains('대전')) return '3';
    if (location.contains('대구')) return '4';
    if (location.contains('광주')) return '5';
    if (location.contains('울산')) return '7';
    if (location.contains('세종')) return '8';
    if (location.contains('경기')) return '31';
    if (location.contains('강원')) return '32';
    if (location.contains('충북')) return '33';
    if (location.contains('충남')) return '34';
    if (location.contains('경북')) return '35';
    if (location.contains('경남')) return '36';
    if (location.contains('전북')) return '37';
    if (location.contains('전남')) return '38';
    if (location.contains('제주')) return '39';
    return null;
  }

  /// 카테고리 텍스트 변환
  static String _getCategoryText(String category) {
    switch (category) {
      case '관광지':
      case '문화시설':
      case '축제공연행사':
      case '여행코스':
      case '레포츠':
      case '숙박':
      case '쇼핑':
      case '음식점':
        return category;
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
      default:
        return '장소';
    }
  }

  /// 거리 문자열에서 km 값 추출
  static double _parseDistanceKm(String distanceText) {
    final kmRegex = RegExp(r'(\d+\.?\d*)km');
    final kmMatch = kmRegex.firstMatch(distanceText);
    if (kmMatch != null) {
      return double.tryParse(kmMatch.group(1)!) ?? 999.0;
    }

    // 도보 시간을 km로 변환 (20분 = 1km)
    final walkRegex = RegExp(r'도보 (\d+)분');
    final walkMatch = walkRegex.firstMatch(distanceText);
    if (walkMatch != null) {
      final minutes = int.tryParse(walkMatch.group(1)!) ?? 999;
      return minutes / 20.0;
    }

    return 999.0; // 기본값
  }
}

/// 주변 장소 상세 정보 모델 (기존과 동일)
class NearbyPlaceDetail {
  final String name;
  final String location;
  final String hours;
  final String phone;
  final String facilities;
  final String fee;
  final String parking;
  final String transport;
  final String special;
  final String recommendedTime;

  const NearbyPlaceDetail({
    required this.name,
    required this.location,
    required this.hours,
    required this.phone,
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
      'hours': hours,
      'phone': phone,
      'facilities': facilities,
      'fee': fee,
      'parking': parking,
      'transport': transport,
      'special': special,
      'recommendedTime': recommendedTime,
    };
  }

  factory NearbyPlaceDetail.fromJson(Map<String, dynamic> json) {
    return NearbyPlaceDetail(
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      hours: json['hours'] ?? '',
      phone: json['phone'] ?? '',
      facilities: json['facilities'] ?? '',
      fee: json['fee'] ?? '',
      parking: json['parking'] ?? '',
      transport: json['transport'] ?? '',
      special: json['special'] ?? '',
      recommendedTime: json['recommendedTime'] ?? '',
    );
  }
}

/// 내 주변 서비스 예외 클래스
class NearbyServiceException implements Exception {
  final String message;
  NearbyServiceException(this.message);

  @override
  String toString() => message;
}
