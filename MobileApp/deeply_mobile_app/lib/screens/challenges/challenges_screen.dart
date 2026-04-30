import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ChallengeItem {
  final String title;
  final int days;
  final String difficulty;
  final Color difficultyColor;
  final String emoji;

  const ChallengeItem({
    required this.title,
    required this.days,
    required this.difficulty,
    required this.difficultyColor,
    required this.emoji,
  });
}

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = [
      ChallengeItem(
        title: 'Фото каждого рассвета',
        days: 14,
        difficulty: 'Лёгкий',
        difficultyColor: Color(0xFF4CAF50),
        emoji: '🌅',
      ),
      ChallengeItem(
        title: 'Письмо партнёру каждый день',
        days: 7,
        difficulty: 'Романтический',
        difficultyColor: Color(0xFFD63AF5),
        emoji: '💌',
      ),
      ChallengeItem(
        title: 'Медитация вместе',
        days: 21,
        difficulty: 'Средний',
        difficultyColor: Color(0xFFFF9800),
        emoji: '🧘',
      ),
      ChallengeItem(
        title: 'Без телефона 1 час в день',
        days: 7,
        difficulty: 'Сложный',
        difficultyColor: Color(0xFFFF5722),
        emoji: '📵',
      ),
    ];

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
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Active challenge
            Container(
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '🔥 Активный челлендж',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '7 дней благодарности',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'День 4 из 7',
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(7, (i) {
                      final done = i < 4;
                      return Container(
                        width: 34,
                        height: 34,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, color: Color(0xFF2D8A40), size: 16)
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Выбрать новый',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ...challenges.map((c) => _ChallengeCard(challenge: c)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeItem challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Text(challenge.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${challenge.days} дней',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: challenge.difficultyColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        challenge.difficulty,
                        style: TextStyle(
                          color: challenge.difficultyColor,
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
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Начат',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
