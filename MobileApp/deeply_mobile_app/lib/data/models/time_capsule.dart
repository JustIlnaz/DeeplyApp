class TimeCapsule {
  final String id;
  final String coupleId;
  final String createdById;
  final String content;
  final DateTime openDate;
  final bool isOpened;
  final DateTime createdAt;

  TimeCapsule({
    required this.id,
    required this.coupleId,
    required this.createdById,
    required this.content,
    required this.openDate,
    required this.isOpened,
    required this.createdAt,
  });

  factory TimeCapsule.fromJson(Map<String, dynamic> json) {
    return TimeCapsule(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      createdById: json['createdById'] as String,
      content: json['content'] as String,
      openDate: DateTime.parse(json['openDate'] as String),
      isOpened: json['isOpened'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'createdById': createdById,
      'content': content,
      'openDate': openDate.toIso8601String(),
      'isOpened': isOpened,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SecretMessage {
  final String id;
  final String coupleId;
  final String createdById;
  final String content;
  final int? hoursToOpen;
  final DateTime? openDate;
  final bool isOpened;
  final DateTime createdAt;

  SecretMessage({
    required this.id,
    required this.coupleId,
    required this.createdById,
    required this.content,
    this.hoursToOpen,
    this.openDate,
    required this.isOpened,
    required this.createdAt,
  });

  factory SecretMessage.fromJson(Map<String, dynamic> json) {
    return SecretMessage(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      createdById: json['createdById'] as String,
      content: json['content'] as String,
      hoursToOpen: json['hoursToOpen'] as int?,
      openDate: json['openDate'] != null ? DateTime.parse(json['openDate'] as String) : null,
      isOpened: json['isOpened'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'createdById': createdById,
      'content': content,
      'hoursToOpen': hoursToOpen,
      'openDate': openDate?.toIso8601String(),
      'isOpened': isOpened,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
