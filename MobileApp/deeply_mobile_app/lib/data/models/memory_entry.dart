class MemoryEntry {
  final String id;
  final String coupleId;
  final String createdById;
  final String? content;
  final List<String>? photoUrls;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MemoryEntry({
    required this.id,
    required this.coupleId,
    required this.createdById,
    this.content,
    this.photoUrls,
    required this.isPinned,
    required this.createdAt,
    this.updatedAt,
  });

  factory MemoryEntry.fromJson(Map<String, dynamic> json) {
    return MemoryEntry(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      createdById: json['createdById'] as String,
      content: json['content'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.cast<String>(),
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'createdById': createdById,
      'content': content,
      'photoUrls': photoUrls,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
