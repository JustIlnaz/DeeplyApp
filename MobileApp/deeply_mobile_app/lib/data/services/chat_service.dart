import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../models/dtos.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';

abstract class ChatService {
  Future<List<ChatMessage>> getMessages({int? skip, int? take});
  Future<ChatMessage> sendMessage(CreateChatMessageRequest request);
  Future<void> markAsRead(String messageId);
}

class ChatServiceImpl implements ChatService {
  final DioClient _dioClient;

  ChatServiceImpl(this._dioClient);

  @override
  Future<List<ChatMessage>> getMessages({int? skip, int? take}) async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/chat/messages',
        queryParameters: {
          'skip': ?skip,
          'take': ?take,
        },
      );
      final data = response.data ?? [];
      return data
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ChatMessage> sendMessage(CreateChatMessageRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/chat/send',
        data: request.toJson(),
      );
      return ChatMessage.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    try {
      await _dioClient.put('/chat/messages/$messageId/read');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
