import 'package:flutter/material.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final _dio = DioClient.instance;
  List<MessageModel> messages = [];
  bool isLoading = false;

  Future<void> fetchHistory({int take = 50}) async {
    isLoading = true; notifyListeners();
    try {
      final r = await _dio.get(ApiEndpoints.chatHistory, queryParameters: {'take': take});
      messages = (r.data as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (_) {}
    isLoading = false; notifyListeners();
  }

  Future<bool> sendMessage({String? text, String? photoUrl}) async {
    try {
      final r = await _dio.post(ApiEndpoints.chatSend, data: {
        'text': ?text,
        'photoUrl': ?photoUrl,
      });
      messages.add(MessageModel.fromJson(r.data));
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<void> markRead(int messageId) async {
    try {
      await _dio.post(ApiEndpoints.chatRead(messageId));
      final idx = messages.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        messages[idx] = MessageModel(
          id: messages[idx].id,
          coupleId: messages[idx].coupleId,
          senderUserId: messages[idx].senderUserId,
          text: messages[idx].text,
          photoUrl: messages[idx].photoUrl,
          isRead: true,
          sentAtUtc: messages[idx].sentAtUtc,
        );
        notifyListeners();
      }
    } catch (_) {}
  }
}
