import 'dart:math';

// 추천 카드 모델
class RecommendationCard {
  final String contentId;
  final String title;
  final String location;
  final String description;
  final double rating;
  final int matchPercentage;
  final int congestionLevel;
  final String reason;
  final String imageUrl;
  final String contentTypeId;
  final String transportation;
  final String quietReason;
  final String recommendedActivity;
  final String weatherSuitability;

  RecommendationCard({
    required this.contentId,
    required this.title,
    required this.location,
    required this.description,
    required this.rating,
    required this.matchPercentage,
    required this.congestionLevel,
    required this.reason,
    required this.imageUrl,
    required this.contentTypeId,
    required this.transportation,
    required this.quietReason,
    required this.recommendedActivity,
    required this.weatherSuitability,
  });

  factory RecommendationCard.fromJson(Map<String, dynamic> json) {
    final random = Random();
    return RecommendationCard(
      contentId: json['contentid'] ?? '',
      title: json['title'] ?? '제목 없음',
      location: '${json['addr1'] ?? ''} ${json['addr2'] ?? ''}'.trim(),
      description: json['overview'] ?? '설명이 없습니다.',
      rating: 4.0 + random.nextDouble(),
      matchPercentage: 70 + random.nextInt(30),
      congestionLevel: 20 + random.nextInt(60),
      reason: _generateReason(json['contenttypeid']),
      imageUrl: json['firstimage'] ?? '',
      contentTypeId: json['contenttypeid'] ?? '12',
      transportation: '대중교통 이용 가능',
      quietReason: '자연 속 한적한 위치',
      recommendedActivity: '조용한 산책과 사색',
      weatherSuitability: '날씨 무관하게 방문 가능',
    );
  }

  static String _generateReason(String? contentTypeId) {
    final reasons = {
      '12': '자연을 좋아하는 당신에게 완벽한 장소',
      '14': '문화적 경험을 원하는 당신의 취향',
      '15': '새로운 경험을 추구하는 성향',
      '25': '체계적인 여행을 선호하는 스타일',
      '28': '활동적인 여행을 즐기는 성향',
      '32': '편안한 휴식을 원하는 당신',
      '39': '미식 여행을 좋아하는 취향',
    };
    return reasons[contentTypeId] ?? '당신의 여행 스타일에 맞는 장소';
  }

  // copyWith 메서드 (상태 변경시 유용)
  RecommendationCard copyWith({
    String? contentId,
    String? title,
    String? location,
    String? description,
    double? rating,
    int? matchPercentage,
    int? congestionLevel,
    String? reason,
    String? imageUrl,
    String? contentTypeId,
    String? transportation,
    String? quietReason,
    String? recommendedActivity,
    String? weatherSuitability,
  }) {
    return RecommendationCard(
      contentId: contentId ?? this.contentId,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      congestionLevel: congestionLevel ?? this.congestionLevel,
      reason: reason ?? this.reason,
      imageUrl: imageUrl ?? this.imageUrl,
      contentTypeId: contentTypeId ?? this.contentTypeId,
      transportation: transportation ?? this.transportation,
      quietReason: quietReason ?? this.quietReason,
      recommendedActivity: recommendedActivity ?? this.recommendedActivity,
      weatherSuitability: weatherSuitability ?? this.weatherSuitability,
    );
  }

  // JSON 변환 (찜 목록 로컬 저장시 유용)
  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'title': title,
      'location': location,
      'description': description,
      'rating': rating,
      'matchPercentage': matchPercentage,
      'congestionLevel': congestionLevel,
      'reason': reason,
      'imageUrl': imageUrl,
      'contentTypeId': contentTypeId,
      'transportation': transportation,
      'quietReason': quietReason,
      'recommendedActivity': recommendedActivity,
      'weatherSuitability': weatherSuitability,
    };
  }

  // JSON에서 객체 생성 (로컬 저장된 찜 목록 불러올 때 사용)
  factory RecommendationCard.fromStoredJson(Map<String, dynamic> json) {
    return RecommendationCard(
      contentId: json['contentId'] ?? '',
      title: json['title'] ?? '제목 없음',
      location: json['location'] ?? '',
      description: json['description'] ?? '설명이 없습니다.',
      rating: (json['rating'] ?? 4.0).toDouble(),
      matchPercentage: json['matchPercentage'] ?? 0,
      congestionLevel: json['congestionLevel'] ?? 50,
      reason: json['reason'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      contentTypeId: json['contentTypeId'] ?? '12',
      transportation: json['transportation'] ?? '대중교통 이용 가능',
      quietReason: json['quietReason'] ?? '자연 속 한적한 위치',
      recommendedActivity: json['recommendedActivity'] ?? '조용한 산책과 사색',
      weatherSuitability: json['weatherSuitability'] ?? '날씨 무관하게 방문 가능',
    );
  }

  // 고유 ID 반환 (찜 기능에서 사용)
  String get id => contentId;

  // 동등성 비교 (contentId 기준)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationCard && other.contentId == contentId;
  }

  @override
  int get hashCode => contentId.hashCode;

  @override
  String toString() {
    return 'RecommendationCard(contentId: $contentId, title: $title, location: $location)';
  }
}
