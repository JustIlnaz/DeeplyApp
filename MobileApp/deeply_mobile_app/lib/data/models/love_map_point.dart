class LoveMapPoint {
  final String id;
  final String coupleId;
  final String createdById;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final List<String>? photoUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LoveMapPoint({
    required this.id,
    required this.coupleId,
    required this.createdById,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.photoUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory LoveMapPoint.fromJson(Map<String, dynamic> json) {
    return LoveMapPoint(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      createdById: json['createdById'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'createdById': createdById,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
