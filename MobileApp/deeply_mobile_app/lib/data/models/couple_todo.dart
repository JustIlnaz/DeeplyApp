class CoupleTodo {
  final String id;
  final String coupleId;
  final String createdById;
  final String? assignedTo;
  final String title;
  final String? description;
  final String status;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CoupleTodo({
    required this.id,
    required this.coupleId,
    required this.createdById,
    this.assignedTo,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory CoupleTodo.fromJson(Map<String, dynamic> json) {
    return CoupleTodo(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      createdById: json['createdById'] as String,
      assignedTo: json['assignedTo'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'createdById': createdById,
      'assignedTo': assignedTo,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
