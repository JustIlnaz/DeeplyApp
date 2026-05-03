import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/memory_model.dart';
import '../data/models/event_model.dart';
import '../data/models/mood_model.dart';
import '../data/models/question_model.dart';
import '../data/models/challenge_model.dart';
import '../data/models/capsule_model.dart';
import '../data/models/secret_message_model.dart';
import '../data/models/love_map_model.dart';
import '../data/models/todo_model.dart';
import '../data/models/finance_model.dart';
import '../data/models/attachment_test_model.dart';

class FeaturesProvider extends ChangeNotifier {
  final _dio = DioClient.instance;

  List<MemoryModel> memories = [];
  List<EventModel> events = [];
  List<MoodModel> moodWeekly = [];
  QuestionModel? questionToday;
  List<ChallengeTemplateModel> challengeTemplates = [];
  ChallengeProgressModel? activeChallenge;
  List<CapsuleModel> openedCapsules = [];
  List<SecretMessageModel> secretMessages = [];
  List<SecretMessageModel> allSecretMessages = [];
  List<LoveMapPointModel> lovePoints = [];
  List<TodoModel> todos = [];
  FinanceSummaryModel? financeSummary;
  int closenessIndex = 0;
  bool myCheckinSubmitted = false;
  bool partnerCheckinSubmitted = false;
  MoodModel? todayMyMood;
  MoodModel? todayPartnerMood;
  AttachmentTestResultModel? attachmentTestResult;
  bool isLoading = false;
  String? error;

  // ── Memories ──────────────────────────────────────────────────────────────
  Future<void> fetchMemories() async {
    _load(true);
    try {
      final r = await _dio.get(ApiEndpoints.memories);
      memories = (r.data as List).map((e) => MemoryModel.fromJson(e)).toList();
    } on DioException catch (e) { error = e.message; }
    finally { _load(false); }
  }

