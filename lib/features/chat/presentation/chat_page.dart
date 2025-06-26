import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';
import '../../../core/service/unified_laas_api_service.dart';

// ChatMessage 모델
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

// Chat State Provider
final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final isInitializingProvider = StateProvider<bool>((ref) => true);

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final isInitializing = ref.watch(isInitializingProvider);

    // 페이지 시작 시 최초 메시지 받아오기
    useEffect(() {
      _initializeChat(ref);
      return null;
    }, []);

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
                Text(
                    isInitializing ? '초기화 중...' : '온라인',
                    style: AppTextStyles.caption.copyWith(
                        color: isInitializing ? AppColors.warning : AppColors.success
                    )
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        actions: [
          // 새로고침 버튼
          IconButton(
            onPressed: () async {
              try {
                ref.read(isLoadingProvider.notifier).state = true;

                // LaaS에서 새로운 환영 메시지 받아오기
                final newWelcomeMessage = await UnifiedLaaSAPIService.getWelcomeMessage();

                ref.read(chatMessagesProvider.notifier).state = [
                  ChatMessage(
                    text: newWelcomeMessage,
                    isUser: false,
                    timestamp: DateTime.now(),
                  ),
                ];
              } catch (e) {
                print('❌ 새로고침 실패: $e');
              } finally {
                ref.read(isLoadingProvider.notifier).state = false;
              }
            },
            icon: Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: '새로운 인사말 받기',
          ),

          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Column(
        children: [
          // 초기화 중일 때 로딩 표시
          if (isInitializing)
            Container(
              padding: EdgeInsets.all(AppSizes.gapM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(width: AppSizes.gapS),
                  Text('AI와 연결 중...', style: AppTextStyles.caption),
                ],
              ),
            ),

          Expanded(
            child: messages.isEmpty && !isInitializing
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppSizes.gapM),
                  Text('대화를 시작해보세요!',
                      style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary
                      )),
                ],
              ),
            )
                : ListView.builder(
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

  // 초기화 메서드
  void _initializeChat(WidgetRef ref) async {
    try {
      print('🚀 Chat 초기화 시작...');
      ref.read(isInitializingProvider.notifier).state = true;

      // LaaS에서 환영 메시지 받아오기
      final welcomeMessage = await UnifiedLaaSAPIService.getWelcomeMessage();

      // 환영 메시지를 채팅에 추가
      ref.read(chatMessagesProvider.notifier).state = [
        ChatMessage(
          text: welcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

      print('✅ Chat 초기화 완료');
    } catch (e) {
      print('❌ Chat 초기화 실패: $e');

      // 실패 시 기본 메시지 사용
      ref.read(chatMessagesProvider.notifier).state = [
        ChatMessage(
          text: '안녕하세요! 조용한 여행지를 추천해드리는 AI 여행 챗봇입니다. 현재 일시적인 연결 문제가 있지만 계속 이용하실 수 있습니다. 😊',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    } finally {
      ref.read(isInitializingProvider.notifier).state = false;
    }
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
    final isInitializing = ref.watch(isInitializingProvider);

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
            // 퀵 질문 버튼
            PopupMenuButton<String>(
              icon: Icon(Icons.lightbulb_outline, color: AppColors.primary),
              tooltip: '추천 질문',
              enabled: !isLoading && !isInitializing,
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
                    hintText: isInitializing ? '초기화 중...' : '메시지를 입력하세요...',
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
                  enabled: !isLoading && !isInitializing,
                ),
              ),
            ),
            SizedBox(width: AppSizes.gapS),
            FloatingActionButton(
              onPressed: (isLoading || isInitializing) ? null : () => _sendMessage(ref, messageController),
              mini: true,
              backgroundColor: (isLoading || isInitializing) ? AppColors.textSecondary : AppColors.primary,
              elevation: AppSizes.elevationS,
              child: (isLoading || isInitializing)
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

  // 단순화된 AI 응답
  Future<String> _fetchAIResponse(String userMessage) async {
    try {
      print('🤖 AI 응답 생성: $userMessage');

      // TODO: 나중에 관광공사 API 데이터 추가 가능
      // final additionalContext = await TourismApiService.getContextForMessage(userMessage);

      final aiResponse = await UnifiedLaaSAPIService.callAIWithContext(
        userMessage: userMessage,
        additionalContext: null, // 필요시 여기에 관광공사 API 데이터 추가
      );

      return aiResponse;

    } catch (e) {
      print('❌ AI 응답 생성 실패: $e');

      if (e.toString().toLowerCase().contains('timeout')) {
        return 'API 응답 시간이 초과되었습니다. 다시 시도해주세요.';
      } else if (e.toString().toLowerCase().contains('network')) {
        return '네트워크 연결을 확인해주세요.';
      } else {
        return '일시적인 오류가 발생했습니다. 다시 시도해주세요.';
      }
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
