import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/memory_entry.dart';
import '../../data/models/couple_event.dart';
import '../../data/models/mood_entry.dart';
import '../../data/models/daily_question.dart';
import '../../data/models/weekly_checkin.dart';
import '../../data/models/challenge.dart';
import '../../data/models/time_capsule.dart';
import '../../data/models/love_map_point.dart';
import '../../data/models/couple_todo.dart';
import '../../data/models/finance.dart';
import '../../data/models/dtos.dart';
import '../../data/services/feature_service.dart';
import 'service_providers.dart';

// Memory Provider
final memoriesProvider =
    StateNotifierProvider<MemoriesNotifier, AsyncValue<List<MemoryEntry>>>((
      ref,
    ) {
      final featureService = ref.watch(featureServiceProvider);
      return MemoriesNotifier(featureService);
    });

class MemoriesNotifier extends StateNotifier<AsyncValue<List<MemoryEntry>>> {
  final FeatureService featureService;

  MemoriesNotifier(this.featureService) : super(const AsyncValue.loading());

  Future<void> loadMemories({int skip = 0, int take = 50}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => featureService.getMemories(skip: skip, take: take),
    );
  }

  Future<void> createMemory(String? content, List<String>? photoUrls) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final memory = await featureService.createMemory(
        CreateMemoryRequest(content: content, photoUrls: photoUrls),
      );
      final currentMemories = state.maybeWhen(
        data: (list) => list,
        orElse: () => [],
      );
      return [memory, ...currentMemories];
    });
  }

  Future<void> deleteMemory(String memoryId) async {
    await featureService.deleteMemory(memoryId);
    state.whenData((memories) {
      state = AsyncValue.data(memories.where((m) => m.id != memoryId).toList());
    });
  }

  Future<void> togglePin(String memoryId) async {
    await featureService.togglePinMemory(memoryId);
    state.whenData((memories) {
      state = AsyncValue.data(
        memories
            .map(
              (m) => m.id == memoryId
                  ? MemoryEntry(
                      id: m.id,
                      coupleId: m.coupleId,
                      createdById: m.createdById,
                      content: m.content,
                      photoUrls: m.photoUrls,
                      isPinned: !m.isPinned,
                      createdAt: m.createdAt,
                      updatedAt: m.updatedAt,
                    )
                  : m,
            )
            .toList(),
      );
    });
  }
}

// Events Provider
final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<CoupleEvent>>>((ref) {
      final featureService = ref.watch(featureServiceProvider);
      return EventsNotifier(featureService);
    });

class EventsNotifier extends StateNotifier<AsyncValue<List<CoupleEvent>>> {
  final FeatureService featureService;

  EventsNotifier(this.featureService) : super(const AsyncValue.loading());

  Future<void> loadEvents({DateTime? from, DateTime? to}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => featureService.getEvents(from: from, to: to),
    );
  }

  Future<void> createEvent(
    String title,
    String? description,
    DateTime eventDate, {
    bool? isAnniversary,
  }) async {
    state = await AsyncValue.guard(() async {
      final event = await featureService.createEvent(
        CreateEventRequest(
          title: title,
          description: description,
          eventDate: eventDate,
          isAnniversary: isAnniversary,
        ),
      );
      final currentEvents = state.maybeWhen(
        data: (list) => list,
        orElse: () => [],
      );
      return [event, ...currentEvents];
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await featureService.deleteEvent(eventId);
    state.whenData((events) {
      state = AsyncValue.data(events.where((e) => e.id != eventId).toList());
    });
  }
}

// Moods Provider
final moodsProvider =
    StateNotifierProvider<MoodsNotifier, AsyncValue<List<MoodEntry>>>((ref) {
      final featureService = ref.watch(featureServiceProvider);
      return MoodsNotifier(featureService);
    });

class MoodsNotifier extends StateNotifier<AsyncValue<List<MoodEntry>>> {
  final FeatureService featureService;

  MoodsNotifier(this.featureService) : super(const AsyncValue.loading());

  Future<void> loadMoods({DateTime? from, DateTime? to}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => featureService.getMoodEntries(from: from, to: to),
    );
  }

  Future<void> createMood(String mood, String? comment) async {
    state = await AsyncValue.guard(() async {
      final moodEntry = await featureService.createMood(
        CreateMoodRequest(mood: mood, comment: comment),
      );
      final currentMoods = state.maybeWhen(
        data: (list) => list,
        orElse: () => [],
      );
      return [moodEntry, ...currentMoods];
    });
  }
}

// Daily Questions Provider
final dailyQuestionProvider = FutureProvider<DailyQuestion>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getTodayQuestion();
});

