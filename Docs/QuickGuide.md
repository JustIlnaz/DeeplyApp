# DeeplyApp - Краткая шпаргалка

## Основные компоненты

### Controllers
HTTP endpoints, которые получают запросы от клиентов и вызывают сервисы.
Файлы: AuthController.cs, ChatController.cs, CouplesController.cs, FeaturesController.cs

### Services
Содержат бизнес-логику. Каждый service отвечает за конкретную область:
- AuthService - регистрация и вход
- ChatService - сообщения чата
- CoupleService - управление парами
- FeatureService - остальные функции

### Models
Сущности базы данных, которые отображаются на таблицы в PostgreSQL.
Примеры: User, Couple, ChatMessage, MemoryEntry, MoodEntry

### Requests
DTO (Data Transfer Objects) для входящих данных от клиента.
Используются для валидации и преобразования в Models.

### AppDbContext
Entity Framework контекст. Управляет подключением к БД и миграциями.

---

## SignalR - Real-time чат

SignalR позволяет серверу отправлять сообщения клиентам в реальном времени через WebSocket.

### Как работает:
1. Клиент подключается к ChatHub через WebSocket
2. Клиент отправляет сообщение методом SendMessage()
3. Сервер сохраняет сообщение в БД
4. Сервер отправляет сообщение всем клиентам пары через Clients.Group()
5. Все клиенты получают обновление мгновенно

### Основной код ChatHub:
- OnConnectedAsync() - вызывается при подключении
- SendMessage() - получает сообщение от клиента
- OnDisconnectedAsync() - вызывается при отключении

### На клиенте:
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/hubs/chat")
    .build();

connection.on("receiveMessage", (message) => { ... });
connection.invoke("SendMessage", coupleId, content);

### Преимущества:
- Низкая задержка (100-200мс вместо 5-10 сек)
- Двусторонняя коммуникация
- Автоматическое переподключение

---

## Hangfire - Фоновые задачи

Hangfire позволяет выполнять задачи в фоне, не блокируя HTTP запрос.

### Типы задач:

1. Fire-and-forget (сразу):
BackgroundJob.Enqueue(() => SendEmail(...));

2. Delayed (через некоторое время):
BackgroundJob.Schedule(() => SendReminder(...), TimeSpan.FromMinutes(5));

3. Recurring (по расписанию):
RecurringJob.AddOrUpdate("job-id", () => SendDailyQuestion(), Cron.Daily(9));

### Примеры:
- Отправка email-ов
- Отправка push-уведомлений
- Проверка открытых капсул (каждый час)
- Отправка ежедневного вопроса (каждый день в 9:00)
- Отправка еженедельного напоминания (каждый понедельник)

### Как настроить:
В Program.cs:
builder.Services.AddHangfire(...);
builder.Services.AddHangfireServer();
app.UseHangfireDashboard("/hangfire");

### Dashboard:
https://localhost:5000/hangfire - смотрите историю задач

### Преимущества:
- Не блокирует основной процесс
- Задачи сохраняются в БД
- Автоматический retry при ошибке
- Можно посмотреть историю выполнения

---

## JWT - Аутентификация

JWT - подписанный токен, который сервер отправляет клиенту при входе.

### Структура токена:
header.payload.signature

Например:
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImVtYWlsIjoiand0QGV4YW1wbGUuY29tIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

### Как это работает:
1. Клиент отправляет email и пароль
2. Сервер проверяет и создает JWT
3. Клиент отправляет JWT с каждым запросом: Authorization: Bearer {token}
4. Сервер проверяет подпись и извлекает userId

### Access vs Refresh токены:
- Access token - короткоживущий (1 час), используется для запросов
- Refresh token - долгоживущий (7 дней), используется для получения нового access токена

### Преимущества:
- Stateless - сервер не хранит сеансы
- Масштабируемость - несколько серверов могут проверить токен
- CORS-friendly

---

## Основные API endpoints

### Аутентификация
POST /api/auth/register - регистрация
POST /api/auth/login - вход
POST /api/auth/refresh - обновить токен

### Пары
POST /api/couples/create - создать пару
POST /api/couples/join - присоединиться к паре

### Функции (требуется Authorization header)
POST /api/features/memories - добавить память
GET /api/features/memories - получить памяти
POST /api/features/mood - добавить настроение
GET /api/features/mood/weekly - статистика настроения за неделю
GET /api/features/question/today - получить ежедневный вопрос
POST /api/features/question/{id}/answer - ответить на вопрос
GET /api/features/challenges/templates - список челленджей
POST /api/features/challenges/start - начать челленж

---

## Dependency Injection (DI)

DI - паттерн, при котором класс получает зависимости через конструктор.

### Без DI (плохо):
public class UserController
{
    private UserService _service = new UserService();
}

### С DI (хорошо):
public class UserController
{
    public UserController(IUserService service)
    {
        _service = service;
    }
}

### Регистрация в Program.cs:
builder.Services.AddScoped<IAuthService, AuthService>();

### Преимущества:
- Легче тестировать
- Легче менять реализацию
- Более модульный код

---

## DTO (Data Transfer Objects)

DTO - класс для передачи данных между клиентом и сервером.

### Пример:
// DTO от клиента
public class CreateMemoryRequest
{
    public string Title { get; set; }
    public string Description { get; set; }
    public byte[] Photo { get; set; }
    public DateOnly EntryDate { get; set; }
}

// Model для БД
public class MemoryEntry
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int CoupleId { get; set; }
    // ... остальные поля
}

### Преимущества:
- Валидация входящих данных
- Не передаешь лишние данные из БД
- Явный контракт API

---

## Архитектура слои (N-Tier)

Controllers
    |
    v
Services (бизнес-логика)
    |
    v
Entity Framework (ORM)
    |
    v
PostgreSQL (база данных)

Каждый слой отвечает за свою область и не знает деталей других слоев.

---

## Полезные команды

# Создать миграцию
dotnet ef migrations add MigrationName

# Применить миграцию
dotnet ef database update

# Откатить миграцию
dotnet ef database update PreviousMigrationName

# Запустить приложение
dotnet run

# Запустить тесты
dotnet test

---

## Файлы которые изменяешь часто

Program.cs - конфигурация DI, Hangfire, SignalR
appsettings.json - настройки (связь с БД, JWT)
Controllers/* - HTTP endpoints
Services/* - бизнес-логика
Models/* - сущности БД

---

## Полезные ссылки в приложении

API Swagger: https://localhost:5000/swagger
Hangfire Dashboard: https://localhost:5000/hangfire
ChatHub WebSocket: wss://localhost:5000/hubs/chat

