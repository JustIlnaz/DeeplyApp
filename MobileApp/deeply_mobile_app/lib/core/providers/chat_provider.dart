import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/dtos.dart';
import '../../data/services/chat_service.dart';
import 'service_providers.dart';

// Chat State
class ChatState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final String? error;

  ChatState({this.isLoading = false, this.messages = const [], this.error});

  ChatState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService chatService;

  ChatNotifier(this.chatService) : super(ChatState());

  Future<void> loadMessages({int skip = 0, int take = 50}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await chatService.getMessages(skip: skip, take: take);
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> sendMessage(
    String content, {
    List<String>? attachmentUrls,
  }) async {
    try {
      final message = await chatService.sendMessage(
        CreateChatMessageRequest(
          content: content,
          attachmentUrls: attachmentUrls,
        ),
      );
      state = state.copyWith(messages: [message, ...state.messages]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await chatService.markAsRead(messageId);

      final updatedMessages = state.messages
          .map(
            (msg) => msg.id == messageId
                ? ChatMessage(
                    id: msg.id,
                    coupleId: msg.coupleId,
                    senderId: msg.senderId,
                    content: msg.content,
                    attachmentUrls: msg.attachmentUrls,
                    isRead: true,
                    createdAt: msg.createdAt,
                    updatedAt: msg.updatedAt,
                  )
                : msg,
          )
          .toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatNotifier(chatService);
});
