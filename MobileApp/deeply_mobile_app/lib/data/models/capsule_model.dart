class CapsuleModel {
  final int id;
  final String letter;
  final String openAtUtc;
  final bool isOpened;

  CapsuleModel({
    required this.id,
    required this.letter,
    required this.openAtUtc,
    required this.isOpened,
  });

  factory CapsuleModel.fromJson(Map<String, dynamic> j) => CapsuleModel(
    id: j['id'],
    letter: j['letter'] ?? '',
    openAtUtc: j['openAtUtc'] ?? '',
    isOpened: j['isOpened'] ?? false,
  );
}
