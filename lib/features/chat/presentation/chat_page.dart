import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';
import '../../../core/service/unified_laas_api_service.dart'; // ⭐ LaaS 서비스
import '../../../core/service/tourism_api_service.dart'; // ⭐ 관광공사 API 서비스

// ChatMessage 모델
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

// Chat State Provider
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => [
  ChatMessage(
    text: '안녕하세요! 여행 관련해서 궁금한 것이 있으시면 언제든 물어보세요! 😊\n\n위치 기반 추천을 원하시면 "내 주변 맛집 추천해줘" 같이 물어보세요!',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
]);

final isLoadingProvider = StateProvider<bool>((ref) => false);

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: AppSizes.avatarS / 2,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.smart_toy,
                color: AppColors.white,
                size: AppSizes.iconS,
              ),
            ),
            SizedBox(width: AppSizes.gapS),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI 여행 도우미', style: AppTextStyles.labelBold),
                Text('온라인', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        actions: [
          IconButton(
            onPressed: () {
              // 대화 초기화
              ref.read(chatMessagesProvider.notifier).state = [
                ChatMessage(
                  text: '안녕하세요! 여행 관련해서 궁금한 것이 있으시면 언제든 물어보세요! 😊\n\n위치 기반 추천을 원하시면 "내 주변 맛집 추천해줘" 같이 물어보세요!',
                  isUser: false,
                  timestamp: DateTime.now(),
                ),
              ];
            },
            icon: Icon(Icons.refresh, color: AppColors.textSecondary),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppSizes.gapM),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
            ),
          ),
          if (isLoading)
            Container(
              padding: EdgeInsets.all(AppSizes.gapS),
              child: Row(
                children: [
                  SizedBox(width: AppSizes.gapL),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(width: AppSizes.gapS),
                  Text('AI가 답변을 생성하고 있어요...',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          _buildMessageInput(context, ref, messageController),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.gapS),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: AppSizes.avatarS / 2,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.smart_toy, color: AppColors.white, size: AppSizes.iconS),
            ),
            SizedBox(width: AppSizes.gapS),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: AppSizes.gapS),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL).copyWith(
                      bottomLeft: message.isUser
                          ? Radius.circular(AppSizes.radiusL)
                          : Radius.circular(AppSizes.radiusS),
                      bottomRight: message.isUser
                          ? Radius.circular(AppSizes.radiusS)
                          : Radius.circular(AppSizes.radiusL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: AppSizes.elevationS,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: message.isUser ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.gapXS),
                Text(_formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: AppSizes.gapS),
            CircleAvatar(
              radius: AppSizes.avatarS / 2,
              backgroundColor: AppColors.secondary,
              child: Icon(Icons.person, color: AppColors.white, size: AppSizes.iconS),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, WidgetRef ref, TextEditingController messageController) {
    final isLoading = ref.watch(isLoadingProvider);

    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: AppSizes.elevationS, offset: const Offset(0, -1)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ⭐ 퀵 질문 버튼
            PopupMenuButton<String>(
              icon: Icon(Icons.lightbulb_outline, color: AppColors.primary),
              tooltip: '추천 질문',
              onSelected: (value) {
                messageController.text = value;
                _sendMessage(ref, messageController);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: '내 주변 맛집 추천해줘', child: Text('🍽️ 내 주변 맛집 추천')),
                PopupMenuItem(value: '가족과 갈만한 관광지 알려줘', child: Text('👨‍👩‍👧‍👦 가족 여행지 추천')),
                PopupMenuItem(value: '데이트 코스 추천해줘', child: Text('💕 데이트 코스 추천')),
                PopupMenuItem(value: '비오는날 갈만한 실내 장소는?', child: Text('☔ 실내 장소 추천')),
                PopupMenuItem(value: '부산 대표 관광지 알려줘', child: Text('🏔️ 대표 관광지')),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle: AppTextStyles.hint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSizes.gapM,
                      vertical: AppSizes.gapS,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _sendMessage(ref, messageController),
                  enabled: !isLoading,
                ),
              ),
            ),
            SizedBox(width: AppSizes.gapS),
            FloatingActionButton(
              onPressed: isLoading ? null : () => _sendMessage(ref, messageController),
              mini: true,
              backgroundColor: isLoading ? AppColors.textSecondary : AppColors.primary,
              elevation: AppSizes.elevationS,
              child: isLoading
                  ? SizedBox(
                width: AppSizes.iconS,
                height: AppSizes.iconS,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  strokeWidth: 2,
                ),
              )
                  : Icon(Icons.send, color: AppColors.white, size: AppSizes.iconS),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(WidgetRef ref, TextEditingController messageController) {
    final text = messageController.text.trim();
    if (text.isEmpty || ref.read(isLoadingProvider)) return;

    // 사용자 메시지 추가
    final currentMessages = ref.read(chatMessagesProvider);
    ref.read(chatMessagesProvider.notifier).state = [
      ...currentMessages,
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    ];

    ref.read(isLoadingProvider.notifier).state = true;
    messageController.clear();

    _fetchAIResponse(text).then((aiText) {
      final updatedMessages = ref.read(chatMessagesProvider);
      ref.read(chatMessagesProvider.notifier).state = [
        ...updatedMessages,
        ChatMessage(text: aiText, isUser: false, timestamp: DateTime.now()),
      ];
      ref.read(isLoadingProvider.notifier).state = false;
    }).catchError((error) {
      final errorMessages = ref.read(chatMessagesProvider);
      ref.read(chatMessagesProvider.notifier).state = [
        ...errorMessages,
        ChatMessage(
          text: '죄송합니다. 일시적인 오류가 발생했습니다. 다시 시도해주세요.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
      ref.read(isLoadingProvider.notifier).state = false;
    });
  }

  // ⭐ 매우 간소화된 AI 응답 - 데이터만 수집하고 LaaS에 위임
  Future<String> _fetchAIResponse(String userMessage) async {
    try {
      print('🤖 AI 응답 생성 시작: $userMessage');

      // ⭐ 위치 기반 질문인지 확인하고 주변 장소 데이터 수집
      List<NearbyPlace>? nearbyPlaces;
      if (_isLocationBasedQuery(userMessage)) {
        print('📍 위치 기반 질문 감지, 주변 장소 정보 수집 중...');

        try {
          nearbyPlaces = await _getNearbyPlaces(userMessage);
          print('✅ ${nearbyPlaces?.length ?? 0}개 주변 장소 정보 수집 완료');
        } catch (e) {
          print('⚠️ 주변 장소 정보 수집 실패: $e');
          // 오류가 있어도 기본 질문으로 진행
        }
      }

      // ⭐ UnifiedLaaSAPIService에 데이터와 함께 전달 (프롬프트는 LaaS에서 처리)
      print('🌐 UnifiedLaaSAPIService.callAI 호출 중...');
      final aiResponse = await UnifiedLaaSAPIService.callAIWithContext(
        userMessage: userMessage,
        nearbyPlaces: nearbyPlaces,
      );

      print('✅ AI 응답 생성 완료');
      return aiResponse;

    } catch (e) {
      print('❌ AI 응답 생성 실패: $e');

      if (e.toString().toLowerCase().contains('timeout')) {
        return 'API 응답 시간이 초과되었습니다. 다시 시도해주세요.';
      } else if (e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('network')) {
        return '네트워크 연결을 확인해주세요.';
      } else {
        return '일시적인 오류가 발생했습니다. 다시 시도해주세요.';
      }
    }
  }

  // ⭐ 위치 기반 질문인지 판단
  bool _isLocationBasedQuery(String query) {
    final locationKeywords = [
      '내 주변', '근처', '주변', '가까운', '내 근처',
      '맛집', '음식점', '카페', '관광지', '놀거리',
      '가볼만한', '추천', '데이트', '코스',
      '부산', '해운대', '서면', '광안리'
    ];

    final lowerQuery = query.toLowerCase();
    return locationKeywords.any((keyword) => lowerQuery.contains(keyword));
  }

  // ⭐ 주변 장소 데이터만 수집 (프롬프트 구성은 LaaS에서 처리)
  Future<List<NearbyPlace>> _getNearbyPlaces(String userQuery) async {
    try {
      // 현재 위치 가져오기
      Position? position;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            ).timeout(const Duration(seconds: 5));
            print('📍 현재 위치: ${position.latitude}, ${position.longitude}');
          }
        }
      } catch (e) {
        print('⚠️ 위치 정보 획득 실패: $e');
      }

      // 카테고리 추정
      String? category = _inferCategoryFromQuery(userQuery);
      print('🏷️ 추정된 카테고리: $category');

      List<NearbyPlace> places = [];

      if (position != null) {
        // ⭐ TourismApiService 사용 - 현재 위치 기반
        places = await TourismApiService.fetchNearbyPlaces(
          latitude: position.latitude,
          longitude: position.longitude,
          category: category,
          radius: 5000, // 5km
        );
        print('📍 위치 기반 검색: ${places.length}개 장소');
      } else {
        // ⭐ TourismApiService 사용 - 부산 지역 기반
        places = await TourismApiService.fetchPlacesByCategory(
          category: category ?? '전체',
          areaCode: '6', // 부산
        );
        print('🏙️ 부산 지역 검색: ${places.length}개 장소');
      }

      // 상위 5개 장소만 반환 (LaaS에서 프롬프트 구성할 때 사용)
      return places.take(5).toList();

    } catch (e) {
      print('❌ 주변 장소 데이터 수집 실패: $e');
      return [];
    }
  }

  // ⭐ 질문에서 카테고리 추정
  String? _inferCategoryFromQuery(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('맛집') || lowerQuery.contains('음식점') ||
        lowerQuery.contains('식당') || lowerQuery.contains('먹을곳')) {
      return '음식점';
    }
    if (lowerQuery.contains('관광지') || lowerQuery.contains('명소') ||
        lowerQuery.contains('구경') || lowerQuery.contains('여행')) {
      return '관광지';
    }
    if (lowerQuery.contains('숙박') || lowerQuery.contains('호텔') ||
        lowerQuery.contains('펜션') || lowerQuery.contains('잘곳')) {
      return '숙박';
    }
    if (lowerQuery.contains('쇼핑') || lowerQuery.contains('쇼핑몰') ||
        lowerQuery.contains('마트') || lowerQuery.contains('시장')) {
      return '쇼핑';
    }
    if (lowerQuery.contains('문화') || lowerQuery.contains('박물관') ||
        lowerQuery.contains('미술관') || lowerQuery.contains('전시')) {
      return '문화시설';
    }
    if (lowerQuery.contains('운동') || lowerQuery.contains('스포츠') ||
        lowerQuery.contains('헬스') || lowerQuery.contains('레저')) {
      return '레포츠';
    }

    return null; // 전체 카테고리
  }

  // ⭐ 카테고리 표시명 변환 (제거 - 필요시 TourismApiService에서 처리)
  String _getCategoryDisplayName(String category) {
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return '방금';
    if (difference.inHours < 1) return '${difference.inMinutes}분 전';
    if (difference.inDays < 1) return '${difference.inHours}시간 전';
    return '${time.month}/${time.day}';
  }
}
