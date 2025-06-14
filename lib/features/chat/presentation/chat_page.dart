import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '안녕하세요! 여행 관련해서 궁금한 것이 있으시면 언제든 물어보세요! 😊',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'AI 여행 도우미',
                  style: AppTextStyles.labelBold,
                ),
                Text(
                  '온라인',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: AppSizes.elevationS,
        actions: [
          IconButton(
            onPressed: () {
              // 채팅 설정
            },
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 채팅 메시지 리스트
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AppSizes.gapM),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // 메시지 입력 영역
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.gapS),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
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
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.gapM,
                    vertical: AppSizes.gapS,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusL)
                        .copyWith(
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
                      color: message.isUser
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.gapXS),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          if (message.isUser) ...[
            SizedBox(width: AppSizes.gapS),
            CircleAvatar(
              radius: AppSizes.avatarS / 2,
              backgroundColor: AppColors.secondary,
              child: Icon(
                Icons.person,
                color: AppColors.white,
                size: AppSizes.iconS,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(AppSizes.gapM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.elevationS,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 첨부 버튼
            IconButton(
              onPressed: () {
                // 파일 첨부
              },
              icon: Icon(
                Icons.attach_file,
                color: AppColors.textSecondary,
              ),
            ),

            // 텍스트 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
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
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
            ),

            SizedBox(width: AppSizes.gapS),

            // 전송 버튼
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              backgroundColor: AppColors.primary,
              elevation: AppSizes.elevationS,
              child: Icon(
                Icons.send,
                color: AppColors.white,
                size: AppSizes.iconS,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();

    // AI 응답 시뮬레이션
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          text: _getAIResponse(text),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  String _getAIResponse(String userMessage) {
    final responses = [
      '그것에 대해 더 자세히 알려드릴게요! 🏝️',
      '좋은 질문이네요. 제가 도움을 드릴 수 있어요! ✈️',
      '여행 관련해서 더 궁금한 것이 있으시면 언제든 물어보세요! 🗺️',
      '맞춤형 추천을 원하시면 알고리즘 추천 기능을 이용해보세요! 🎯',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${time.month}/${time.day}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
