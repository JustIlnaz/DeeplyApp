import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/couple_service.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/services/feature_service.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthServiceImpl(dioClient);
});

// Couple Service Provider
final coupleServiceProvider = Provider<CoupleService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CoupleServiceImpl(dioClient);
});

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChatServiceImpl(dioClient);
});

// Feature Service Provider
final featureServiceProvider = Provider<FeatureService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FeatureServiceImpl(dioClient);
});

// Token Storage Providers
final accessTokenProvider = StateProvider<String?>((ref) => null);
final refreshTokenProvider = StateProvider<String?>((ref) => null);
final userIdProvider = StateProvider<String?>((ref) => null);
