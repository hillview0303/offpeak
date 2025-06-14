import 'package:flutter/material.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';

class AlgorithmRecommendationPage extends StatefulWidget {
  const AlgorithmRecommendationPage({super.key});

  @override
  State<AlgorithmRecommendationPage> createState() => _AlgorithmRecommendationPageState();
}

class _AlgorithmRecommendationPageState extends State<AlgorithmRecommendationPage> {
  bool _isLoading = false;
  final List<RecommendationCard> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AI 맞춤 추천',
          style: AppTextStyles.appBarTitle,
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        leading: IconButton(
          onPressed: () => NavigationService.instance.goBack(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterDialog();
            },
            icon: Icon(
              Icons.tune,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _recommendations.isEmpty
          ? _buildEmptyState()
          : _buildRecommendationList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadRecommendations,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.refresh),
        label: Text(
          '새로운 추천',
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: AppSizes.gapL),
          Text(
            'AI가 당신만을 위한\n특별한 장소를 찾고 있어요...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.gapL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.gapXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: AppSizes.iconXL * 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppSizes.gapL),
            Text(
              '아직 추천할 장소가 없어요',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              '새로운 추천 버튼을 눌러서\nAI 추천을 받아보세요!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationList() {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.gapM),
      itemCount: _recommendations.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapM),
      itemBuilder: (context, index) {
        return _buildRecommendationCard(_recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(RecommendationCard recommendation) {
    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          // 장소 상세 페이지로 이동
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusL),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.place,
                      size: AppSizes.iconXL * 2,
                      color: AppColors.white,
                    ),
                  ),
                  Positioned(
                    top: AppSizes.gapM,
                    right: AppSizes.gapM,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTag('AI 추천', AppColors.secondary),
                        SizedBox(width: AppSizes.gapS),
                        _buildTag('${recommendation.matchPercentage}% 일치', AppColors.success),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 내용 영역
            Padding(
              padding: EdgeInsets.all(AppSizes.gapL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 평점
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recommendation.title,
                          style: AppTextStyles.h3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSizes.gapS),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: AppSizes.iconS,
                          ),
                          SizedBox(width: AppSizes.gapXS),
                          Text(
                            recommendation.rating.toStringAsFixed(1),
                            style: AppTextStyles.numberSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.gapS),

                  // 위치
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: AppSizes.iconS,
                      ),
                      SizedBox(width: AppSizes.gapXS),
                      Expanded(
                        child: Text(
                          recommendation.location,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.gapM),

                  // 설명
                  Text(
                    recommendation.description,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.gapM),

                  // 추천 이유
                  Container(
                    padding: EdgeInsets.all(AppSizes.gapM),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primary,
                              size: AppSizes.iconS,
                            ),
                            SizedBox(width: AppSizes.gapS),
                            Text(
                              '추천 이유',
                              style: AppTextStyles.labelBold.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSizes.gapS),
                        Text(
                          recommendation.reason,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSizes.gapM),

                  // 액션 버튼들
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // 찜하기
                          },
                          icon: Icon(
                            Icons.favorite_border,
                            size: AppSizes.iconS,
                          ),
                          label: Text('찜하기'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.gapM),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 상세 보기
                          },
                          icon: Icon(
                            Icons.info_outline,
                            size: AppSizes.iconS,
                          ),
                          label: Text('상세 보기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.gapS,
        vertical: AppSizes.gapXS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.white,
          fontWeight: AppTextStyles.medium,
        ),
      ),
    );
  }

  void _loadRecommendations() {
    setState(() {
      _isLoading = true;
      _recommendations.clear();
    });

    // API 호출 시뮬레이션
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
        _recommendations.addAll(_generateSampleRecommendations());
      });
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('추천 필터', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('필터 옵션을 선택하세요', style: AppTextStyles.bodyMedium),
            // 여기에 필터 옵션들 추가
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadRecommendations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('적용'),
          ),
        ],
      ),
    );
  }

  List<RecommendationCard> _generateSampleRecommendations() {
    return [
      RecommendationCard(
        title: '해운대 해변',
        location: '부산광역시 해운대구',
        description: '한국에서 가장 유명한 해변 중 하나로, 아름다운 백사장과 다양한 해양 액티비티를 즐길 수 있는 곳입니다.',
        rating: 4.5,
        matchPercentage: 95,
        reason: '당신이 선호하는 해변 여행과 수상 스포츠 활동에 완벽하게 맞는 장소입니다.',
      ),
      RecommendationCard(
        title: '감천문화마을',
        location: '부산광역시 사하구',
        description: '컬러풀한 집들이 계단식으로 이어진 독특한 마을로, 예술과 문화가 어우러진 특별한 공간입니다.',
        rating: 4.3,
        matchPercentage: 87,
        reason: '당신이 좋아하는 문화 예술 체험과 사진 촬영 명소를 찾는 성향에 적합합니다.',
      ),
      RecommendationCard(
        title: '태종대',
        location: '부산광역시 영도구',
        description: '절벽과 바다가 만나는 절경을 감상할 수 있는 자연 관광지로, 등대와 전망대가 유명합니다.',
        rating: 4.4,
        matchPercentage: 82,
        reason: '자연 경관을 좋아하고 하이킹을 즐기는 당신의 취향에 맞는 장소입니다.',
      ),
    ];
  }
}

class RecommendationCard {
  final String title;
  final String location;
  final String description;
  final double rating;
  final int matchPercentage;
  final String reason;

  RecommendationCard({
    required this.title,
    required this.location,
    required this.description,
    required this.rating,
    required this.matchPercentage,
    required this.reason,
  });
}
