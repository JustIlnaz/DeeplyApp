# Configuration TODO

## ⚠️ ВАЖНО: Обновить перед запуском

### 1. API Configuration
- [ ] Обновить `DioClient.baseUrl` на актуальный адрес сервера
  - Файл: `lib/core/network/dio_client.dart`
  - Текущее значение: `https://api.deeply.local`
  
### 2. Environment Variables
- [ ] Создать `.env` файл или использовать конфигурацию для dev/prod
- [ ] Добавить поддержку разных баз URL для разных сред

### 3. SSL Certificate
- [ ] Для production добавить правильный SSL сертификат
- [ ] Отключить проверку сертификата только для development

### 4. Logging
- [ ] Настроить уровень логирования в `LoggingInterceptor`
- [ ] Добавить логирование в файл для production

### 5. Error Handling
- [ ] Добавить глобальный error handler
- [ ] Настроить пользовательские ошибки в UI

### 6. Token Management
- [ ] Реализовать сохранение токенов в secure storage
- [ ] Добавить автоматическое обновление токена при истечении
- [ ] Реализовать logout при получении 401

### 7. SignalR Integration (для чата)
- [ ] Добавить SignalR клиент
- [ ] Настроить реал-тайм слушатели сообщений
- [ ] Добавить переподключение при разрыве соединения

### 8. Push Notifications
- [ ] Добавить Firebase Cloud Messaging
- [ ] Настроить уведомления для новых сообщений
- [ ] Настроить уведомления для напоминаний

### 9. Image Upload
- [ ] Добавить multipart file upload
- [ ] Добавить compression перед загрузкой
- [ ] Добавить progress tracking

### 10. Local Storage
- [ ] Реализовать кэширование с help flutter_cache_manager
- [ ] Добавить offline-first функциональность
- [ ] Реализовать синхронизацию при восстановлении интернета

### 11. Testing
- [ ] Написать unit тесты для сервисов
- [ ] Написать widget тесты для UI
- [ ] Настроить mock API для тестирования

### 12. Analytics
- [ ] Добавить Firebase Analytics
- [ ] Отслеживать ключевые пользовательские события

## Файлы которые нужно создать

- [ ] `lib/core/config/environment.dart` - Configuration для разных сред
- [ ] `lib/core/storage/secure_storage.dart` - Безопасное хранилище токенов
- [ ] `lib/data/datasources/local_datasource.dart` - Локальное хранилище
- [ ] `lib/data/datasources/remote_datasource.dart` - API datasource
- [ ] `lib/core/services/notification_service.dart` - Push уведомления
- [ ] `lib/core/services/signalr_service.dart` - SignalR для чата
- [ ] `lib/core/utils/file_manager.dart` - Загрузка файлов

## API Endpoints (из Backend)

```
Auth:
- POST /auth/register
- POST /auth/login
- POST /auth/refresh
- POST /auth/logout

Couples:
- POST /couples/create
- GET /couples/my
- POST /couples/join

Chat:
- GET /chat/messages
- POST /chat/send
- PUT /chat/messages/{id}/read

Features: (все под /features/)
- GET/POST /memories
- PUT /memories/{id}/toggle-pin
- DELETE /memories/{id}
- GET/POST /events
- DELETE /events/{id}
- GET/POST /moods
- GET /daily-questions/today
- POST /daily-questions/{id}/answer
- GET /weekly-checkin
- POST /weekly-checkin
- GET /challenges/active
- GET /challenges/templates
- POST /challenges/{id}/start
- PUT /challenges/{id}/progress
- GET/POST /time-capsules
- GET/POST /secret-messages
- GET/POST /love-map
- GET/POST /todos
- PUT /todos/{id}
- GET/POST /finance/goals
- PUT /finance/goals/{id}/progress
- GET/POST /finance/records
```
