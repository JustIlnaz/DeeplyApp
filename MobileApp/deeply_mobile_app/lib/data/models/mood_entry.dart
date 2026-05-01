class MoodEntry {
  final String id;
  final String coupleId;
  final String userId;
  final String mood;
  final String? comment;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MoodEntry({
    required this.id,
    required this.coupleId,
    required this.userId,
    required this.mood,
    this.comment,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      userId: json['userId'] as String,
      mood: json['mood'] as String,
      comment: json['comment'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'userId': userId,
      'mood': mood,
      'comment': comment,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
