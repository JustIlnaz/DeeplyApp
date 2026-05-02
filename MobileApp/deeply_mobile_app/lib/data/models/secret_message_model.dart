class SecretMessageModel {
  final int id;
  final String message;
  final String openAtUtc;
  final bool isOpened;

  SecretMessageModel({
    required this.id,
    required this.message,
    required this.openAtUtc,
    required this.isOpened,
  });

  factory SecretMessageModel.fromJson(Map<String, dynamic> j) => SecretMessageModel(
    id: j['id'],
    message: j['message'] ?? '',
    openAtUtc: j['openAtUtc'] ?? '',
    isOpened: j['isOpened'] ?? false,
  );
}
