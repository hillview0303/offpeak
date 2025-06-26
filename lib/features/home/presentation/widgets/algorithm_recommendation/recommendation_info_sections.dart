import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import '../../../../../core/constants/size.dart';
import '../../../../../core/constants/style.dart';
import '../../../../../core/service/tourism_api_service.dart';
import '../../providers/recommendation_model.dart';

class RecommendationInfoSections extends HookConsumerWidget {
  final RecommendationCard recommendation;
  final bool isTablet;

  const RecommendationInfoSections({
    super.key,
    required this.recommendation,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🆕 Hook 상태 관리 (혼잡도만)
    final congestionData = useState<CongestionData?>(null);
    final isLoadingCongestion = useState<bool>(false);

    // 🆕 혼잡도 데이터 로드 함수
    Future<void> loadCongestionData() async {
      if (recommendation.contentId.isEmpty) {
        congestionData.value = _getDefaultCongestionData(recommendation);
        return;
      }

      isLoadingCongestion.value = true;

      try {
        print('📊 혼잡도 데이터 로드 시작: ${recommendation.title}');

        final congestionResult = await TourismApiService.fetchCongestionData(
          contentId: recommendation.contentId,
          areaCode: _extractAreaCode(recommendation.location),
          sigunguCode: null,
        );

        // API가 이미 CongestionData? 객체를 반환하므로 fromJson() 불필요
        congestionData.value = congestionResult ?? _getDefaultCongestionData(recommendation);
        isLoadingCongestion.value = false;

        print('✅ 혼잡도 데이터 로드 완료: ${congestionData.value?.currentLevel}%');
      } catch (e) {
        print('❌ 혼잡도 데이터 로드 실패: $e');
        congestionData.value = _getDefaultCongestionData(recommendation);
        isLoadingCongestion.value = false;
      }
    }

    // 🆕 초기 데이터 로드 (useEffect)
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadCongestionData();
      });
      return null;
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationInfo(recommendation, isTablet),
        _buildDescription(recommendation, isTablet),
        SizedBox(height: AppSizes.gapS),
        // 🆕 이미지 섹션 제거됨 (메인 카드에서 처리)
        _buildCongestionSection(
          congestionData.value,
          isLoadingCongestion.value,
          isTablet,
        ),
        SizedBox(height: AppSizes.gapS),
      ],
    );
  }

  // ==================== 정적 메서드들 ====================

  /// 기본 혼잡도 데이터 생성 (API 실패 시)
  static CongestionData _getDefaultCongestionData(RecommendationCard recommendation) {
    final seed = recommendation.title.hashCode;
    final random = Random(seed);

    final baseLevel = recommendation.congestionLevel;
    final lastWeek = 80 + random.nextInt(200);
    final expected = (lastWeek * (0.8 + random.nextDouble() * 0.4)).round();

    return CongestionData(
      currentLevel: baseLevel,
      lastWeekVisitors: lastWeek,
      expectedVisitors: expected,
      recommendedTime: _generateRecommendedTime(baseLevel),
      peakTime: _generatePeakTime(baseLevel),
      predictedVisitors: null,
      dataSource: 'default',
    );
  }

  /// 주소에서 지역코드 추출 (간단한 매핑)
  static String? _extractAreaCode(String address) {
    if (address.contains('서울')) return '1';
    if (address.contains('인천')) return '2';
    if (address.contains('대전')) return '3';
    if (address.contains('대구')) return '4';
    if (address.contains('광주')) return '5';
    if (address.contains('부산')) return '6';
    if (address.contains('울산')) return '7';
    if (address.contains('세종')) return '8';
    if (address.contains('경기')) return '31';
    if (address.contains('강원')) return '32';
    if (address.contains('충청북도') || address.contains('충북')) return '33';
    if (address.contains('충청남도') || address.contains('충남')) return '34';
    if (address.contains('경상북도') || address.contains('경북')) return '35';
    if (address.contains('경상남도') || address.contains('경남')) return '36';
    if (address.contains('전라북도') || address.contains('전북')) return '37';
    if (address.contains('전라남도') || address.contains('전남')) return '38';
    if (address.contains('제주')) return '39';
    return null;
  }

  static String _generateRecommendedTime(int level) {
    if (level <= 25) return '지금 방문 추천';
    if (level <= 40) return '오전 9-11시';
    if (level <= 60) return '평일 오후 2-4시';
    return '평일 이른 아침';
  }

  static String _generatePeakTime(int level) {
    if (level <= 30) return '혼잡 시간 없음';
    if (level <= 50) return '주말 오후 1-3시';
    if (level <= 70) return '주말 전체';
    return '주말 및 공휴일';
  }

  // ==================== UI 빌더 메서드들 ====================

  static Widget _buildLocationInfo(RecommendationCard recommendation, bool isTablet) {
    if (recommendation.location.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Color(0xFF888888),
              size: isTablet ? AppSizes.iconM : AppSizes.iconS,
            ),
            SizedBox(width: AppSizes.gapXS + 2),
            Expanded(
              child: Text(
                recommendation.location,
                style: isTablet
                    ? AppTextStyles.bodyMedium.copyWith(color: Color(0xFF888888))
                    : AppTextStyles.bodySmall.copyWith(color: Color(0xFF888888)),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.gapS),
      ],
    );
  }

  static Widget _buildDescription(RecommendationCard recommendation, bool isTablet) {
    return Text(
      recommendation.description.replaceAll(RegExp(r'\*+'), ''),
      style: isTablet
          ? AppTextStyles.bodyLarge.copyWith(color: Color(0xFF666666))
          : AppTextStyles.bodyMedium.copyWith(color: Color(0xFF666666)),
    );
  }

  /// 🆕 실제 혼잡도 정보 섹션
  static Widget _buildCongestionSection(
      CongestionData? congestionData,
      bool isLoadingCongestion,
      bool isTablet,
      ) {
    if (isLoadingCongestion) {
      return _buildLoadingCongestionSection(isTablet);
    }

    if (congestionData == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Padding(
          padding: EdgeInsets.only(bottom: AppSizes.gapXS),
          child: Row(
            children: [
              Text(
                '실시간 혼잡도 정보',
                style: AppTextStyles.caption.copyWith(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (congestionData.dataSource != 'default') ...[
                SizedBox(width: AppSizes.gapXS),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.gapXS,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF7A9B76).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.gapXS),
                  ),
                  child: Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A9B76),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 혼잡도 컨테이너들 (2x2 그리드)
        Row(
          children: [
            Expanded(
              child: _buildCongestionItem(
                icon: _getCongestionIcon(congestionData.currentLevel),
                title: '현재 혼잡도',
                value: '${congestionData.currentLevel}%',
                subtitle: _getCongestionText(congestionData.currentLevel),
                color: _getCongestionColor(congestionData.currentLevel),
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: AppSizes.gapXS),
            Expanded(
              child: _buildCongestionItem(
                icon: Icons.trending_down,
                title: '지난주 방문자',
                value: '${congestionData.lastWeekVisitors}명',
                subtitle: '전주 방문 실적',
                color: Color(0xFF4CAF50),
                isTablet: isTablet,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.gapXS),
        Row(
          children: [
            Expanded(
              child: _buildCongestionItem(
                icon: Icons.schedule,
                title: '추천 시간',
                value: congestionData.recommendedTime,
                subtitle: '최적 방문 시간',
                color: Color(0xFF2196F3),
                isTablet: isTablet,
                isTimeValue: true,
              ),
            ),
            SizedBox(width: AppSizes.gapXS),
            Expanded(
              child: _buildCongestionItem(
                icon: Icons.trending_up,
                title: '이번주 예상',
                value: '${congestionData.expectedVisitors}명',
                subtitle: '예상 방문자',
                color: Color(0xFFFF9800),
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 로딩 중 혼잡도 섹션
  static Widget _buildLoadingCongestionSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: AppSizes.gapXS),
          child: Row(
            children: [
              Text(
                '혼잡도 정보 로딩 중...',
                style: AppTextStyles.caption.copyWith(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: AppSizes.gapXS),
              SizedBox(
                width: 12.0,
                height: 12.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Color(0xFF7A9B76),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 80.0,
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Center(
            child: Text(
              '실시간 데이터 조회 중...',
              style: AppTextStyles.caption.copyWith(
                color: Color(0xFF888888),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 혼잡도 개별 아이템 위젯
  static Widget _buildCongestionItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isTablet,
    bool isTimeValue = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? AppSizes.gapS : 8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘과 제목
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: isTablet ? 16.0 : 14.0,
              ),
              SizedBox(width: AppSizes.gapXS),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 11.0 : 10.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.gapXS),

          // 값
          Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: isTablet
                  ? (isTimeValue ? 10.0 : 12.0)
                  : (isTimeValue ? 9.0 : 11.0),
            ),
            maxLines: isTimeValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),

          // 부제목
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: color.withOpacity(0.7),
              fontSize: isTablet ? 10.0 : 9.0,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== 혼잡도 유틸리티 메서드들 ====================

  static Color _getCongestionColor(int level) {
    if (level <= 25) return Color(0xFF4CAF50); // 초록 - 한적함
    if (level <= 50) return Color(0xFF8BC34A); // 연두 - 보통
    if (level <= 75) return Color(0xFFFF9800); // 주황 - 혼잡
    return Color(0xFFF44336); // 빨강 - 매우 혼잡
  }

  static IconData _getCongestionIcon(int level) {
    if (level <= 25) return Icons.sentiment_very_satisfied;
    if (level <= 50) return Icons.sentiment_satisfied;
    if (level <= 75) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  static String _getCongestionText(int level) {
    if (level <= 25) return '매우 한적';
    if (level <= 50) return '적당함';
    if (level <= 75) return '약간 혼잡';
    return '매우 혼잡';
  }
}
