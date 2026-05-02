import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> saveTokens(String access, String refresh) async {
    if (access.isEmpty || refresh.isEmpty) {
      debugPrint('[SecureStorage] saveTokens rejected: empty token');
      await clear();
      return;
    }

    debugPrint('[SecureStorage] saveTokens access=${access.substring(0, 10)}...');
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<String?> getAccessToken() async {
    final v = await _storage.read(key: _accessKey);
    debugPrint('[SecureStorage] getAccessToken = ${v == null ? "null" : v.isEmpty ? "EMPTY STRING" : "${v.substring(0, 10)}..."}');
    return (v != null && v.isNotEmpty) ? v : null;
  }

  static Future<String?> getRefreshToken() async {
    final v = await _storage.read(key: _refreshKey);
    debugPrint('[SecureStorage] getRefreshToken = ${v == null ? "null" : v.isEmpty ? "EMPTY STRING" : "exists"}');
    return (v != null && v.isNotEmpty) ? v : null;
  }

  static Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
