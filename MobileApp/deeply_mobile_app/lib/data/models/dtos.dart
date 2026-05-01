// Auth DTOs
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'name': name,
  };
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
    );
  }
}

class RefreshRequest {
  final String refreshToken;

  RefreshRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

// Couple DTOs
class CreateCoupleRequest {
  final String? coupleName;

  CreateCoupleRequest({this.coupleName});

  Map<String, dynamic> toJson() => {'coupleName': coupleName};
}

class JoinCoupleRequest {
  final String coupleCode;

  JoinCoupleRequest({required this.coupleCode});

  Map<String, dynamic> toJson() => {'coupleCode': coupleCode};
}

// Chat DTOs
class CreateChatMessageRequest {
  final String content;
  final List<String>? attachmentUrls;

  CreateChatMessageRequest({
    required this.content,
    this.attachmentUrls,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'attachmentUrls': attachmentUrls,
  };
}

// Memory DTOs
class CreateMemoryRequest {
  final String? content;
  final List<String>? photoUrls;

  CreateMemoryRequest({
    this.content,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'photoUrls': photoUrls,
  };
}

// Event DTOs
class CreateEventRequest {
  final String title;
  final String? description;
  final DateTime eventDate;
  final bool? isAnniversary;

  CreateEventRequest({
    required this.title,
    this.description,
    required this.eventDate,
    this.isAnniversary,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'eventDate': eventDate.toIso8601String(),
    'isAnniversary': isAnniversary,
  };
}

// Mood DTOs
class CreateMoodRequest {
  final String mood;
  final String? comment;

  CreateMoodRequest({
    required this.mood,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'comment': comment,
  };
}

// Daily Question DTOs
class AnswerQuestionRequest {
  final String answer;

  AnswerQuestionRequest({required this.answer});

  Map<String, dynamic> toJson() => {'answer': answer};
}

// Weekly CheckIn DTOs
class WeeklyCheckInRequest {
  final String whatWasGreat;
  final String whereWasTension;
  final String whatCanBeImproved;

  WeeklyCheckInRequest({
    required this.whatWasGreat,
    required this.whereWasTension,
    required this.whatCanBeImproved,
  });

  Map<String, dynamic> toJson() => {
    'whatWasGreat': whatWasGreat,
    'whereWasTension': whereWasTension,
    'whatCanBeImproved': whatCanBeImproved,
  };
}

// Todo DTOs
class CreateTodoRequest {
  final String title;
  final String? description;
  final String? assignedTo;
  final DateTime? dueDate;

  CreateTodoRequest({
    required this.title,
    this.description,
    this.assignedTo,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'assignedTo': assignedTo,
    'dueDate': dueDate?.toIso8601String(),
  };
}

class UpdateTodoStatusRequest {
  final String status;

  UpdateTodoStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}

// Finance DTOs
class CreateFinanceGoalRequest {
  final String title;
  final double targetAmount;
  final String category;
  final DateTime targetDate;

  CreateFinanceGoalRequest({
    required this.title,
    required this.targetAmount,
    required this.category,
    required this.targetDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'targetAmount': targetAmount,
    'category': category,
    'targetDate': targetDate.toIso8601String(),
  };
}

class UpdateFinanceGoalProgressRequest {
  final double amount;

  UpdateFinanceGoalProgressRequest({required this.amount});

  Map<String, dynamic> toJson() => {'amount': amount};
}

class CreateFinanceRecordRequest {
  final double amount;
  final String category;
  final String type;
  final String? description;

  CreateFinanceRecordRequest({
    required this.amount,
    required this.category,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'category': category,
    'type': type,
    'description': description,
  };
}

// Time Capsule DTOs
class CreateTimeCapsuleRequest {
  final String content;
  final DateTime openDate;

  CreateTimeCapsuleRequest({
    required this.content,
    required this.openDate,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'openDate': openDate.toIso8601String(),
  };
}

// Secret Message DTOs
class CreateSecretMessageRequest {
  final String content;
  final int? hoursToOpen;
  final DateTime? openDate;

  CreateSecretMessageRequest({
    required this.content,
    this.hoursToOpen,
    this.openDate,
  });

  Map<String, dynamic> toJson() => {
    'content': content,
    'hoursToOpen': hoursToOpen,
    'openDate': openDate?.toIso8601String(),
  };
}

// Love Map DTOs
class CreateLovePointRequest {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final List<String>? photoUrls;

  CreateLovePointRequest({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.photoUrls,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'photoUrls': photoUrls,
  };
}
