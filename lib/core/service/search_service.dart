// lib/features/search/services/search_service.dart

import '../../../core/service/tourism_api_service.dart';
import '../../../core/utils/html_utils.dart';

/// 여행지 검색 전용 서비스
class SearchService {

  /// 키워드로 여행지 검색
  static Future<SearchResult> searchPlaces({
    required String keyword,
    String? areaCode,
    String? sigunguCode,
    String? contentTypeId,
    int page = 1,
    int itemsPerPage = 20,
    String arrange = 'A', // A=제목순, C=수정일순, D=생성일순
  }) async {
    try {
      print('🔍 여행지 검색: "$keyword" (페이지: $page)');

      // 키워드가 비어있으면 빈 결과 반환
      if (keyword.trim().isEmpty) {
        return SearchResult(
          places: [],
          keyword: keyword,
          totalCount: 0,
          currentPage: page,
          hasNextPage: false,
          searchTime: DateTime.now(),
        );
      }

      // 관광공사 API 호출
      final apiPlaces = await TourismApiService.searchPlaces(
        keyword: keyword.trim(),
        areaCode: areaCode,
        page: page,
      );

      // SearchPlace로 변환
      final searchPlaces = apiPlaces.map((place) => SearchPlace(
        contentId: place.contentId,
        name: place.name,
        address: place.address,
        description: place.description.isNotEmpty
            ? HtmlUtils.toSingleLine(place.description, maxLength: 150)
            : _generateDefaultDescription(place.name, place.category),
        category: _mapCategoryToKorean(place.category),
        categoryIcon: _getCategoryIcon(place.category),
        areaCode: place.areaCode,
        sigunguCode: place.sigunguCode,
        imageUrl: '', // 기본 API에서는 이미지 URL이 제한적
        latitude: place.latitude,
        longitude: place.longitude,
        isPopular: _checkIfPopular(place.name, place.category),
      )).toList();

      // 검색 결과 정렬 (인기순 우선, 그 다음 이름순)
      searchPlaces.sort((a, b) {
        // 1차: 인기 장소 우선
        if (a.isPopular && !b.isPopular) return -1;
        if (!a.isPopular && b.isPopular) return 1;

        // 2차: 이름순
        return a.name.compareTo(b.name);
      });

      print('✅ 검색 완료: "${keyword}" - ${searchPlaces.length}개 결과');

      return SearchResult(
        places: searchPlaces,
        keyword: keyword,
        totalCount: searchPlaces.length,
        currentPage: page,
        hasNextPage: searchPlaces.length >= itemsPerPage,
        searchTime: DateTime.now(),
      );

    } catch (e) {
      print('❌ 검색 실패: $e');
      return SearchResult(
        places: [],
        keyword: keyword,
        totalCount: 0,
        currentPage: page,
        hasNextPage: false,
        searchTime: DateTime.now(),
        error: '검색 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 인기 검색어 가져오기
  static List<String> getPopularKeywords() {
    return [
      '경복궁',
      '제주도',
      '부산',
      '조용한 카페',
      '도서관',
      '미술관',
      '한옥마을',
      '궁궐',
      '사찰',
      '공원',
      '독서실',
      '명상',
    ];
  }

  /// 추천 검색어 가져오기 (카테고리별)
  static Map<String, List<String>> getRecommendedKeywords() {
    return {
      '문화시설': ['도서관', '미술관', '박물관', '문화센터', '전시관'],
      '관광지': ['궁궐', '한옥마을', '공원', '정원', '전망대'],
      '종교시설': ['사찰', '성당', '교회', '종교센터'],
      '휴식공간': ['조용한 카페', '독서실', '스터디카페', '명상센터'],
      '자연': ['산책로', '호수', '강변', '숲길', '계곡'],
    };
  }

  /// 지역별 추천 검색어
  static Map<String, List<String>> getRegionalKeywords() {
    return {
      '서울': ['경복궁', '창덕궁', '북촌한옥마을', '인사동', '명동'],
      '부산': ['해운대', '광안리', '감천문화마을', '태종대', '용두산공원'],
      '제주': ['한라산', '성산일출봉', '우도', '천지연폭포', '만장굴'],
      '경주': ['불국사', '석굴암', '첨성대', '안압지', '대릉원'],
      '전주': ['한옥마을', '경기전', '오목대', '전동성당'],
    };
  }

  /// 카테고리를 한국어로 변환
  static String _mapCategoryToKorean(String category) {
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

  /// 카테고리별 아이콘 가져오기
  static String _getCategoryIcon(String category) {
    switch (category) {
      case 'tourist_spot':
        return '🏛️';
      case 'culture':
        return '🎨';
      case 'restaurant':
        return '🍽️';
      case 'accommodation':
        return '🏨';
      case 'shopping':
        return '🛍️';
      case 'leisure':
        return '⚽';
      case 'festival':
        return '🎪';
      case 'course':
        return '🗺️';
      default:
        return '📍';
    }
  }

  /// 기본 설명 생성
  static String _generateDefaultDescription(String name, String category) {
    switch (category) {
      case 'culture':
        return '$name - 조용하고 편안한 문화 체험을 즐길 수 있는 공간입니다.';
      case 'tourist_spot':
        return '$name - 아름다운 풍경과 함께 여유로운 시간을 보낼 수 있는 관광지입니다.';
      case 'restaurant':
        return '$name - 맛있는 음식과 함께 편안한 식사를 즐길 수 있는 곳입니다.';
      default:
        return '$name - 조용하고 평화로운 시간을 보낼 수 있는 특별한 장소입니다.';
    }
  }

  /// 인기 장소인지 확인 (키워드 기반)
  static bool _checkIfPopular(String name, String category) {
    // 유명한 장소 키워드들
    final popularKeywords = [
      '경복궁', '창덕궁', '덕수궁', '창경궁', '종묘',
      '국립', '시립', '서울', '부산', '제주',
      '한옥마을', '명동', '인사동', '강남', '홍대',
      '해운대', '광안리', '성산일출봉', '한라산',
      '불국사', '석굴암', '첨성대',
    ];

    final nameLower = name.toLowerCase();
    return popularKeywords.any((keyword) =>
        nameLower.contains(keyword.toLowerCase())
    );
  }
}

// ==================== 모델 클래스들 ====================

/// 검색된 장소 정보
class SearchPlace {
  final String contentId;
  final String name;
  final String address;
  final String description;
  final String category;
  final String categoryIcon;
  final String? areaCode;
  final String? sigunguCode;
  final String imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isPopular;

  const SearchPlace({
    required this.contentId,
    required this.name,
    required this.address,
    required this.description,
    required this.category,
    required this.categoryIcon,
    this.areaCode,
    this.sigunguCode,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    required this.isPopular,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'name': name,
      'address': address,
      'description': description,
      'category': category,
      'categoryIcon': categoryIcon,
      'areaCode': areaCode,
      'sigunguCode': sigunguCode,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isPopular': isPopular,
    };
  }
}

/// 검색 결과
class SearchResult {
  final List<SearchPlace> places;
  final String keyword;
  final int totalCount;
  final int currentPage;
  final bool hasNextPage;
  final DateTime searchTime;
  final String? error;

  const SearchResult({
    required this.places,
    required this.keyword,
    required this.totalCount,
    required this.currentPage,
    required this.hasNextPage,
    required this.searchTime,
    this.error,
  });

  bool get isSuccess => error == null;
  bool get isEmpty => places.isEmpty && isSuccess;
}

/// 검색 필터 옵션
class SearchFilter {
  final String? areaCode;
  final String? sigunguCode;
  final String? category;
  final bool popularOnly;
  final String sortBy; // 'name', 'popular'

  const SearchFilter({
    this.areaCode,
    this.sigunguCode,
    this.category,
    this.popularOnly = false,
    this.sortBy = 'popular',
  });

  SearchFilter copyWith({
    String? areaCode,
    String? sigunguCode,
    String? category,
    bool? popularOnly,
    String? sortBy,
  }) {
    return SearchFilter(
      areaCode: areaCode ?? this.areaCode,
      sigunguCode: sigunguCode ?? this.sigunguCode,
      category: category ?? this.category,
      popularOnly: popularOnly ?? this.popularOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