final questionAnswerProvider =
    StateNotifierProvider<
      QuestionAnswerNotifier,
      AsyncValue<DailyQuestionAnswer>
    >((ref) {
      final featureService = ref.watch(featureServiceProvider);
      return QuestionAnswerNotifier(featureService);
    });

class QuestionAnswerNotifier
    extends StateNotifier<AsyncValue<DailyQuestionAnswer>> {
  final FeatureService featureService;

  QuestionAnswerNotifier(this.featureService)
    : super(const AsyncValue.loading());

  Future<void> answerQuestion(String questionId, String answer) async {
    state = await AsyncValue.guard(
      () => featureService.answerQuestion(
        questionId,
        AnswerQuestionRequest(answer: answer),
      ),
    );
  }
}

// Weekly CheckIn Provider
final weeklyCheckInProvider =
    StateNotifierProvider<WeeklyCheckInNotifier, AsyncValue<WeeklyCheckIn?>>((
      ref,
    ) {
      final featureService = ref.watch(featureServiceProvider);
      return WeeklyCheckInNotifier(featureService);
    });

class WeeklyCheckInNotifier extends StateNotifier<AsyncValue<WeeklyCheckIn?>> {
  final FeatureService featureService;

  WeeklyCheckInNotifier(this.featureService)
    : super(const AsyncValue.data(null));

  Future<void> loadCheckIn(DateTime weekStartDate) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => featureService.getWeeklyCheckIn(weekStartDate),
    );
  }

  Future<void> submitCheckIn(
    String whatWasGreat,
    String whereWasTension,
    String whatCanBeImproved,
  ) async {
    state = await AsyncValue.guard(
      () => featureService.submitWeeklyCheckIn(
        WeeklyCheckInRequest(
          whatWasGreat: whatWasGreat,
          whereWasTension: whereWasTension,
          whatCanBeImproved: whatCanBeImproved,
        ),
      ),
    );
  }
}

// Challenges Provider
final activeChallengesProvider = FutureProvider<List<CoupleChallenge>>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getActiveChallenges();
});

final challengeTemplatesProvider = FutureProvider<List<ChallengeTemplate>>((
  ref,
) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getChallengeTemplates();
});

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, AsyncValue<CoupleChallenge?>>((
      ref,
    ) {
      final featureService = ref.watch(featureServiceProvider);
      return ChallengeNotifier(featureService);
    });

class ChallengeNotifier extends StateNotifier<AsyncValue<CoupleChallenge?>> {
  final FeatureService featureService;

  ChallengeNotifier(this.featureService) : super(const AsyncValue.data(null));

  Future<void> startChallenge(String templateId) async {
    state = await AsyncValue.guard(
      () => featureService.startChallenge(templateId),
    );
  }

  Future<void> updateProgress(String challengeId, int progress) async {
    state = await AsyncValue.guard(
      () => featureService.updateChallengeProgress(challengeId, progress),
    );
  }
}

// Time Capsules Provider
final timCapsulesProvider = FutureProvider<List<TimeCapsule>>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getTimeCapsules();
});

final createTimeCapsuleProvider =
    StateNotifierProvider<CreateTimeCapsuleNotifier, AsyncValue<TimeCapsule?>>((
      ref,
    ) {
      final featureService = ref.watch(featureServiceProvider);
      return CreateTimeCapsuleNotifier(featureService);
    });

class CreateTimeCapsuleNotifier
    extends StateNotifier<AsyncValue<TimeCapsule?>> {
  final FeatureService featureService;

  CreateTimeCapsuleNotifier(this.featureService)
    : super(const AsyncValue.data(null));

  Future<void> createCapsule(String content, DateTime openDate) async {
    state = await AsyncValue.guard(
      () => featureService.createTimeCapsule(
        CreateTimeCapsuleRequest(content: content, openDate: openDate),
      ),
    );
  }
}

// Secret Messages Provider
final secretMessagesProvider = FutureProvider<List<SecretMessage>>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getSecretMessages();
});

final createSecretMessageProvider =
    StateNotifierProvider<
      CreateSecretMessageNotifier,
      AsyncValue<SecretMessage?>
    >((ref) {
      final featureService = ref.watch(featureServiceProvider);
      return CreateSecretMessageNotifier(featureService);
    });

class CreateSecretMessageNotifier
    extends StateNotifier<AsyncValue<SecretMessage?>> {
  final FeatureService featureService;

  CreateSecretMessageNotifier(this.featureService)
    : super(const AsyncValue.data(null));

  Future<void> createMessage(
    String content, {
    int? hoursToOpen,
    DateTime? openDate,
  }) async {
    state = await AsyncValue.guard(
      () => featureService.createSecretMessage(
        CreateSecretMessageRequest(
          content: content,
          hoursToOpen: hoursToOpen,
          openDate: openDate,
        ),
      ),
    );
  }
}

