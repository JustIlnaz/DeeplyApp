class FinanceGoal {
  final String id;
  final String coupleId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String category;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FinanceGoal({
    required this.id,
    required this.coupleId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.category,
    required this.targetDate,
    required this.isCompleted,
    required this.createdAt,
    this.updatedAt,
  });

  factory FinanceGoal.fromJson(Map<String, dynamic> json) {
    return FinanceGoal(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      category: json['category'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'category': category,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class FinanceRecord {
  final String id;
  final String coupleId;
  final String userId;
  final double amount;
  final String category;
  final String type;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  FinanceRecord({
    required this.id,
    required this.coupleId,
    required this.userId,
    required this.amount,
    required this.category,
    required this.type,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory FinanceRecord.fromJson(Map<String, dynamic> json) {
    return FinanceRecord(
      id: json['id'] as String,
      coupleId: json['coupleId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'userId': userId,
      'amount': amount,
      'category': category,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
