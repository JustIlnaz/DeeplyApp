class CoupleChallenge {
  final String id;
  final String coupleId;
  final String templateId;
  final int progress;
  final bool isCompleted;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  CoupleChallenge({
    required this.id,
    required this.coupleId,
    required this.templateId,
    required this.progress,
    required this.isCompleted,
    required this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory CoupleChallenge.fromJson(Map<String, dynamic> json) {
    return CoupleChallenge(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      templateId: json['templateId'] as String,
      progress: json['progress'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'templateId': templateId,
      'progress': progress,
      'isCompleted': isCompleted,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChallengeTemplate {
  final String id;
  final String name;
  final String description;
  final int duration;
  final String? imageUrl;

  ChallengeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    this.imageUrl,
  });

  factory ChallengeTemplate.fromJson(Map<String, dynamic> json) {
    return ChallengeTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      duration: json['duration'] as int,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration': duration,
      'imageUrl': imageUrl,
    };
  }
}
