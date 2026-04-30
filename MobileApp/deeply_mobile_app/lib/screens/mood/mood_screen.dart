import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_button.dart';

class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  const MoodOption({required this.emoji, required this.label, required this.color});
}

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  int? _selectedMood;
  final _commentController = TextEditingController();

  final List<MoodOption> _moods = [
    MoodOption(emoji: '😔', label: 'Усталый', color: Color(0xFF5B6AF5)),
    MoodOption(emoji: '😢', label: 'Грустно', color: Color(0xFF4A90D9)),
    MoodOption(emoji: '😐', label: 'Спокойно', color: Color(0xFF7B6FE8)),
    MoodOption(emoji: '😊', label: 'Хорошо', color: Color(0xFF4CAF50)),
    MoodOption(emoji: '😍', label: 'Влюблён', color: Color(0xFFD63AF5)),
    MoodOption(emoji: '⚡', label: 'Энергия', color: Color(0xFFFFC107)),
    MoodOption(emoji: '😤', label: 'Напряжён', color: Color(0xFFFF7043)),
    MoodOption(emoji: '🔥', label: 'Тепло', color: Color(0xFFFF5722)),
  ];

  // Partner's mood (mock data)
  final String _partnerMood = '😍 Влюблённая';

  // Weekly chart data (0.0 to 1.0)
  final List<double> _weekData = [0.5, 0.7, 0.6, 0.8, 0.75, 0.9, 1.0];
  final List<String> _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
          'Трекер настроения',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Как ты себя чувствуешь?',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Mood grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _moods.length,
              itemBuilder: (context, i) {
                final mood = _moods[i];
                final selected = _selectedMood == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? mood.color.withOpacity(0.25) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? mood.color : Colors.white.withOpacity(0.07),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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

            // Comment
            const Text(
              'Комментарий',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Что-то особенное сегодня?...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Partner mood
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Настроение Девушки',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _partnerMood,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Weekly chart
            const Text(
              'График за неделю',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_weekData.length, (i) {
                  final isToday = i == _weekData.length - 1;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 32,
                            height: 80 * _weekData[i],
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isToday
                                    ? [AppColors.primary, AppColors.primaryLight]
                                    : [
                                        AppColors.gradientPurple.withOpacity(0.6),
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
                        _weekDays[i],
                        style: TextStyle(
                          color: isToday ? AppColors.primary : AppColors.textHint,
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 32),
            AppButton(text: 'Сохранить настроение', onPressed: () {}),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
