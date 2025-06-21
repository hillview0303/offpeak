import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/constants/color.dart';
import '../../../../core/constants/size.dart';
import '../../../../core/constants/style.dart';
import '../../../../core/router/navigation_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

// 추천 카드 모델
class RecommendationCard {
  final String contentId;
  final String title;
  final String location;
  final String description;
  final double rating;
  final int matchPercentage;
  final int congestionLevel; // 혼잡도 추가
  final String reason;
  final String imageUrl;
  final String contentTypeId;

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
  });

  factory RecommendationCard.fromJson(Map<String, dynamic> json) {
    final random = Random();
    return RecommendationCard(
      contentId: json['contentid'] ?? '',
      title: json['title'] ?? '제목 없음',
      location: '${json['addr1'] ?? ''} ${json['addr2'] ?? ''}'.trim(),
      description: json['overview'] ?? '설명이 없습니다.',
      rating: 4.0 + random.nextDouble(), // 4.0~5.0 사이 랜덤 평점
      matchPercentage: 70 + random.nextInt(30), // 70~99% 매칭률
      congestionLevel: 20 + random.nextInt(60), // 20~79% 혼잡도
      reason: _generateReason(json['contenttypeid']),
      imageUrl: json['firstimage'] ?? '',
      contentTypeId: json['contenttypeid'] ?? '12',
    );
  }

  static String _generateReason(String? contentTypeId) {
    final reasons = {
      '12': '당신이 선호하는 관광지 유형과 완벽하게 일치하는 장소입니다.',
      '14': '문화예술을 좋아하는 당신의 취향에 맞는 특별한 공간입니다.',
      '15': '축제와 이벤트를 즐기는 당신에게 추천하는 행사입니다.',
      '25': '코스 여행을 선호하는 당신에게 적합한 여행 루트입니다.',
      '28': '레포츠 활동을 좋아하는 당신의 성향에 맞는 장소입니다.',
      '32': '편안한 숙박을 원하는 당신에게 추천하는 곳입니다.',
      '39': '맛있는 음식을 찾는 당신의 입맛에 맞는 맛집입니다.',
    };
    return reasons[contentTypeId] ?? '당신의 여행 스타일에 맞는 추천 장소입니다.';
  }
}

// State Providers
final recommendationsProvider = StateProvider<List<RecommendationCard>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final selectedAreaCodeProvider = StateProvider<String?>((ref) => null);
final selectedContentTypeProvider = StateProvider<String?>((ref) => null);
final userPreferencesProvider = StateProvider<String>((ref) => '');

class AlgorithmRecommendationPage extends HookConsumerWidget {
  const AlgorithmRecommendationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(recommendationsProvider);
    final isLoading = ref.watch(isLoadingProvider);

