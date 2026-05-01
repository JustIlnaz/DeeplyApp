class DailyQuestion {
  final String id;
  final String question;
  final String category;
  final DateTime date;

  DailyQuestion({
    required this.id,
    required this.question,
    required this.category,
    required this.date,
  });

  factory DailyQuestion.fromJson(Map<String, dynamic> json) {
    return DailyQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}

class DailyQuestionAnswer {
  final String id;
  final String questionId;
  final String coupleId;
  final String userId;
  final String answer;
  final DateTime createdAt;

  DailyQuestionAnswer({
    required this.id,
    required this.questionId,
    required this.coupleId,
    required this.userId,
    required this.answer,
    required this.createdAt,
  });

  factory DailyQuestionAnswer.fromJson(Map<String, dynamic> json) {
    return DailyQuestionAnswer(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      coupleId: json['coupleId'] as String,
      userId: json['userId'] as String,
      answer: json['answer'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'coupleId': coupleId,
      'userId': userId,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
