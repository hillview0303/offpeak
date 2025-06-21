import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    text: '안녕하세요! 여행 관련해서 궁금한 것이 있으시면 언제든 물어보세요! 😊',
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
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.attach_file, color: AppColors.textSecondary),
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

  Future<String> _fetchAIResponse(String userMessage) async {
    try {
      final projectCode = dotenv.env['LAAS_PROJECT_CODE'];
      final apiKey = dotenv.env['LAAS_API_KEY'];
      final hash = dotenv.env['LAAS_HASH'];

      if (projectCode == null || apiKey == null || hash == null) {
        return '.env 파일 설정을 확인해주세요.';
      }

      const String apiUrl = 'https://api-laas.wanted.co.kr/api/preset/v2/chat/completions';
      final url = Uri.parse(apiUrl);

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
            'content': userMessage,
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

          return 'AI 응답을 찾을 수 없습니다.';

        } else {
          return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
        }

      } finally {
        client.close();
      }

    } catch (e) {
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return '방금';
    if (difference.inHours < 1) return '${difference.inMinutes}분 전';
    if (difference.inDays < 1) return '${difference.inHours}시간 전';
    return '${time.month}/${time.day}';
  }
}