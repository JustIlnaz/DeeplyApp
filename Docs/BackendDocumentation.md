# DeeplyApp Backend API - Полная документация

## Оглавление

1. [Обзор проекта](#обзор-проекта)
2. [Архитектура](#архитектура)
3. [Технологический стек](#технологический-стек)
4. [Структура проекта](#структура-проекта)
5. [Основные концепции](#основные-концепции)
6. [SignalR - Real-time коммуникация](#signalr---real-time-коммуникация)
7. [Hangfire - Фоновые задачи](#hangfire---фоновые-задачи)
8. [Аутентификация JWT](#аутентификация-jwt)

---

## Обзор проекта

DeeplyApp Backend - это REST API для мобильного приложения, которое помогает парам укреплять отношения через совместную деятельность. Приложение предоставляет функциональность для:

- Ведения совместного чата с партнером
- Сохранения воспоминаний и фотографий из отношений
- Отслеживания настроения и эмоционального состояния
- Выполнения совместных челленджей (вызовов)
- Ведения совместных дел и финансов
- Создания временных капсул и секретных сообщений
- Ежедневных вопросов для углубления связи
- Управления общей базой знаний о партнере (Love Map)

---

## Архитектура

Проект следует классической многоуровневой архитектуре (n-tier architecture):

``
Уровень представления (Controllers)
           |
           v
Уровень бизнес-логики (Services)
           |
           v
Уровень доступа к данным (Entity Framework)
           |
           v
Уровень хранения (PostgreSQL Database)
``

Ключевые компоненты:

- Controllers - HTTP endpoints, которые получают запросы от клиентов
- Services - содержат основную бизнес-логику приложения
- Interfaces - определяют контракты сервисов, позволяя использовать Dependency Injection
- Models - сущности, которые соответствуют таблицам в базе данных
- Requests - DTO (Data Transfer Objects), используются для валидации входящих данных
- AppDbContext - Entity Framework контекст, управляет подключением к БД

---

## Технологический стек

| Компонент | Версия | Назначение |
|-----------|--------|-----------|
| .NET | 8.0 | Основной фреймворк для сборки приложения |
| ASP.NET Core | 8.0 | Фреймворк для создания REST API |
| Entity Framework Core | Последняя | ORM для работы с базой данных |
| PostgreSQL | 14+ | Реляционная база данных |
| SignalR | Built-in | Real-time двусторонняя коммуникация |
| Hangfire | Последняя | Библиотека для фоновых задач |
| JWT | Built-in | JSON Web Token для аутентификации |

---

## Структура проекта

``
DeeplyApi/
├── Controllers/
│   ├── AuthController.cs          - Регистрация, вход, обновление токена
│   ├── ChatController.cs          - Отправка и получение сообщений
│   ├── CouplesController.cs       - Создание и управление парой
│   └── FeaturesController.cs      - Все основные функции
│
├── Services/
│   ├── AuthService.cs             - Логика аутентификации
│   ├── ChatService.cs             - Логика чата
│   ├── CoupleService.cs           - Логика пар
│   └── FeatureService.cs          - Логика остальных функций
│
├── Interfaces/
│   ├── IAuthService.cs
│   ├── IChatService.cs
│   ├── ICoupleService.cs
│   └── IFeatureService.cs
│
├── Models/                        - Сущности базы данных
│   ├── User.cs
│   ├── Couple.cs
│   ├── ChatMessage.cs
│   ├── MemoryEntry.cs
│   ├── MoodEntry.cs
│   ├── DailyQuestion.cs
│   ├── ChallengeTemplate.cs
│   ├── CoupleChallenge.cs
│   ├── TimeCapsule.cs
│   ├── SecretMessage.cs
│   ├── LoveMapPoint.cs
│   ├── CoupleTodo.cs
│   ├── FinanceRecord.cs
│   └── RefreshToken.cs
│
├── Requests/                      - DTO для входящих запросов
│   └── ... (RegisterRequest, LoginRequest и т.д.)
│
├── Connection/
│   └── AppDbContext.cs            - Entity Framework контекст
│
├── Hubs/
│   └── ChatHub.cs                 - SignalR Hub для real-time чата
│
├── JWT/
│   └── JwtService.cs              - Создание и валидация JWT токенов
│
└── Program.cs                     - Конфигурация приложения
``

---

## Основные концепции

### Что такое Dependency Injection (DI)

Dependency Injection - это паттерн, который позволяет класс получать зависимости через конструктор, вместо того чтобы создавать их самостоятельно.

Пример БЕЗ DI (плохо):
``csharp
public class UserController
{
    private UserService _service = new UserService();
}
``

Пример С DI (хорошо):
``csharp
public class UserController
{
    public UserController(IUserService service)
    {
        _service = service;
    }
}
``

В Program.cs происходит регистрация:
``csharp
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IFeatureService, FeatureService>();
``

Это говорит фреймворку: "Когда кто-то попросит IAuthService, дай ему экземпляр AuthService".

Преимущества:
- Легче тестировать код
- Легче менять реализацию
- Код более модульный

### Что такое DTO (Data Transfer Object)

DTO - это класс, который используется только для передачи данных между клиентом и сервером. Помогает:

1. Валидировать входящие данные
2. Не передавать лишние данные из БД
3. Иметь явный контракт API

Пример DTO для создания памяти (то, что приходит от клиента):
``csharp
public class CreateMemoryRequest
{
    public string Title { get; set; }
    public string Description { get; set; }
    public byte[] Photo { get; set; }
    public DateOnly EntryDate { get; set; }
}
``

Сущность БД (то, что хранится в БД):
``csharp
public class MemoryEntry
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int CoupleId { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public byte[] Photo { get; set; }
    public DateOnly EntryDate { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
``

---

## SignalR - Real-time коммуникация

### Что такое SignalR

SignalR - это библиотека ASP.NET Core, которая позволяет серверу отправлять информацию клиентам в реальном времени через WebSocket. 

Основное отличие от обычного REST API:

REST API (Polling - клиент постоянно спрашивает):
``
Клиент: "Есть ли новые сообщения?" -> Сервер
Клиент: "Есть ли новые сообщения?" -> Сервер
Клиент: "Есть ли новые сообщения?" -> Сервер
(много ненужных запросов, задержка 5-10 секунд)
``

SignalR (Push - сервер сам отправляет):
``
Новое сообщение появилось в БД
Сервер сразу отправляет всем клиентам пары
Клиенты сразу получают обновление (задержка 100-200мс)
``

### Как это работает

1. Клиент подключается к SignalR Hub (ChatHub) через WebSocket
2. Устанавливается двусторонний канал коммуникации
3. Когда клиент отправляет сообщение, сервер получает его через Hub
4. Сервер сохраняет сообщение в БД
5. Сервер отправляет сообщение всем подключенным клиентам этой пары
6. Все клиенты получают обновление одновременно

### ChatHub - реализация в коде

``csharp
public class ChatHub : Hub
{
    private readonly AppDbContext _context;

    public ChatHub(AppDbContext context)
    {
        _context = context;
    }

    public override async Task OnConnectedAsync()
    {
        await base.OnConnectedAsync();
    }

    public async Task SendMessage(int coupleId, string content)
    {
        try
        {
            var userIdClaim = Context.User?.FindFirst("userId");
            if (!int.TryParse(userIdClaim?.Value, out var userId))
            {
                await Clients.Caller.SendAsync("error", "Unauthorized");
                return;
            }

            var message = new ChatMessage
            {
                CoupleId = coupleId,
                SenderId = userId,
                Content = content,
                CreatedAtUtc = DateTime.UtcNow
            };

            _context.ChatMessages.Add(message);
            await _context.SaveChangesAsync();

            await Clients.Group(\couple-\\).SendAsync(
                "receiveMessage",
                new
                {
                    id = message.Id,
                    senderId = userId,
                    content = message.Content,
                    timestamp = message.CreatedAtUtc
                }
            );
        }
        catch (Exception ex)
        {
            await Clients.Caller.SendAsync("error", "Failed to send message");
        }
    }

    public override async Task OnDisconnectedAsync(Exception exception)
    {
        await base.OnDisconnectedAsync(exception);
    }
}
``

### Использование SignalR с клиента (JavaScript)

``javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("https://localhost:5000/hubs/chat", {
        accessTokenFactory: () => localStorage.getItem('accessToken')
    })
    .withAutomaticReconnect()
    .build();

connection.on("receiveMessage", (message) => {
    console.log("Новое сообщение:", message);
    addMessageToChat(message);
});

connection.on("error", (error) => {
    console.error("Ошибка:", error);
});

connection.start().catch(err => console.error(err));

function sendMessage(coupleId, content) {
    connection.invoke("SendMessage", coupleId, content)
        .catch(err => console.error(err));
}

function disconnect() {
    connection.stop();
}
``

### Преимущества SignalR

- Низкая задержка - сообщения приходят мгновенно (100-200мс вместо 5-10 сек)
- Двусторонняя коммуникация - обе стороны могут инициировать отправку
- Автоматическое переподключение - при разрыве соединения
- Fallback механизм - если WebSocket недоступен, использует другие протоколы

---

## Hangfire - Фоновые задачи

### Что такое Hangfire

Hangfire - это библиотека для выполнения фоновых задач (background jobs) в ASP.NET Core приложениях.

Типичные применения:
- Отправка email-ов (не блокируя HTTP запрос)
- Генерация отчетов
- Обработка больших файлов
- Выполнение операций по расписанию (cron jobs)
- Очистка старых данных
- Отправка push-уведомлений

### Проблема БЕЗ Hangfire:

``csharp
public async Task<ActionResult> CreateMemory(CreateMemoryRequest request)
{
    // ... сохраняем память ...
    
    await _emailService.SendEmail(...);
    
    return Ok(memory);
}
``

### Решение с Hangfire:

``csharp
public async Task<ActionResult> CreateMemory(CreateMemoryRequest request)
{
    // ... сохраняем память ...
    
    BackgroundJob.Enqueue(() => _emailService.SendEmail(...));
    
    return Ok(memory);
}
``

### Как это работает

1. Вы создаете задачу через BackgroundJob.Enqueue()
2. Hangfire сохраняет задачу в БД (в таблицы Hangfire)
3. Hangfire Server (обработчик) достает задачу из БД и выполняет ее
4. После выполнения результат сохраняется в БД
5. Вы можете посмотреть результат в Hangfire Dashboard

### Конфигурация в Program.cs

``csharp
builder.Services.AddHangfire(config =>
    config.UseSimpleAssemblyNameTypeSerializer()
        .UseRecommendedSerializerSettings()
        .UsePostgreSqlStorage(c => 
            c.UseNpgsqlConnection(
                builder.Configuration.GetConnectionString("Postgres")
            )
        )
);

builder.Services.AddHangfireServer();

app.UseHangfireDashboard("/hangfire");
``

### Использование Hangfire в коде

Одноразовая задача:
``csharp
BackgroundJob.Enqueue(() => SendEmailToPartner(userId, "Your partner created a new memory"));
``

Отложенная задача (через 5 минут):
``csharp
BackgroundJob.Schedule(
    () => NotificationService.SendReminder(coupleId),
    TimeSpan.FromMinutes(5)
);
``

Повторяющаяся задача (каждый день в 9:00):
``csharp
RecurringJob.AddOrUpdate(
    "send-daily-question",
    () => QuestionService.SendDailyQuestion(),
    Cron.Daily(9)
);
``

Каждый час:
``csharp
RecurringJob.AddOrUpdate(
    "check-opened-capsules",
    () => CapsuleService.CheckAndNotifyOpenedCapsules(),
    Cron.Hourly
);
``

### Пример: Проверка открытых капсул каждый час

``csharp
public class CapsuleService
{
    private readonly AppDbContext _context;
    private readonly INotificationService _notificationService;

    public void CheckAndNotifyOpenedCapsules()
    {
        var now = DateTime.UtcNow;
        var capsulesToOpen = _context.TimeCapsules
            .Where(c => !c.IsOpened && c.OpenAtUtc <= now)
            .ToList();

        foreach (var capsule in capsulesToOpen)
        {
            capsule.IsOpened = true;

            var couple = _context.Couples
                .FirstOrDefault(cp => cp.Id == capsule.CoupleId);
            var receiver = couple.User1Id == capsule.UserId 
                ? couple.User2 
                : couple.User1;

            _notificationService.SendPushNotification(
                receiver.Id,
                "Your partner has a time capsule for you!"
            );
        }

        _context.SaveChanges();
    }
}

// В Program.cs:
RecurringJob.AddOrUpdate(
    "check-capsules",
    () => capsuleService.CheckAndNotifyOpenedCapsules(),
    Cron.Hourly
);
``

### Hangfire Dashboard

Доступен по адресу: https://localhost:5000/hangfire

Вы можете:
- Увидеть историю всех выполненных задач
- Посмотреть время выполнения каждой задачи
- Увидеть ошибки
- Вручную запустить или отменить задачу

### Типы задач в Hangfire

1. Fire-and-forget (сразу):
``csharp
BackgroundJob.Enqueue(() => SomeMethod());
``

2. Delayed (через некоторое время):
``csharp
BackgroundJob.Schedule(() => SomeMethod(), TimeSpan.FromMinutes(5));
``

3. Recurring (по расписанию):
``csharp
RecurringJob.AddOrUpdate("job-id", () => SomeMethod(), Cron.Daily);
``

---

## Аутентификация JWT

### Что такое JWT

JWT (JSON Web Token) - это способ безопасно передавать информацию между клиентом и сервером.

Вместо того чтобы сервер хранил информацию о сеансах пользователя, клиент получает подписанный токен, который содержит информацию. При каждом запросе клиент отправляет этот токен, а сервер проверяет подпись.

### Структура JWT

JWT состоит из трех частей, разделенных точками:

``
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.
eyJ1c2VySWQiOjEsImVtYWlsIjoiand0QGV4YW1wbGUuY29tIn0.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
``

1. Header (Заголовок):
``json
{
  "alg": "HS256",
  "typ": "JWT"
}
``

2. Payload (Данные):
``json
{
  "userId": 1,
  "email": "user@example.com",
  "exp": 1624608000,
  "iat": 1624521600
}
``

3. Signature (Подпись):
``
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret-key)
``

### Как работает аутентификация

1. Клиент отправляет email и пароль на POST /api/auth/login
2. Сервер проверяет учетные данные
3. Если верно, сервер создает JWT токен и отправляет его
4. Клиент сохраняет токен локально
5. При следующих запросах клиент отправляет токен:

``
Authorization:  eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
``

6. Сервер проверяет подпись токена
7. Из токена извлекаются данные пользователя

### Преимущества JWT

- Stateless - сервер не хранит информацию о сеансах
- Масштабируемость - несколько серверов могут проверить токен
- CORS-friendly - хорошо работает с кросс-доменными запросами

---

## Заключение

DeeplyApp построено на проверенных принципах:

- Многоуровневая архитектура отделяет слои ответственности
- Dependency Injection обеспечивает модульность
- REST API предоставляет четкий интерфейс
- JWT обеспечивает безопасную аутентификацию
- SignalR обеспечивает real-time коммуникацию с низкой задержкой
- Hangfire позволяет выполнять фоновые задачи без блокирования
- PostgreSQL обеспечивает надежное хранилище данных
- Entity Framework Core упрощает работу с БД
