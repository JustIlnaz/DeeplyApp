import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/couple_provider.dart';
import '../../providers/features_provider.dart';
import '../../data/models/mood_model.dart';
import '../../widgets/common/app_button.dart';

// ─── Mood option descriptor ───────────────────────────────────────────────────
class _MoodOption {
  final String key; // moodType used by the API
  final String emoji;
  final String label;
  final Color color;
  const _MoodOption(this.key, this.emoji, this.label, this.color);
}

const List<_MoodOption> _kMoods = [
  _MoodOption('tired', '😔', 'Усталый', Color(0xFF5B6AF5)),
  _MoodOption('sad', '😢', 'Грустно', Color(0xFF4A90D9)),
  _MoodOption('calm', '😐', 'Спокойно', Color(0xFF7B6FE8)),
  _MoodOption('happy', '😊', 'Хорошо', Color(0xFF4CAF50)),
  _MoodOption('love', '😍', 'Влюблён', Color(0xFFD63AF5)),
  _MoodOption('energy', '⚡', 'Энергия', Color(0xFFFFC107)),
  _MoodOption('tense', '😤', 'Напряжён', Color(0xFFFF7043)),
  _MoodOption('warm', '🔥', 'Тепло', Color(0xFFFF5722)),
];

// ─── moodType → bar height (0.0–1.0) ─────────────────────────────────────────
double _moodHeight(String? moodType) {
  const h = {
    'love': 1.0,
    'happy': 0.9,
    'energy': 0.8,
    'warm': 0.7,
    'calm': 0.5,
    'tired': 0.3,
    'sad': 0.25,
    'tense': 0.2,
  };
  return h[moodType] ?? 0.0;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  String? _selectedMoodKey;
  final _commentController = TextEditingController();

  static const List<String> _weekDayLabels = [
    'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) await auth.fetchProfile();

    if (mounted) {
      final couple = context.read<CoupleProvider>();
      if (couple.partnerName == null && auth.userId != null) {
        await couple.fetchPartnerProfile(auth.userId!);
      }
    }

    if (mounted) {
      await context.read<FeaturesProvider>().fetchMoodWeekly();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the 7 dates of the current Mon–Sun week.
  List<DateTime> _weekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });
  }

  String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  MoodModel? _moodForDay(
      List<MoodModel> moods, int myUserId, DateTime day) {
    final key = _dayKey(day);
    try {
      return moods.firstWhere(
          (m) => m.userId == myUserId && m.day == key);
    } catch (_) {
      return null;
    }
  }

  MoodModel? _latestPartnerMood(List<MoodModel> moods, int? myUserId) {
    final partnerMoods = moods.where((m) => m.userId != myUserId).toList();
    if (partnerMoods.isEmpty) return null;
    partnerMoods.sort((a, b) => b.day.compareTo(a.day));
    return partnerMoods.first;
  }

  _MoodOption? _optionForKey(String? key) {
    if (key == null) return null;
    try {
      return _kMoods.firstWhere((m) => m.key == key);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveMood() async {
    if (_selectedMoodKey == null) return;
    final features = context.read<FeaturesProvider>();
    final comment = _commentController.text.trim();
    final ok = await features.addMood(
      moodType: _selectedMoodKey!,
      comment: comment.isNotEmpty ? comment : null,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor:
          ok ? AppColors.accentGreen : Colors.redAccent,
      content: Text(
        ok ? 'Настроение сохранено!' : 'Ошибка. Попробуйте ещё раз.',
        style: const TextStyle(color: Colors.white),
      ),
      behavior: SnackBarBehavior.floating,
    ));
    if (ok) {
      setState(() => _selectedMoodKey = null);
      _commentController.clear();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final features = context.watch<FeaturesProvider>();
    final myUserId = context.watch<AuthProvider>().userId;
    final partnerName =
        context.watch<CoupleProvider>().partnerName ?? 'Партнёр';

    final weekDates = _weekDates();
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month}-${today.day}';

    final partnerMood = _latestPartnerMood(features.moodWeekly, myUserId);
    final partnerMoodOption = _optionForKey(partnerMood?.moodType);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Трекер настроения',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Title ──────────────────────────────────────────────────────
            const Text(
              'Как ты себя чувствуешь?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // ── 4×2 Mood grid ──────────────────────────────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _kMoods.length,
              itemBuilder: (context, i) {
                final mood = _kMoods[i];
                final selected = _selectedMoodKey == mood.key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedMoodKey = mood.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? mood.color.withValues(alpha: 0.25)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? mood.color
                            : Colors.white.withValues(alpha: 0.07),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Comment ────────────────────────────────────────────────────
            const Text(
              'Комментарий',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: TextField(
                controller: _commentController,
                style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Что-то особенное сегодня?...',
                  hintStyle: TextStyle(
                      color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Partner mood ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Настроение $partnerName',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  partnerMoodOption != null
                      ? Row(
                          children: [
                            Text(partnerMoodOption.emoji,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Text(
                              partnerMoodOption.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          features.isLoading
                              ? 'Загрузка...'
                              : 'Партнёр ещё не записал настроение',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Weekly chart ───────────────────────────────────────────────
            const Text(
              'График за неделю',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final date = weekDates[i];
                  final dateKey =
                      '${date.year}-${date.month}-${date.day}';
                  final isToday = dateKey == todayKey;
                  final mood = myUserId != null
                      ? _moodForDay(
                          features.moodWeekly, myUserId, date)
                      : null;
                  final barHeight = _moodHeight(mood?.moodType);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            width: 32,
                            height: barHeight > 0 ? 80 * barHeight : 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isToday
                                    ? [
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ]
                                    : [
                                        AppColors.gradientPurple
                                            .withValues(alpha: 0.6),
                                        AppColors.gradientPurple,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _weekDayLabels[i],
                        style: TextStyle(
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textHint,
                          fontSize: 11,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ────────────────────────────────────────────────
            Opacity(
              opacity: _selectedMoodKey == null ? 0.45 : 1.0,
              child: AppButton(
                text: 'Сохранить настроение',
                onPressed:
                    _selectedMoodKey == null ? () {} : _saveMood,
                isLoading: features.isLoading,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
