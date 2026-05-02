class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:5000'; // меняй на свой IP

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';

  // Couple
  static const String coupleCreate = '/api/couples/create';
  static const String coupleJoin = '/api/couples/join';
  static const String coupleMe = '/api/couples/me';

  // Chat
  static const String chatHistory = '/api/chat/history';
  static const String chatSend = '/api/chat/send';
  static String chatRead(int id) => '/api/chat/$id/read';

  // Memories
  static const String memories = '/api/features/memories';
  static String deleteMemory(int id) => '/api/features/memories/$id';

  // Calendar
  static const String events = '/api/features/calendar/events';

  // Mood
  static const String mood = '/api/features/mood';
  static const String moodWeekly = '/api/features/mood/weekly';

  // Question
  static const String questionToday = '/api/features/question/today';
  static String answerQuestion(int id) => '/api/features/question/$id/answer';

  // Check-in
  static const String checkin = '/api/features/checkin/weekly';

  // Challenges
  static const String challengeTemplates = '/api/features/challenges/templates';
  static String startChallenge(int id) => '/api/features/challenges/$id/start';
  static String markChallengeDay(int id, String day) => '/api/features/challenges/$id/days/$day/done';
  static String completeChallenge(int id) => '/api/features/challenges/$id/complete';

  // Capsule
  static const String capsules = '/api/features/time-capsules';
  static const String openedCapsules = '/api/features/time-capsules/opened';

  // Secret messages
  static const String secretMessages = '/api/features/secret-messages';

  // Love map
  static const String loveMapPoints = '/api/features/love-map/points';

  // Todos
  static const String todos = '/api/features/todos';
  static String updateTodoStatus(int id) => '/api/features/todos/$id/status';

  // Finance
  static const String financeRecords = '/api/features/finance/records';
  static const String financeSummary = '/api/features/finance/summary';
  static const String financeGoals = '/api/features/finance/goals';

  // Attachment & Closeness
  static const String attachmentTest = '/api/features/attachment-test';
  static const String closenessIndex = '/api/features/closeness-index';

  // SignalR
  static const String chatHub = '/hubs/chat';
}
