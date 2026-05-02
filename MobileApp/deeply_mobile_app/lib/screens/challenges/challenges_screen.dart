import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/challenge_model.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fp = context.read<FeaturesProvider>();
      fp.fetchChallengeTemplates();
      fp.fetchActiveChallenge();
    });
  }

  ({String emoji, String difficulty, Color color}) _templateMeta(String title) {
    final t = title.toLowerCase();
    if (t.contains('благодарн')) {
      return (emoji: '🙏', difficulty: 'Лёгкий', color: AppColors.accentGreen);
    }
    if (t.contains('рассвет') || t.contains('фото')) {
      return (emoji: '🌅', difficulty: 'Лёгкий', color: AppColors.accentGreen);
    }
    if (t.contains('письм')) {
      return (emoji: '💌', difficulty: 'Романтический', color: AppColors.primary);
    }
    if (t.contains('медитац')) {
      return (
        emoji: '🧘',
        difficulty: 'Средний',
        color: AppColors.accentOrange
      );
    }
    if (t.contains('телефон')) {
      return (
        emoji: '📵',
        difficulty: 'Сложный',
        color: const Color(0xFFFF5722)
      );
    }
    return (emoji: '⭐', difficulty: 'Средний', color: AppColors.accentOrange);
  }

  Future<void> _markToday(
      FeaturesProvider fp, ChallengeProgressModel active) async {
    final ok = await fp.markChallengeDay(active.id, DateTime.now());
    if (ok) await fp.fetchActiveChallenge();
  }

  Future<void> _startChallenge(FeaturesProvider fp, int templateId) async {
    final ok = await fp.startChallenge(templateId);
    if (ok) await fp.fetchActiveChallenge();
  }

  @override
  Widget build(BuildContext context) {
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
          'Челленджи',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<FeaturesProvider>(
        builder: (context, fp, _) {
          if (fp.isLoading && fp.challengeTemplates.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final active = fp.activeChallenge;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Active challenge card
                if (active != null) ...[
                  _ActiveChallengeCard(
                    active: active,
                    onMarkToday: () => _markToday(fp, active),
                  ),
                  const SizedBox(height: 24),
                ],

                const Text(
                  'Выбрать новый',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                ...fp.challengeTemplates.map((t) {
                  final meta = _templateMeta(t.title);
                  return _ChallengeCard(
                    template: t,
                    emoji: meta.emoji,
                    difficulty: meta.difficulty,
                    difficultyColor: meta.color,
                    isDisabled: active != null,
                    onStart: () => _startChallenge(fp, t.id),
                  );
                }),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Active Challenge Card ──────────────────────────────────────────────────

class _ActiveChallengeCard extends StatelessWidget {
  final ChallengeProgressModel active;
  final VoidCallback onMarkToday;

  const _ActiveChallengeCard({
    required this.active,
    required this.onMarkToday,
  });

  @override
  Widget build(BuildContext context) {
    final doneCount = active.completedDays.length;
    final total = active.durationDays;
    // Cap visible day circles at 7
    final visibleDays = total > 7 ? 7 : total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A5C2A), Color(0xFF2D8A40)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '🔥 Активный челлендж',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            active.title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'День $doneCount из $total',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Day circles (max 7)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(visibleDays, (i) {
                final done = i < doneCount;
                return Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check,
                            color: Color(0xFF2D8A40), size: 16)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ),

          if (!active.isCompleted) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onMarkToday,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Text(
                    'Отметить сегодня ✓',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Template Card ──────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final ChallengeTemplateModel template;
  final String emoji;
  final String difficulty;
  final Color difficultyColor;
  final bool isDisabled;
  final VoidCallback onStart;

  const _ChallengeCard({
    required this.template,
    required this.emoji,
    required this.difficulty,
    required this.difficultyColor,
    required this.isDisabled,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${template.durationDays} дней',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: difficultyColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          color: difficultyColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // "Начать" button — grayed out if there's an active challenge
          if (isDisabled)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Начать',
                style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            )
          else
            GestureDetector(
              onTap: onStart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Начать',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
