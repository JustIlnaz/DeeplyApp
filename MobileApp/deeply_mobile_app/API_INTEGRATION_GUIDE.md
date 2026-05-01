# Deeply Mobile App - API Integration Guide

## Структура проекта

### Архитектура слоев:
```
lib/
├── core/
│   ├── network/
│   │   ├── dio_client.dart         # Конфигурация Dio с интерцепторами
│   │   └── api_exception.dart      # Обработка ошибок API
│   └── providers/
│       ├── service_providers.dart   # Базовые провайдеры сервисов
│       ├── auth_provider.dart       # Авторизация
│       ├── couple_provider.dart     # Управление парой
│       ├── chat_provider.dart       # Чат
│       └── features_provider.dart   # Все остальные фичи
├── data/
│   ├── models/                      # Модели данных
│   ├── services/                    # Сервисы для работы с API
│   └── data.dart                    # Экспорт всех моделей и сервисов
├── screens/                         # UI экраны
├── widgets/                         # Переиспользуемые виджеты
└── main.dart                        # Точка входа с ProviderScope
```

## Установка зависимостей

```bash
flutter pub get
```

## Конфигурация

### 1. Обновить базовый URL в `dio_client.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### 2. Обновить эндпоинты в сервисах при необходимости

## Примеры использования

### Авторизация

```dart
// Регистрация
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.register('email@example.com', 'password', 'Name');

// Логин
await authNotifier.login('email@example.com', 'password');

// Логаут
await authNotifier.logout();

// Обновление токена
await authNotifier.refresh();
```

### Чтение состояния авторизации

```dart
final authState = ref.watch(authProvider);

if (authState.isLoading) {
  return const CircularProgressIndicator();
} else if (authState.isAuthenticated) {
  return Text('Добро пожаловать!');
} else if (authState.error != null) {
  return Text('Ошибка: ${authState.error}');
}
```

### Работа с парой

```dart
// Создать пару
final coupleNotifier = ref.read(coupleProvider.notifier);
await coupleNotifier.createCouple('Наша любовь');

// Загрузить свою пару
await coupleNotifier.loadCouple();

// Присоединиться к паре
await coupleNotifier.joinCouple('COUPLE_CODE');

// Читать состояние
final coupleState = ref.watch(coupleProvider);
final couple = coupleState.couple;
```

### Работа с чатом

```dart
// Загрузить сообщения
final chatNotifier = ref.read(chatProvider.notifier);
await chatNotifier.loadMessages(skip: 0, take: 50);

// Отправить сообщение
await chatNotifier.sendMessage('Привет!');

// С фото
await chatNotifier.sendMessage('Смотри!', attachmentUrls: ['https://example.com/photo.jpg']);

// Отметить как прочитано
await chatNotifier.markAsRead(messageId);

// Читать сообщения
final messages = ref.watch(chatProvider).messages;
```

### Работа с воспоминаниями

```dart
final featureService = ref.read(featureServiceProvider);

// Загрузить воспоминания
final memoriesNotifier = ref.read(memoriesProvider.notifier);
await memoriesNotifier.loadMemories(skip: 0, take: 50);

// Создать воспоминание
await memoriesNotifier.createMemory(
  'Прекрасный день',
  photoUrls: ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'],
);

// Удалить воспоминание
await memoriesNotifier.deleteMemory(memoryId);

// Закрепить/открепить
await memoriesNotifier.togglePin(memoryId);

// Читать воспоминания
final memories = ref.watch(memoriesProvider);
```

### Работа с событиями

```dart
final eventsNotifier = ref.read(eventsProvider.notifier);

// Загрузить события за период
await eventsNotifier.loadEvents(
  from: DateTime.now(),
  to: DateTime.now().add(Duration(days: 30)),
);

// Создать событие
await eventsNotifier.createEvent(
  'День рождения партнёра',
  'Не забыть подарок',
  DateTime(2026, 6, 15),
  isAnniversary: false,
);

// Удалить событие
await eventsNotifier.deleteEvent(eventId);

// Читать события
final events = ref.watch(eventsProvider);
```

### Работа с настроением

```dart
final moodsNotifier = ref.read(moodsProvider.notifier);

// Загрузить записи о настроении за неделю
await moodsNotifier.loadMoods(
  from: DateTime.now().subtract(Duration(days: 7)),
  to: DateTime.now(),
);

// Записать настроение
await moodsNotifier.createMood(
  'поддержка', // или 'внимание', 'усталость' и т.д.
  'Нужна помощь с проектом',
);

// Читать настроения
final moods = ref.watch(moodsProvider);
```

### Ежедневный вопрос

