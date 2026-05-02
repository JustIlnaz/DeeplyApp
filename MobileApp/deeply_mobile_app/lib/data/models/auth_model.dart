class AuthModel {
  final String accessToken;
  final String refreshToken;

  AuthModel({required this.accessToken, required this.refreshToken});

  factory AuthModel.fromJson(Map<String, dynamic> j) => AuthModel(
    accessToken: j['accessToken'] ?? '',
    refreshToken: j['refreshToken'] ?? '',
  );
}
