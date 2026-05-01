import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dtos.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';
import 'service_providers.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService authService;
  final Ref ref;

  AuthNotifier(this.authService, this.ref) : super(AuthState());

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await authService.register(
        RegisterRequest(email: email, password: password, name: name),
      );

      ref.read(accessTokenProvider.notifier).state = response.accessToken;
      ref.read(refreshTokenProvider.notifier).state = response.refreshToken;
      ref.read(userIdProvider.notifier).state = response.userId;

      // Set auth token in Dio
      final dioClient = ref.read(dioClientProvider);
      dioClient.setAuthToken(response.accessToken);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await authService.login(
        LoginRequest(email: email, password: password),
      );

      ref.read(accessTokenProvider.notifier).state = response.accessToken;
      ref.read(refreshTokenProvider.notifier).state = response.refreshToken;
      ref.read(userIdProvider.notifier).state = response.userId;

      // Set auth token in Dio
      final dioClient = ref.read(dioClientProvider);
      dioClient.setAuthToken(response.accessToken);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> refresh() async {
    try {
      final refreshToken = ref.read(refreshTokenProvider);
      if (refreshToken == null) throw Exception('No refresh token');

      final response = await authService.refresh(
        RefreshRequest(refreshToken: refreshToken),
      );

      ref.read(accessTokenProvider.notifier).state = response.accessToken;
      ref.read(refreshTokenProvider.notifier).state = response.refreshToken;
      ref.read(userIdProvider.notifier).state = response.userId;

      // Update auth token in Dio
      final dioClient = ref.read(dioClientProvider);
      dioClient.setAuthToken(response.accessToken);

      state = state.copyWith(isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await authService.logout();

      ref.read(accessTokenProvider.notifier).state = null;
      ref.read(refreshTokenProvider.notifier).state = null;
      ref.read(userIdProvider.notifier).state = null;

      // Remove auth token from Dio
      final dioClient = ref.read(dioClientProvider);
      dioClient.removeAuthToken();

      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService, ref);
});
