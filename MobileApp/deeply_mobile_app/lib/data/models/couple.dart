class Couple {
  final String id;
  final String user1Id;
  final String user2Id;
  final String coupleCode;
  final String? coupleName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Couple({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.coupleCode,
    this.coupleName,
    required this.createdAt,
    this.updatedAt,
  });

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'] as String,
      user1Id: json['user1Id'] as String,
      user2Id: json['user2Id'] as String,
      coupleCode: json['coupleCode'] as String,
      coupleName: json['coupleName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'coupleCode': coupleCode,
      'coupleName': coupleName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