// Love Map Points Provider
final loveMapPointsProvider = FutureProvider<List<LoveMapPoint>>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getLoveMapPoints();
});

final createLovePointProvider =
    StateNotifierProvider<CreateLovePointNotifier, AsyncValue<LoveMapPoint?>>((
      ref,
    ) {
      final featureService = ref.watch(featureServiceProvider);
      return CreateLovePointNotifier(featureService);
    });

class CreateLovePointNotifier extends StateNotifier<AsyncValue<LoveMapPoint?>> {
  final FeatureService featureService;

  CreateLovePointNotifier(this.featureService)
    : super(const AsyncValue.data(null));

  Future<void> createPoint(
    String title,
    String description,
    double latitude,
    double longitude, {
    List<String>? photoUrls,
  }) async {
    state = await AsyncValue.guard(
      () => featureService.createLovePoint(
        CreateLovePointRequest(
          title: title,
          description: description,
          latitude: latitude,
          longitude: longitude,
          photoUrls: photoUrls,
        ),
      ),
    );
  }
}

// Todos Provider
final todosProvider = FutureProvider<List<CoupleTodo>>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getTodos();
});

final createTodoProvider =
    StateNotifierProvider<CreateTodoNotifier, AsyncValue<CoupleTodo?>>((ref) {
      final featureService = ref.watch(featureServiceProvider);
      return CreateTodoNotifier(featureService);
    });

class CreateTodoNotifier extends StateNotifier<AsyncValue<CoupleTodo?>> {
  final FeatureService featureService;

  CreateTodoNotifier(this.featureService) : super(const AsyncValue.data(null));

  Future<void> createTodo(
    String title, {
    String? description,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    state = await AsyncValue.guard(
      () => featureService.createTodo(
        CreateTodoRequest(
          title: title,
          description: description,
          assignedTo: assignedTo,
          dueDate: dueDate,
        ),
      ),
    );
  }

  Future<void> updateStatus(String todoId, String status) async {
    await featureService.updateTodoStatus(
      todoId,
      UpdateTodoStatusRequest(status: status),
    );
  }
}

// Finance Goals Provider
final financeGoalsProvider = FutureProvider<List<FinanceGoal>>((ref) {
  final featureService = ref.watch(featureServiceProvider);
  return featureService.getFinanceGoals();
});

final createFinanceGoalProvider =
    StateNotifierProvider<CreateFinanceGoalNotifier, AsyncValue<FinanceGoal?>>((
      ref,
    ) {
      final featureService = ref.watch(featureServiceProvider);
      return CreateFinanceGoalNotifier(featureService);
    });

class CreateFinanceGoalNotifier
    extends StateNotifier<AsyncValue<FinanceGoal?>> {
  final FeatureService featureService;

  CreateFinanceGoalNotifier(this.featureService)
    : super(const AsyncValue.data(null));

  Future<void> createGoal(
    String title,
    double targetAmount,
    String category,
    DateTime targetDate,
  ) async {
    state = await AsyncValue.guard(
      () => featureService.createFinanceGoal(
        CreateFinanceGoalRequest(
          title: title,
          targetAmount: targetAmount,
          category: category,
          targetDate: targetDate,
        ),
      ),
    );
  }

  Future<void> updateProgress(String goalId, double amount) async {
    state = await AsyncValue.guard(
      () => featureService.updateFinanceGoalProgress(
        goalId,
        UpdateFinanceGoalProgressRequest(amount: amount),
      ),
    );
  }
}

// Finance Records Provider
final financeRecordsProvider =
    FutureProvider.family<
      List<FinanceRecord>,
      ({DateTime? from, DateTime? to})
    >((ref, params) {
      final featureService = ref.watch(featureServiceProvider);
      return featureService.getFinanceRecords(from: params.from, to: params.to);
    });

final createFinanceRecordProvider =
    StateNotifierProvider<
      CreateFinanceRecordNotifier,
      AsyncValue<FinanceRecord?>
    >((ref) {
      final featureService = ref.watch(featureServiceProvider);
      return CreateFinanceRecordNotifier(featureService);
    });

class CreateFinanceRecordNotifier
    extends StateNotifier<AsyncValue<FinanceRecord?>> {
  final FeatureService featureService;

  CreateFinanceRecordNotifier(this.featureService)
    : super(const AsyncValue.data(null));

  Future<void> createRecord(
    double amount,
    String category,
    String type, {
    String? description,
  }) async {
    state = await AsyncValue.guard(
      () => featureService.createFinanceRecord(
        CreateFinanceRecordRequest(
          amount: amount,
          category: category,
          type: type,
          description: description,
        ),
      ),
    );
  }
}
