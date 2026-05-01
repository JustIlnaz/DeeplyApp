class ChatMessage {
  final String id;
  final String coupleId;
  final String senderId;
  final String? content;
  final List<String>? attachmentUrls;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatMessage({
    required this.id,
    required this.coupleId,
    required this.senderId,
    this.content,
    this.attachmentUrls,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String?,
      attachmentUrls: (json['attachmentUrls'] as List<dynamic>?)?.cast<String>(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'senderId': senderId,
      'content': content,
      'attachmentUrls': attachmentUrls,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
