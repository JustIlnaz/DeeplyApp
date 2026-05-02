class SecretMessageModel {
  final int id;
  final String message;
  final String openAtUtc;
  final bool isOpened;
  final bool isMine;

  SecretMessageModel({
    required this.id,
    required this.message,
    required this.openAtUtc,
    required this.isOpened,
    this.isMine = false,
  });

  factory SecretMessageModel.fromJson(Map<String, dynamic> j) => SecretMessageModel(
    id: j['id'],
    message: j['message'] ?? '',
    openAtUtc: j['openAtUtc'] ?? '',
    isOpened: j['isOpened'] ?? false,
    isMine: j['isMine'] ?? false,
  );
}