  Future<bool> addMemory({String? text, File? photoFile, File? videoFile, bool isPinned = false}) async {
    try {
      final formData = FormData.fromMap({
        if (text != null) 'text': text,
        'isPinned': isPinned,
        if (photoFile != null)
          'photo': await MultipartFile.fromFile(photoFile.path, filename: photoFile.path.split('/').last),
        if (videoFile != null)
          'video': await MultipartFile.fromFile(videoFile.path, filename: videoFile.path.split('/').last),
      });
      final r = await _dio.post(
        ApiEndpoints.memories,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      memories.insert(0, MemoryModel.fromJson(r.data));
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<void> deleteMemory(int id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteMemory(id));
      memories.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (_) {}
  }

  // ── Events ────────────────────────────────────────────────────────────────
  Future<void> fetchEvents() async {
    try {
      final r = await _dio.get(ApiEndpoints.events);
      events = (r.data as List).map((e) => EventModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createEvent({
    required String title,
    String? description,
    required DateTime startsAt,
    DateTime? endsAt,
    DateTime? reminderAt,
  }) async {
    try {
      final r = await _dio.post(ApiEndpoints.events, data: {
        'title': title,
        if (description != null) 'description': description,
        'startsAtUtc': startsAt.toUtc().toIso8601String(),
        if (endsAt != null) 'endsAtUtc': endsAt.toUtc().toIso8601String(),
        if (reminderAt != null) 'reminderAtUtc': reminderAt.toUtc().toIso8601String(),
      });
      events.add(EventModel.fromJson(r.data));
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  // ── Mood ──────────────────────────────────────────────────────────────────
  Future<bool> addMood({required String moodType, String? comment}) async {
    try {
      await _dio.post(ApiEndpoints.mood, data: {
        'moodType': moodType,
        if (comment != null) 'comment': comment,
      });
      await fetchMoodWeekly();
      return true;
    } catch (_) { return false; }
  }

  Future<void> fetchMoodWeekly() async {
    try {
      final r = await _dio.get(ApiEndpoints.moodWeekly);
      moodWeekly = (r.data as List).map((e) => MoodModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  // ── Question ──────────────────────────────────────────────────────────────
  Future<void> fetchQuestionToday() async {
    try {
      final r = await _dio.get(ApiEndpoints.questionToday);
      questionToday = QuestionModel.fromJson(r.data);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> answerQuestion(int questionId, String answer) async {
    try {
      await _dio.post(ApiEndpoints.answerQuestion(questionId), data: {'answer': answer});
      await fetchQuestionToday();
      return true;
    } catch (_) { return false; }
  }

  // ── Check-in ──────────────────────────────────────────────────────────────
  Future<bool> submitCheckIn({
    required String whatWasGreat,
    required String whereWasTension,
    required String whatToImprove,
  }) async {
    try {
      await _dio.post(ApiEndpoints.checkin, data: {
        'whatWasGreat': whatWasGreat,
        'whereWasTension': whereWasTension,
        'whatToImprove': whatToImprove,
      });
      await fetchCheckinStatus();
      return true;
    } catch (_) { return false; }
  }

  Future<void> fetchCheckinStatus() async {
    try {
      final r = await _dio.get(ApiEndpoints.checkinStatus);
      myCheckinSubmitted = r.data['mySubmitted'] ?? false;
      partnerCheckinSubmitted = r.data['partnerSubmitted'] ?? false;
      notifyListeners();
    } catch (_) {}
  }

  // ── Challenges ────────────────────────────────────────────────────────────
  Future<void> fetchChallengeTemplates() async {
    try {
      final r = await _dio.get(ApiEndpoints.challengeTemplates);
      challengeTemplates = (r.data as List).map((e) => ChallengeTemplateModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> startChallenge(int templateId) async {
    try {
      await _dio.post(ApiEndpoints.startChallenge(templateId));
      return true;
    } catch (_) { return false; }
  }

  Future<bool> markChallengeDay(int challengeId, DateTime day) async {
    try {
      final dayStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      await _dio.post(ApiEndpoints.markChallengeDay(challengeId, dayStr));
      return true;
    } catch (_) { return false; }
  }

  Future<bool> completeChallenge(int challengeId) async {
    try {
      await _dio.post(ApiEndpoints.completeChallenge(challengeId));
      return true;
    } catch (_) { return false; }
  }

  Future<void> fetchActiveChallenge() async {
    try {
      final r = await _dio.get(ApiEndpoints.challengeActive);
      if (r.data != null) {
        activeChallenge = ChallengeProgressModel.fromJson(r.data);
      } else {
        activeChallenge = null;
      }
      notifyListeners();
    } catch (_) {}
  }

  // ── Capsule ───────────────────────────────────────────────────────────────
  Future<void> fetchOpenedCapsules() async {
    try {
      final r = await _dio.get(ApiEndpoints.openedCapsules);
      openedCapsules = (r.data as List).map((e) => CapsuleModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createCapsule({required String letter, required DateTime openAt}) async {
    try {
      await _dio.post(ApiEndpoints.capsules, data: {
        'letter': letter,
        'openAtUtc': openAt.toUtc().toIso8601String(),
      });
      return true;
    } catch (_) { return false; }
  }

  // ── Secret messages ───────────────────────────────────────────────────────
  Future<void> fetchSecretMessages() async {
    try {
      final r = await _dio.get(ApiEndpoints.secretMessages);
      secretMessages = (r.data as List).map((e) => SecretMessageModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchAllSecretMessages() async {
    try {
      final r = await _dio.get(ApiEndpoints.secretMessagesAll);
      allSecretMessages = (r.data as List).map((e) => SecretMessageModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createSecretMessage({required String message, required DateTime openAt}) async {
    try {
      await _dio.post(ApiEndpoints.secretMessages, data: {
        'message': message,
        'openAtUtc': openAt.toUtc().toIso8601String(),
      });
      return true;
    } catch (_) { return false; }
  }

  // ── Love map ──────────────────────────────────────────────────────────────
  Future<void> fetchLovePoints() async {
    try {
      final r = await _dio.get(ApiEndpoints.loveMapPoints);
      lovePoints = (r.data as List).map((e) => LoveMapPointModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addLovePoint({
    required double latitude,
    required double longitude,
    String? description,
    File? photoFile,
    String? address,
  }) async {
    try {
      final formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        if (description != null) 'description': description,
        if (address != null) 'address': address,
        if (photoFile != null)
          'photo': await MultipartFile.fromFile(photoFile.path, filename: photoFile.path.split('/').last),
      });
      final r = await _dio.post(
        ApiEndpoints.loveMapPoints,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      lovePoints.add(LoveMapPointModel.fromJson(r.data));
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  // ── Todos ─────────────────────────────────────────────────────────────────
  Future<void> fetchTodos() async {
    try {
      final r = await _dio.get(ApiEndpoints.todos);
      todos = (r.data as List).map((e) => TodoModel.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> createTodo({required String title, int? responsibleUserId}) async {
    try {
      final r = await _dio.post(ApiEndpoints.todos, data: {
        'title': title,
        if (responsibleUserId != null) 'responsibleUserId': responsibleUserId,
      });
      todos.add(TodoModel.fromJson(r.data));
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> updateTodoStatus(int id, bool isDone) async {
    try {
      final newStatus = isDone ? 'done' : 'todo';
      await _dio.patch(ApiEndpoints.updateTodoStatus(id), data: {'status': newStatus});
      final idx = todos.indexWhere((t) => t.id == id);
      if (idx != -1) {
        todos[idx] = TodoModel(
          id: todos[idx].id,
          title: todos[idx].title,
          responsibleUserId: todos[idx].responsibleUserId,
          status: newStatus,
        );
        notifyListeners();
      }
      return true;
    } catch (_) { return false; }
  }

  // ── Finance ───────────────────────────────────────────────────────────────
  Future<void> fetchFinanceSummary() async {
    try {
      final r = await _dio.get(ApiEndpoints.financeSummary);
      financeSummary = FinanceSummaryModel.fromJson(r.data);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> addFinanceRecord({
    required String type,
    required String category,
    required double amount,
    required DateTime date,
  }) async {
    try {
      await _dio.post(ApiEndpoints.financeRecords, data: {
        'type': type,
        'category': category,
        'amount': amount,
        'dateUtc': date.toUtc().toIso8601String(),
      });
      await fetchFinanceSummary();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> addFinanceGoal({required String title, required double targetAmount}) async {
    try {
      await _dio.post(ApiEndpoints.financeGoals, data: {
        'title': title,
        'targetAmount': targetAmount,
      });
      await fetchFinanceSummary();
      return true;
    } catch (_) { return false; }
  }

  // ── Closeness ─────────────────────────────────────────────────────────────
  Future<void> fetchClosenessIndex() async {
    try {
      final r = await _dio.get(ApiEndpoints.closenessIndex);
      closenessIndex = r.data['score'] ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  // ── Attachment test ────────────────────────────────────────────────────────
  Future<bool> submitAttachmentTest(List<int> answers) async {
    try {
      final r = await _dio.post(ApiEndpoints.attachmentTest, data: {'answers': answers});
      if (r.statusCode == 200 && r.data != null) {
        attachmentTestResult = AttachmentTestResultModel.fromJson(r.data);
        notifyListeners();
      }
      return true;
    } catch (_) { return false; }
  }

  Future<void> fetchAttachmentTestResult() async {
    try {
      final r = await _dio.get(ApiEndpoints.attachmentTestResult);
      if (r.statusCode == 200 && r.data != null) {
        attachmentTestResult = AttachmentTestResultModel.fromJson(r.data);
        notifyListeners();
      }
    } catch (_) {}
  }

  void _load(bool v) { isLoading = v; notifyListeners(); }
}