    useEffect(() {
      // 페이지 로드시 자동으로 추천 데이터 로드
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAIRecommendations(ref);
      });
      return null;
    }, []);

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
              _showFilterDialog(context, ref);
            },
            icon: Icon(
              Icons.tune,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : recommendations.isEmpty
          ? _buildEmptyState()
          : _buildRecommendationList(recommendations),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : () => _loadAIRecommendations(ref),
        backgroundColor: isLoading ? AppColors.textSecondary : AppColors.primary,
        foregroundColor: AppColors.white,
        icon: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            strokeWidth: 2,
          ),
        )
            : const Icon(Icons.auto_awesome),
        label: Text(
          'AI 새 추천',
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
            'AI가 당신의 취향을 분석하여\n맞춤 여행지를 추천하고 있어요...',
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
              'AI 추천을 받을 준비가 되었어요',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.gapM),
            Text(
              'AI 새 추천 버튼을 눌러서\n개인화된 여행지를 찾아보세요!',
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

  Widget _buildRecommendationList(List<RecommendationCard> recommendations) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.gapM),
      itemCount: recommendations.length,
      separatorBuilder: (context, index) => SizedBox(height: AppSizes.gapM),
      itemBuilder: (context, index) {
        return _buildRecommendationCard(context, recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(BuildContext context, RecommendationCard recommendation) {
    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: () {
          // 장소 상세 페이지로 이동
          // NavigationService.instance.pushNamed('/detail', arguments: recommendation.contentId);
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
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusL),
                ),
              ),
              child: Stack(
                children: [
                  // 실제 이미지 또는 기본 배경
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppSizes.radiusL),
                    ),
                    child: recommendation.imageUrl.isNotEmpty
                        ? Image.network(
                      recommendation.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
                    )
                        : _buildDefaultImage(),
                  ),
                  // 오버레이
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppSizes.radiusL),
                      ),
                    ),
                  ),
                  // 태그들
                  Positioned(
                    top: AppSizes.gapM,
                    right: AppSizes.gapM,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTag('AI 추천', AppColors.secondary),
                            SizedBox(width: AppSizes.gapS),
                            _buildTag('${recommendation.matchPercentage}% 일치', AppColors.success),
                          ],
                        ),
                        SizedBox(height: AppSizes.gapS),
                        _buildTag(
                            '혼잡도 ${recommendation.congestionLevel}%',
                            _getCongestionColor(recommendation.congestionLevel)
                        ),
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
                  if (recommendation.location.isNotEmpty) ...[
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
                  ],

                  // 설명
                  Text(
                    recommendation.description,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.gapM),

                  // AI 추천 이유
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
                              Icons.psychology,
                              color: AppColors.primary,
                              size: AppSizes.iconS,
                            ),
                            SizedBox(width: AppSizes.gapS),
                            Text(
                              'AI 추천 이유',
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
                            // 찜하기 기능
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${recommendation.title}을(를) 찜했습니다!')),
                            );
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
                            // NavigationService.instance.pushNamed('/detail', arguments: recommendation.contentId);
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

  Widget _buildDefaultImageWithDebug(String title) {
    print('🖼️ 기본 이미지 표시: $title (API에서 이미지를 찾지 못함)');
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.place,
              size: AppSizes.iconXL * 1.5,
              color: AppColors.white,
            ),
            SizedBox(height: AppSizes.gapS),
            Text(
              '이미지 없음',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.place,
          size: AppSizes.iconXL * 2,
          color: AppColors.white,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
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

  Color _getCongestionColor(int congestionLevel) {
    if (congestionLevel <= 30) {
      return Colors.green; // 여유
    } else if (congestionLevel <= 60) {
      return Colors.orange; // 보통
    } else {
      return Colors.red; // 혼잡
    }
  }

  void _loadAIRecommendations(WidgetRef ref) async {
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(recommendationsProvider.notifier).state = [];

    try {
      // 1. LaaS AI를 통해 추천 장소 리스트 생성
      final aiRecommendations = await _fetchAIRecommendations(ref);
      print('AI Response: $aiRecommendations'); // 디버깅용

      // 2. AI 추천을 파싱하여 RecommendationCard 리스트 생성
      final recommendations = await _parseAIRecommendationsToCards(aiRecommendations);

      if (recommendations.isNotEmpty) {
        ref.read(recommendationsProvider.notifier).state = recommendations;
      } else {
        // AI 파싱 실패시에만 샘플 데이터 사용
        print('AI 파싱 실패, 샘플 데이터 사용');
        ref.read(recommendationsProvider.notifier).state = _generateSampleRecommendations();
      }
    } catch (e) {
      print('Error loading AI recommendations: $e');
      // AI 호출 실패시에만 샘플 데이터 사용
      ref.read(recommendationsProvider.notifier).state = _generateSampleRecommendations();
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<String> _fetchAIRecommendations(WidgetRef ref) async {
    try {
      final projectCode = dotenv.env['LAAS_PROJECT_CODE'];
      final apiKey = dotenv.env['LAAS_API_KEY'];
      final hash = dotenv.env['LAAS_HASH'];

      if (projectCode == null || apiKey == null || hash == null) {
        throw Exception('.env 파일 설정을 확인해주세요.');
      }

      const String apiUrl = 'https://api-laas.wanted.co.kr/api/preset/v2/chat/completions';
      final url = Uri.parse(apiUrl);

      final selectedAreaCode = ref.read(selectedAreaCodeProvider);
      final selectedContentType = ref.read(selectedContentTypeProvider);

      // 지역과 콘텐츠 타입을 기반으로 AI 프롬프트 구성
      String locationFilter = selectedAreaCode != null ? _getAreaName(selectedAreaCode) : '전국';
      String typeFilter = selectedContentType != null ? _getContentTypeName(selectedContentType) : '모든 유형';

      final prompt = '''
당신은 한국 여행 전문 AI입니다. 다음 조건에 맞는 한국의 여행지를 5곳 추천해주세요:

조건:
- 지역: $locationFilter
- 유형: $typeFilter
- 개인화된 맞춤 추천

각 추천지에 대해 다음 형식으로 답변해주세요:
1. 장소명: [정확한 관광지 이름]
2. 위치: [시/도 + 구/군]  
3. 설명: [2-3문장으로 간단한 설명]
4. 추천이유: [개인화된 추천 이유 1문장]
5. 매칭률: [70-99 사이 숫자]%
6. 혼잡도: [20-80 사이 숫자]%

---
[다음 장소]

실제 존재하는 한국의 유명 관광지만 추천해주세요.
각 장소는 구체적이고 방문 가능한 실제 장소여야 합니다.
''';

      final headers = {
        'project': projectCode,
        'apiKey': apiKey,
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': 'Flutter App',
        'Accept': 'application/json',
      };

      final requestBody = {
        'hash': hash,
        'messages': [
          {
            'role': 'user',
            'content': prompt,
          }
        ]
      };

      final client = http.Client();

      try {
        final response = await client.post(
          url,
          headers: headers,
          body: jsonEncode(requestBody),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            final choice = data['choices'][0];
            if (choice['message'] != null && choice['message']['content'] != null) {
              return choice['message']['content'];
            }
          }
        }

        throw Exception('AI 응답을 받을 수 없습니다.');

      } finally {
        client.close();
      }

    } catch (e) {
      print('Error fetching AI recommendations: $e');
      throw e;
    }
  }

  List<RecommendationCard> _parseAIRecommendationsToCards(String aiResponse) {
    final recommendations = <RecommendationCard>[];

    try {
      final lines = aiResponse.split('\n');
      Map<String, dynamic>? currentPlace;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        // 새로운 장소 시작 감지
        if (trimmed.contains('장소명:') || trimmed.startsWith('1.') || trimmed.startsWith('2.') ||
            trimmed.startsWith('3.') || trimmed.startsWith('4.') || trimmed.startsWith('5.')) {

          // 이전 장소 정보가 있으면 카드로 변환하여 추가
          if (currentPlace != null && currentPlace['name'] != null) {
            recommendations.add(_createRecommendationCard(currentPlace));
          }

          currentPlace = {};

          // 장소명 추출
          if (trimmed.contains('장소명:')) {
            currentPlace['name'] = trimmed.split('장소명:')[1].trim();
          } else {
            // 숫자로 시작하는 경우 (예: "1. 해운대 해변")
            final nameMatch = RegExp(r'^\d+\.\s*(.+)').firstMatch(trimmed);
            if (nameMatch != null) {
              currentPlace['name'] = nameMatch.group(1)!.trim();
            }
          }
        }
        else if (trimmed.contains('위치:') && currentPlace != null) {
          currentPlace['location'] = trimmed.split('위치:')[1].trim();
        }
        else if (trimmed.contains('설명:') && currentPlace != null) {
          currentPlace['description'] = trimmed.split('설명:')[1].trim();
        }
        else if (trimmed.contains('추천이유:') && currentPlace != null) {
          currentPlace['reason'] = trimmed.split('추천이유:')[1].trim();
        }
        else if (trimmed.contains('매칭률:') && currentPlace != null) {
          final match = RegExp(r'(\d+)%').firstMatch(trimmed);
          if (match != null) {
            currentPlace['matchRate'] = int.tryParse(match.group(1)!) ?? 85;
          }
        }
        else if (trimmed.contains('혼잡도:') && currentPlace != null) {
          final match = RegExp(r'(\d+)%').firstMatch(trimmed);
          if (match != null) {
            currentPlace['congestionLevel'] = int.tryParse(match.group(1)!) ?? 40;
          }
        }
        else if (trimmed.contains('이미지:') && currentPlace != null) {
          final imageUrl = trimmed.split('이미지:')[1].trim();
          if (imageUrl.isNotEmpty && imageUrl != '공백' && imageUrl.startsWith('http')) {
            currentPlace['imageUrl'] = imageUrl;
          }
        }
        // 번호 없이 연속으로 나오는 경우도 처리
        else if (currentPlace != null) {
          if (currentPlace['description'] == null && trimmed.isNotEmpty && !trimmed.contains(':')) {
            currentPlace['description'] = trimmed;
          }
        }
      }

      // 마지막 장소 추가
      if (currentPlace != null && currentPlace['name'] != null) {
        recommendations.add(_createRecommendationCard(currentPlace));
      }

      print('파싱된 추천 장소 수: ${recommendations.length}'); // 디버깅용

    } catch (e) {
      print('Error parsing AI recommendations: $e');
    }

    return recommendations;
  }

  RecommendationCard _createRecommendationCard(Map<String, dynamic> place) {
    final random = Random();

    return RecommendationCard(
      contentId: random.nextInt(1000000).toString(),
      title: place['name'] ?? '추천 장소',
      location: place['location'] ?? '',
      description: place['description'] ?? '멋진 여행지입니다.',
      rating: 4.0 + random.nextDouble(), // 4.0-5.0
      matchPercentage: place['matchRate'] ?? (75 + random.nextInt(25)), // 75-99%
      congestionLevel: place['congestionLevel'] ?? (30 + random.nextInt(40)), // 30-69%
      reason: place['reason'] ?? 'AI가 당신의 취향에 맞게 선별한 특별한 장소입니다.',
      imageUrl: place['imageUrl'] ?? '', // AI가 제공한 이미지 URL 사용
      contentTypeId: '12',
    );
  }

  String _getAreaName(String areaCode) {
    const areaNames = {
      '1': '서울',
      '2': '인천',
      '3': '대전',
      '4': '대구',
      '5': '광주',
      '6': '부산',
      '7': '울산',
      '8': '세종',
      '31': '경기도',
      '32': '강원도',
      '33': '충청북도',
      '34': '충청남도',
      '35': '경상북도',
      '36': '경상남도',
      '37': '전라북도',
      '38': '전라남도',
      '39': '제주도',
    };
    return areaNames[areaCode] ?? '전국';
  }

  String _getContentTypeName(String contentTypeId) {
    const typeNames = {
      '12': '관광지',
      '14': '문화시설',
      '15': '축제공연행사',
      '25': '여행코스',
      '28': '레포츠',
      '32': '숙박',
      '39': '음식점',
    };
    return typeNames[contentTypeId] ?? '모든 유형';
  }

  List<RecommendationCard> _generateSampleRecommendations() {
    return [
      RecommendationCard(
        contentId: '126508',
        title: '해운대 해변',
        location: '부산광역시 해운대구',
        description: '한국에서 가장 유명한 해변 중 하나로, 아름다운 백사장과 다양한 해양 액티비티를 즐길 수 있는 곳입니다.',
        rating: 4.5,
        matchPercentage: 95,
        congestionLevel: 65,
        reason: 'AI가 분석한 당신의 여행 패턴에 따르면, 해변 휴양과 도시 문화를 함께 즐기는 스타일에 완벽하게 맞습니다.',
        imageUrl: 'https://images.unsplash.com/photo-1544966503-7cc536d9f2c9?w=500',
        contentTypeId: '12',
      ),
      RecommendationCard(
        contentId: '126549',
        title: '감천문화마을',
        location: '부산광역시 사하구',
        description: '컬러풀한 집들이 계단식으로 이어진 독특한 마을로, 예술과 문화가 어우러진 특별한 공간입니다.',
        rating: 4.3,
        matchPercentage: 87,
        congestionLevel: 42,
        reason: 'AI가 당신의 SNS 활동과 사진 선호도를 분석한 결과, 독특한 건축물과 포토존을 좋아하는 성향과 일치합니다.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=500',
        contentTypeId: '12',
      ),
      RecommendationCard(
        contentId: '126565',
        title: '태종대',
        location: '부산광역시 영도구',
        description: '절벽과 바다가 만나는 절경을 감상할 수 있는 자연 관광지로, 등대와 전망대가 유명합니다.',
        rating: 4.4,
        matchPercentage: 82,
        congestionLevel: 28,
        reason: 'AI가 분석한 당신의 이전 여행 기록에 따르면, 자연 경관과 하이킹을 즐기는 패턴과 매우 유사합니다.',
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=500',
        contentTypeId: '12',
      ),
    ];
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final selectedAreaCode = ref.read(selectedAreaCodeProvider);
    final selectedContentType = ref.read(selectedContentTypeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI 추천 필터', style: AppTextStyles.h3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI가 더 정확한 추천을 할 수 있도록 선호사항을 알려주세요',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: AppSizes.gapL),
              Text('선호 지역', style: AppTextStyles.labelBold),
              SizedBox(height: AppSizes.gapS),
              DropdownButtonFormField<String>(
                value: selectedAreaCode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: AppSizes.gapS),
                  hintText: '전체 지역',
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('전체 지역')),
                  DropdownMenuItem(value: '1', child: Text('서울')),
                  DropdownMenuItem(value: '2', child: Text('인천')),
                  DropdownMenuItem(value: '3', child: Text('대전')),
                  DropdownMenuItem(value: '4', child: Text('대구')),
                  DropdownMenuItem(value: '5', child: Text('광주')),
                  DropdownMenuItem(value: '6', child: Text('부산')),
                  DropdownMenuItem(value: '7', child: Text('울산')),
                  DropdownMenuItem(value: '8', child: Text('세종')),
                  DropdownMenuItem(value: '31', child: Text('경기도')),
                  DropdownMenuItem(value: '32', child: Text('강원도')),
                  DropdownMenuItem(value: '33', child: Text('충청북도')),
                  DropdownMenuItem(value: '34', child: Text('충청남도')),
                  DropdownMenuItem(value: '35', child: Text('경상북도')),
                  DropdownMenuItem(value: '36', child: Text('경상남도')),
                  DropdownMenuItem(value: '37', child: Text('전라북도')),
                  DropdownMenuItem(value: '38', child: Text('전라남도')),
                  DropdownMenuItem(value: '39', child: Text('제주도')),
                ],
                onChanged: (value) {
                  ref.read(selectedAreaCodeProvider.notifier).state = value;
                },
              ),
              SizedBox(height: AppSizes.gapM),
              Text('여행 스타일', style: AppTextStyles.labelBold),
              SizedBox(height: AppSizes.gapS),
              DropdownButtonFormField<String>(
                value: selectedContentType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: AppSizes.gapS),
                  hintText: '전체 유형',
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('전체 유형')),
                  DropdownMenuItem(value: '12', child: Text('🏔️ 관광지')),
                  DropdownMenuItem(value: '14', child: Text('🎭 문화시설')),
                  DropdownMenuItem(value: '15', child: Text('🎪 축제공연행사')),
                  DropdownMenuItem(value: '25', child: Text('🗺️ 여행코스')),
                  DropdownMenuItem(value: '28', child: Text('🏃 레포츠')),
                  DropdownMenuItem(value: '32', child: Text('🏨 숙박')),
                  DropdownMenuItem(value: '39', child: Text('🍽️ 음식점')),
                ],
                onChanged: (value) {
                  ref.read(selectedContentTypeProvider.notifier).state = value;
                },
              ),
              SizedBox(height: AppSizes.gapM),
              Container(
                padding: EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: AppColors.primary, size: AppSizes.iconS),
                    SizedBox(width: AppSizes.gapS),
                    Expanded(
                      child: Text(
                        'AI가 당신의 선택을 학습하여 더 정확한 추천을 제공합니다',
                        style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 필터 초기화
              ref.read(selectedAreaCodeProvider.notifier).state = null;
              ref.read(selectedContentTypeProvider.notifier).state = null;
              Navigator.pop(context);
            },
            child: Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _loadAIRecommendations(ref);
            },
            icon: Icon(Icons.auto_awesome, size: AppSizes.iconS),
            label: Text('AI 추천 받기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}