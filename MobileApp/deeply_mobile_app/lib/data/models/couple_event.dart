class CoupleEvent {
  final String id;
  final String coupleId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final bool? isAnniversary;
  final bool? isReminder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CoupleEvent({
    required this.id,
    required this.coupleId,
    required this.title,
    this.description,
    required this.eventDate,
    this.isAnniversary,
    this.isReminder,
    required this.createdAt,
    this.updatedAt,
  });

  factory CoupleEvent.fromJson(Map<String, dynamic> json) {
    return CoupleEvent(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['eventDate'] as String),
      isAnniversary: json['isAnniversary'] as bool?,
      isReminder: json['isReminder'] as bool?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'title': title,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'isAnniversary': isAnniversary,
      'isReminder': isReminder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