```dart
// Получить вопрос на сегодня
final questionAsync = ref.watch(dailyQuestionProvider);

questionAsync.when(
  data: (question) => Text(question.question),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Ошибка: $err'),
);

// Ответить на вопрос
final answerNotifier = ref.read(questionAnswerProvider.notifier);
await answerNotifier.answerQuestion(questionId, 'Мой ответ');
```

### Еженедельный чек-ин

```dart
final checkInNotifier = ref.read(weeklyCheckInProvider.notifier);

// Загрузить чек-ин
final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
await checkInNotifier.loadCheckIn(weekStart);

// Отправить чек-ин
await checkInNotifier.submitCheckIn(
  'Прекрасная неделя вместе',
  'Было напряжение на работе',
  'Больше времени для общения',
);

// Читать
final checkIn = ref.watch(weeklyCheckInProvider);
```

### Челленджи

```dart
// Получить доступные челленджи
final templates = ref.watch(challengeTemplatesProvider);

// Начать челленж
final challengeNotifier = ref.read(challengeProvider.notifier);
await challengeNotifier.startChallenge(templateId);

// Обновить прогресс
await challengeNotifier.updateProgress(challengeId, 5);

// Получить активные
final active = ref.watch(activeChallengesProvider);
```

### Капсула времени

```dart
// Получить все капсулы
final capsules = ref.watch(timCapsulesProvider);

// Создать новую
final createNotifier = ref.read(createTimeCapsuleProvider.notifier);
await createNotifier.createCapsule(
  'Письмо из прошлого',
  DateTime.now().add(Duration(days: 365)),
);
```

### Тайные сообщения

```dart
// Получить сообщения
final secrets = ref.watch(secretMessagesProvider);

// Создать сообщение (откроется через 12 часов)
final secretNotifier = ref.read(createSecretMessageProvider.notifier);
await secretNotifier.createMessage(
  'Сюрприз! 🎁',
  hoursToOpen: 12,
);

// Или на определённую дату
await secretNotifier.createMessage(
  'Письмо ко Дню святого Валентина',
  openDate: DateTime(2027, 2, 14),
);
```

### Love Map

```dart
// Получить все точки
final points = ref.watch(loveMapPointsProvider);

// Добавить новую точку
final mapNotifier = ref.read(createLovePointProvider.notifier);
await mapNotifier.createPoint(
  'Наше первое кафе',
  'Именно здесь мы впервые поцеловались',
  40.7128,
  -74.0060,
  photoUrls: ['https://example.com/photo.jpg'],
);
```

### Совместные задачи

```dart
// Получить все задачи
final todos = ref.watch(todosProvider);

// Создать задачу
final todoNotifier = ref.read(createTodoProvider.notifier);
await todoNotifier.createTodo(
  'Купить продукты',
  description: 'Для ужина',
  assignedTo: partnerId, // или null если для обоих
  dueDate: DateTime.now().add(Duration(days: 1)),
);

// Обновить статус
await todoNotifier.updateStatus(todoId, 'completed');
```

### Финансы

```dart
// Получить цели
final goals = ref.watch(financeGoalsProvider);

// Создать цель
final goalNotifier = ref.read(createFinanceGoalProvider.notifier);
await goalNotifier.createGoal(
  'Медовый месяц в Париже',
  5000.0,
  'travel',
  DateTime(2027, 6, 1),
);

// Обновить прогресс цели
await goalNotifier.updateProgress(goalId, 1000.0);

// Получить записи за период
final records = ref.watch(
  financeRecordsProvider((
    from: DateTime.now().subtract(Duration(days: 30)),
    to: DateTime.now(),
  )),
);

// Добавить расход
final recordNotifier = ref.read(createFinanceRecordProvider.notifier);
await recordNotifier.createRecord(
  50.0,
  'restaurant',
  'expense',
  description: 'Ужин в ресторане',
);
```

## Обработка ошибок

Все сервисы выбрасывают `ApiException`, которое можно перехватить:

```dart
try {
  await authNotifier.login('email', 'password');
} on ApiException catch (e) {
  print('Ошибка API: ${e.message}');
  print('Статус: ${e.statusCode}');
}
```

## Логирование

Все запросы и ответы автоматически логируются через `Logger`. Настройте уровень логирования в `LoggingInterceptor`.

## Автоматические повторы

Неудачные запросы (кроме POST) автоматически повторяются до 3 раз при ошибках сети.

## Следующие шаги

1. Добавить обработку SignalR для реал-тайм чата
2. Добавить загрузку файлов (фото, видео)
3. Добавить локальное кэширование
4. Добавить offline-first функциональность
5. Добавить тесты для сервисов и провайдеров
