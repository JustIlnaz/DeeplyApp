class WeeklyCheckIn {
  final String id;
  final String coupleId;
  final String userId;
  final String whatWasGreat;
  final String whereWasTension;
  final String whatCanBeImproved;
  final DateTime weekStartDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WeeklyCheckIn({
    required this.id,
    required this.coupleId,
    required this.userId,
    required this.whatWasGreat,
    required this.whereWasTension,
    required this.whatCanBeImproved,
    required this.weekStartDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory WeeklyCheckIn.fromJson(Map<String, dynamic> json) {
    return WeeklyCheckIn(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      userId: json['userId'] as String,
      whatWasGreat: json['whatWasGreat'] as String,
      whereWasTension: json['whereWasTension'] as String,
      whatCanBeImproved: json['whatCanBeImproved'] as String,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'userId': userId,
      'whatWasGreat': whatWasGreat,
      'whereWasTension': whereWasTension,
      'whatCanBeImproved': whatCanBeImproved,
      'weekStartDate': weekStartDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
