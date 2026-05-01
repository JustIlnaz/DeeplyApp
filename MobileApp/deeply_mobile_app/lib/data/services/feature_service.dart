import 'package:dio/dio.dart';
import '../models/memory_entry.dart';
import '../models/couple_event.dart';
import '../models/mood_entry.dart';
import '../models/daily_question.dart';
import '../models/weekly_checkin.dart';
import '../models/challenge.dart';
import '../models/time_capsule.dart';
import '../models/love_map_point.dart';
import '../models/couple_todo.dart';
import '../models/finance.dart';
import '../models/dtos.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';

abstract class FeatureService {
  // Memory
  Future<List<MemoryEntry>> getMemories({int? skip, int? take});
  Future<MemoryEntry> createMemory(CreateMemoryRequest request);
  Future<void> deleteMemory(String memoryId);
  Future<void> togglePinMemory(String memoryId);

  // Events
  Future<List<CoupleEvent>> getEvents({DateTime? from, DateTime? to});
  Future<CoupleEvent> createEvent(CreateEventRequest request);
  Future<void> deleteEvent(String eventId);

  // Mood
  Future<List<MoodEntry>> getMoodEntries({DateTime? from, DateTime? to});
  Future<MoodEntry> createMood(CreateMoodRequest request);

  // Daily Questions
  Future<DailyQuestion> getTodayQuestion();
  Future<DailyQuestionAnswer> answerQuestion(
    String questionId,
    AnswerQuestionRequest request,
  );

  // Weekly CheckIn
  Future<WeeklyCheckIn> getWeeklyCheckIn(DateTime weekStartDate);
  Future<WeeklyCheckIn> submitWeeklyCheckIn(WeeklyCheckInRequest request);

  // Challenges
  Future<List<CoupleChallenge>> getActiveChallenges();
  Future<List<ChallengeTemplate>> getChallengeTemplates();
  Future<CoupleChallenge> startChallenge(String templateId);
  Future<CoupleChallenge> updateChallengeProgress(
    String challengeId,
    int progress,
  );

  // Time Capsule
  Future<List<TimeCapsule>> getTimeCapsules();
  Future<TimeCapsule> createTimeCapsule(CreateTimeCapsuleRequest request);

  // Secret Messages
  Future<List<SecretMessage>> getSecretMessages();
  Future<SecretMessage> createSecretMessage(CreateSecretMessageRequest request);

  // Love Map
  Future<List<LoveMapPoint>> getLoveMapPoints();
  Future<LoveMapPoint> createLovePoint(CreateLovePointRequest request);

  // Todos
  Future<List<CoupleTodo>> getTodos();
  Future<CoupleTodo> createTodo(CreateTodoRequest request);
  Future<void> updateTodoStatus(String todoId, UpdateTodoStatusRequest request);

  // Finance
  Future<List<FinanceGoal>> getFinanceGoals();
  Future<FinanceGoal> createFinanceGoal(CreateFinanceGoalRequest request);
  Future<FinanceGoal> updateFinanceGoalProgress(
    String goalId,
    UpdateFinanceGoalProgressRequest request,
  );
  Future<List<FinanceRecord>> getFinanceRecords({DateTime? from, DateTime? to});
  Future<FinanceRecord> createFinanceRecord(CreateFinanceRecordRequest request);
}

class FeatureServiceImpl implements FeatureService {
  final DioClient _dioClient;

  FeatureServiceImpl(this._dioClient);

