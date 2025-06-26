import 'dart:math';

/// AI 추천 카드 모델
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

  const RecommendationCard({
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

  /// 복사 생성자
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

  /// JSON 직렬화
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

  /// JSON 역직렬화
  factory RecommendationCard.fromJson(Map<String, dynamic> json) {
    return RecommendationCard(
      contentId: json['contentId'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 4.0).toDouble(),
      matchPercentage: json['matchPercentage'] ?? 85,
      congestionLevel: json['congestionLevel'] ?? 25,
      reason: json['reason'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      contentTypeId: json['contentTypeId'] ?? '12',
      transportation: json['transportation'] ?? '',
      quietReason: json['quietReason'] ?? '',
      recommendedActivity: json['recommendedActivity'] ?? '',
      weatherSuitability: json['weatherSuitability'] ?? '',
    );
  }

  @override
  String toString() {
    return 'RecommendationCard(title: $title, matchPercentage: $matchPercentage%, congestionLevel: $congestionLevel%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationCard &&
        other.contentId == contentId;
  }

  @override
  int get hashCode => contentId.hashCode;
}

/// 🆕 혼잡도 데이터 모델 (tourism_api_service.dart에서 import하는 대신 여기서 정의)
class CongestionData {
  final int currentLevel; // 현재 혼잡도 (%)
  final int lastWeekVisitors; // 지난주 방문자수
  final int expectedVisitors; // 예상 방문자수
  final String recommendedTime; // 추천 시간
  final String peakTime; // 피크 시간
  final int? predictedVisitors; // 예측 방문자수 (선택사항)
  final String dataSource; // 데이터 출처

  const CongestionData({
    required this.currentLevel,
    required this.lastWeekVisitors,
    required this.expectedVisitors,
    required this.recommendedTime,
    required this.peakTime,
    this.predictedVisitors,
    required this.dataSource,
  });

  CongestionData copyWith({
    int? currentLevel,
    int? lastWeekVisitors,
    int? expectedVisitors,
    String? recommendedTime,
    String? peakTime,
    int? predictedVisitors,
    String? dataSource,
  }) {
    return CongestionData(
      currentLevel: currentLevel ?? this.currentLevel,
      lastWeekVisitors: lastWeekVisitors ?? this.lastWeekVisitors,
      expectedVisitors: expectedVisitors ?? this.expectedVisitors,
      recommendedTime: recommendedTime ?? this.recommendedTime,
      peakTime: peakTime ?? this.peakTime,
      predictedVisitors: predictedVisitors ?? this.predictedVisitors,
      dataSource: dataSource ?? this.dataSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLevel': currentLevel,
      'lastWeekVisitors': lastWeekVisitors,
      'expectedVisitors': expectedVisitors,
      'recommendedTime': recommendedTime,
      'peakTime': peakTime,
      'predictedVisitors': predictedVisitors,
      'dataSource': dataSource,
    };
  }

  factory CongestionData.fromJson(Map<String, dynamic> json) {
    return CongestionData(
      currentLevel: json['currentLevel'] ?? 25,
      lastWeekVisitors: json['lastWeekVisitors'] ?? 100,
      expectedVisitors: json['expectedVisitors'] ?? 120,
      recommendedTime: json['recommendedTime'] ?? '언제든지',
      peakTime: json['peakTime'] ?? '주말 오후',
      predictedVisitors: json['predictedVisitors'],
      dataSource: json['dataSource'] ?? 'default',
    );
  }

  @override
  String toString() {
    return 'CongestionData(currentLevel: $currentLevel%, source: $dataSource)';
  }
}
