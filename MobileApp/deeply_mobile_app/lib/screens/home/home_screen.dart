import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/features_provider.dart';
import '../chat/chat_screen.dart';
import '../calendar/calendar_screen.dart';
import '../challenges/challenges_screen.dart';
import '../memories/memories_screen.dart';
import '../question/question_screen.dart';
import '../mood/mood_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    final fp = context.read<FeaturesProvider>();
    await Future.wait([
      fp.fetchQuestionToday(),
      fp.fetchMoodWeekly(),
      fp.fetchClosenessIndex(),
      fp.fetchActiveChallenge(),
    ]);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _formatDate(DateTime d) {
    const weekDays = [
      '',
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    const months = [
      '',
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return '${weekDays[d.weekday]}, ${months[d.month]} ${d.day}';
  }

  ({String text, String emoji}) _greeting(int hour) {
    if (hour >= 5 && hour < 12) return (text: 'Доброе утро', emoji: '☀️');
    if (hour >= 12 && hour < 17) return (text: 'Добрый день', emoji: '🌤️');
    if (hour >= 17 && hour < 23) return (text: 'Добрый вечер', emoji: '🌙');
    return (text: 'Доброй ночи', emoji: '🌙');
  }

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fp = context.watch<FeaturesProvider>();
    final now = DateTime.now();
    final greeting = _greeting(now.hour);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.bgCard,
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(auth, greeting, now),
                const SizedBox(height: 20),
                _buildClosenessCard(fp),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildQuestionCard(fp),
                const SizedBox(height: 16),
                _buildMoodCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(
    AuthProvider auth,
    ({String text, String emoji}) greeting,
    DateTime now,
  ) {
    final name = auth.userName.isNotEmpty ? auth.userName : 'Пользователь';
    final initial = name[0].toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(now),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${greeting.text}, $name ',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    greeting.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Closeness index card ─────────────────────────────────────────────────

  Widget _buildClosenessCard(FeaturesProvider fp) {
    final pct = fp.closenessIndex.clamp(0, 100);
    final progress = pct / 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D1D7A), Color(0xFF5C2090)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Индекс близости',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$pct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppColors.accentGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+5% с прошлой недели',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick actions ────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _ActionData(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Чат',
        colors: const [Color(0xFF3D1D7A), Color(0xFF6B35B8)],
        onTap: () => _push(const ChatScreen()),
      ),
      _ActionData(
        icon: Icons.calendar_month_outlined,
        label: 'Календарь',
        colors: const [Color(0xFF1A2A5E), Color(0xFF2D4A9E)],
        onTap: () => _push(const CalendarScreen()),
      ),
      _ActionData(
        icon: Icons.local_fire_department_outlined,
        label: 'Челлендж',
        colors: const [Color(0xFF5E1A1A), Color(0xFF9E2D2D)],
        onTap: () => _push(const ChallengesScreen()),
      ),
      _ActionData(
        icon: Icons.photo_album_outlined,
        label: 'Лента',
        colors: const [Color(0xFF1A3D2A), Color(0xFF2D7A4A)],
        onTap: () => _push(const MemoriesScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые действия',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: actions
              .map((a) => _QuickActionCard(data: a))
              .toList(),
        ),
      ],
    );
  }

  // ─── Question of the day ──────────────────────────────────────────────────

  Widget _buildQuestionCard(FeaturesProvider fp) {
    final q = fp.questionToday;
    final questionText = q?.text ??
        'Вопрос дня ещё не загружен. Потяните, чтобы обновить.';
    final category = q?.category ?? 'Вопрос дня';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💬', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (fp.isLoading && q == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            Text(
              questionText,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _push(const QuestionScreen()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Ответить →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Mood tracker ─────────────────────────────────────────────────────────

  Widget _buildMoodCard() {
    const moods = [
      ('😔', 'Грустно'),
      ('😐', 'Нейтрально'),
      ('🙂', 'Неплохо'),
      ('😊', 'Хорошо'),
      ('😄', 'Отлично'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🧠', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Трекер настроения',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Как ты себя чувствуешь сегодня?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: moods
                .map(
                  (m) => Tooltip(
                    message: m.$2,
                    child: GestureDetector(
                      onTap: () => _push(const MoodScreen()),
                      child: Text(
                        m.$1,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Quick action card ─────────────────────────────────────────────────────

class _ActionData {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _ActionData data;
  const _QuickActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: data.colors),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: data.onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(data.icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