  @override
  Future<List<MemoryEntry>> getMemories({int? skip, int? take}) async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/memories',
        queryParameters: {
          'skip': ?skip,
          'take': ?take,
        },
      );
      final data = response.data ?? [];
      return data
          .map((item) => MemoryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MemoryEntry> createMemory(CreateMemoryRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/memories',
        data: request.toJson(),
      );
      return MemoryEntry.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteMemory(String memoryId) async {
    try {
      await _dioClient.delete('/features/memories/$memoryId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> togglePinMemory(String memoryId) async {
    try {
      await _dioClient.put('/features/memories/$memoryId/toggle-pin');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<CoupleEvent>> getEvents({DateTime? from, DateTime? to}) async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/events',
        queryParameters: {
          if (from != null) 'from': from.toIso8601String(),
          if (to != null) 'to': to.toIso8601String(),
        },
      );
      final data = response.data ?? [];
      return data
          .map((item) => CoupleEvent.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CoupleEvent> createEvent(CreateEventRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/events',
        data: request.toJson(),
      );
      return CoupleEvent.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _dioClient.delete('/features/events/$eventId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<MoodEntry>> getMoodEntries({DateTime? from, DateTime? to}) async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/moods',
        queryParameters: {
          if (from != null) 'from': from.toIso8601String(),
          if (to != null) 'to': to.toIso8601String(),
        },
      );
      final data = response.data ?? [];
      return data
          .map((item) => MoodEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<MoodEntry> createMood(CreateMoodRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/moods',
        data: request.toJson(),
      );
      return MoodEntry.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<DailyQuestion> getTodayQuestion() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/features/daily-questions/today',
      );
      return DailyQuestion.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<DailyQuestionAnswer> answerQuestion(
    String questionId,
    AnswerQuestionRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/daily-questions/$questionId/answer',
        data: request.toJson(),
      );
      return DailyQuestionAnswer.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<WeeklyCheckIn> getWeeklyCheckIn(DateTime weekStartDate) async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/features/weekly-checkin',
        queryParameters: {'weekStartDate': weekStartDate.toIso8601String()},
      );
      return WeeklyCheckIn.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<WeeklyCheckIn> submitWeeklyCheckIn(
    WeeklyCheckInRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/weekly-checkin',
        data: request.toJson(),
      );
      return WeeklyCheckIn.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<CoupleChallenge>> getActiveChallenges() async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/challenges/active',
      );
      final data = response.data ?? [];
      return data
          .map((item) => CoupleChallenge.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<ChallengeTemplate>> getChallengeTemplates() async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/challenges/templates',
      );
      final data = response.data ?? [];
      return data
          .map(
            (item) => ChallengeTemplate.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CoupleChallenge> startChallenge(String templateId) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/challenges/$templateId/start',
      );
      return CoupleChallenge.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CoupleChallenge> updateChallengeProgress(
    String challengeId,
    int progress,
  ) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        '/features/challenges/$challengeId/progress',
        data: {'progress': progress},
      );
      return CoupleChallenge.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<TimeCapsule>> getTimeCapsules() async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/time-capsules',
      );
      final data = response.data ?? [];
      return data
          .map((item) => TimeCapsule.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<TimeCapsule> createTimeCapsule(
    CreateTimeCapsuleRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/time-capsules',
        data: request.toJson(),
      );
      return TimeCapsule.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<SecretMessage>> getSecretMessages() async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/secret-messages',
      );
      final data = response.data ?? [];
      return data
          .map((item) => SecretMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<SecretMessage> createSecretMessage(
    CreateSecretMessageRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/secret-messages',
        data: request.toJson(),
      );
      return SecretMessage.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<LoveMapPoint>> getLoveMapPoints() async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/love-map',
      );
      final data = response.data ?? [];
      return data
          .map((item) => LoveMapPoint.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<LoveMapPoint> createLovePoint(CreateLovePointRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/love-map',
        data: request.toJson(),
      );
      return LoveMapPoint.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<CoupleTodo>> getTodos() async {
    try {
      final response = await _dioClient.get<List<dynamic>>('/features/todos');
      final data = response.data ?? [];
      return data
          .map((item) => CoupleTodo.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<CoupleTodo> createTodo(CreateTodoRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/todos',
        data: request.toJson(),
      );
      return CoupleTodo.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> updateTodoStatus(
    String todoId,
    UpdateTodoStatusRequest request,
  ) async {
    try {
      await _dioClient.put('/features/todos/$todoId', data: request.toJson());
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<FinanceGoal>> getFinanceGoals() async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/finance/goals',
      );
      final data = response.data ?? [];
      return data
          .map((item) => FinanceGoal.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<FinanceGoal> createFinanceGoal(
    CreateFinanceGoalRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/finance/goals',
        data: request.toJson(),
      );
      return FinanceGoal.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<FinanceGoal> updateFinanceGoalProgress(
    String goalId,
    UpdateFinanceGoalProgressRequest request,
  ) async {
    try {
      final response = await _dioClient.put<Map<String, dynamic>>(
        '/features/finance/goals/$goalId/progress',
        data: request.toJson(),
      );
      return FinanceGoal.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<FinanceRecord>> getFinanceRecords({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _dioClient.get<List<dynamic>>(
        '/features/finance/records',
        queryParameters: {
          if (from != null) 'from': from.toIso8601String(),
          if (to != null) 'to': to.toIso8601String(),
        },
      );
      final data = response.data ?? [];
      return data
          .map((item) => FinanceRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<FinanceRecord> createFinanceRecord(
    CreateFinanceRecordRequest request,
  ) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/features/finance/records',
        data: request.toJson(),
      );
      return FinanceRecord.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
