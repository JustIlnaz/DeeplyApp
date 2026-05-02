class AuthModel {
  final String accessToken;
  final String refreshToken;

  AuthModel({required this.accessToken, required this.refreshToken});

  factory AuthModel.fromJson(Map<String, dynamic> j) => AuthModel(
    accessToken: (j['accessToken'] ?? j['AccessToken'] ?? '') as String,
    refreshToken: (j['refreshToken'] ?? j['RefreshToken'] ?? '') as String,
  );

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;
}
