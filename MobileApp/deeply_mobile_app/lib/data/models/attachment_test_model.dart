class AttachmentQuestion {
  final int id;
  final String text;
  final List<String> options;

  const AttachmentQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}

class AttachmentTestResultModel {
  final int userId;
  final String attachmentType;
  final String recommendation;

  AttachmentTestResultModel({
    required this.userId,
    required this.attachmentType,
    required this.recommendation,
  });

  factory AttachmentTestResultModel.fromJson(Map<String, dynamic> j) =>
      AttachmentTestResultModel(
        userId: j['userId'],
        attachmentType: j['attachmentType'] ?? '',
        recommendation: j['recommendation'] ?? '',
      );

  String get typeLabel => switch (attachmentType.toLowerCase()) {
        'secure' => 'Надёжный тип',
        'anxious' => 'Тревожный тип',
        'avoidant' => 'Избегающий тип',
        _ => attachmentType,
      };

  String get typeEmoji => switch (attachmentType.toLowerCase()) {
        'secure' => '🤍',
        'anxious' => '💛',
        'avoidant' => '💜',
        _ => '❓',
      };
}
