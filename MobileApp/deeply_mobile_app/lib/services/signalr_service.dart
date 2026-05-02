import 'package:signalr_netcore/signalr_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../data/models/message_model.dart';

class SignalRService {
  HubConnection? _connection;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void Function(MessageModel)? onNewMessage;
  void Function(int)? onMessageRead;

  Future<void> connect(int coupleId) async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) return;

    _connection = HubConnectionBuilder()
        .withUrl(
          '${ApiEndpoints.baseUrl}${ApiEndpoints.chatHub}',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _connection!.on('message:new', (args) {
      if (args == null || args.isEmpty) return;
      final data = Map<String, dynamic>.from(args[0] as Map);
      onNewMessage?.call(MessageModel.fromJson(data));
    });

    _connection!.on('message:read', (args) {
      if (args == null || args.isEmpty) return;
      final data = Map<String, dynamic>.from(args[0] as Map);
      final messageId = data['messageId'] as int?;
      if (messageId != null) onMessageRead?.call(messageId);
    });

    _connection!.onclose(({Exception? error}) {
      _isConnected = false;
    });

    _connection!.onreconnected(({String? connectionId}) {
      _isConnected = true;
      joinRoom(coupleId);
    });

    try {
      await _connection!.start();
      _isConnected = true;
      await joinRoom(coupleId);
    } catch (_) {
      _isConnected = false;
    }
  }

  Future<void> joinRoom(int coupleId) async {
    try {
      await _connection?.invoke('JoinCoupleRoom', args: ['$coupleId']);
    } catch (_) {}
  }

  Future<void> leaveRoom(int coupleId) async {
    try {
      await _connection?.invoke('LeaveCoupleRoom', args: ['$coupleId']);
    } catch (_) {}
  }

  Future<void> disconnect(int coupleId) async {
    await leaveRoom(coupleId);
    await _connection?.stop();
    _isConnected = false;
    _connection = null;
  }

  void dispose() {
    _connection?.stop();
    _connection = null;
  }
}
