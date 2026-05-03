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
  
  // Partner info
  final String? partnerType;
  final String? partnerRecommendation;

  AttachmentTestResultModel({
    required this.userId,
    required this.attachmentType,
    required this.recommendation,
    this.partnerType,
    this.partnerRecommendation,
  });

  factory AttachmentTestResultModel.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    final partner = j['partner'];
    
    return AttachmentTestResultModel(
      userId: user?['attachmentType'] != null ? j['userId'] ?? 0 : 0,
      attachmentType: user?['attachmentType'] ?? '',
      recommendation: user?['recommendation'] ?? '',
      partnerType: partner?['attachmentType'],
      partnerRecommendation: partner?['recommendation'],
    );
  }

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

  String get partnerTypeLabel => switch (partnerType?.toLowerCase()) {
        'secure' => 'Надёжный тип',
        'anxious' => 'Тревожный тип',
        'avoidant' => 'Избегающий тип',
        _ => partnerType ?? '',
      };

  String get partnerTypeEmoji => switch (partnerType?.toLowerCase()) {
        'secure' => '🤍',
        'anxious' => '💛',
        'avoidant' => '💜',
        _ => '❓',
      };
}
