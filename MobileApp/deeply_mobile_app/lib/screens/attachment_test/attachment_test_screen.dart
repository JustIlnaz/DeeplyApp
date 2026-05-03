import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/attachment_test_model.dart';
import '../../widgets/common/app_button.dart';

class AttachmentTestScreen extends StatefulWidget {
  const AttachmentTestScreen({super.key});

  @override
  State<AttachmentTestScreen> createState() => _AttachmentTestScreenState();
}

class _AttachmentTestScreenState extends State<AttachmentTestScreen> {
  final _answers = <int>[];
  int _currentIndex = 0;

  final List<AttachmentQuestion> _questions = [
    AttachmentQuestion(id: 1, text: 'Мне комфортно делиться своими чувствами с партнёром.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 2, text: 'Я боюсь, что партнёр может меня покинуть.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 3, text: 'Я чувствую себя комфортно, когда проявляю нежность.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 4, text: 'Я часто ревную и беспокоюсь о верности партнёра.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 5, text: 'Я легко доверяю партнёру.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 6, text: 'Я стараюсь избегать слишком близких отношений.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 7, text: 'Мне нравится, когда партнёр рядом, и я скучаю, когда его нет.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 8, text: 'Я часто анализирую сообщения партнёра, ища скрытый смысл.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 9, text: 'Я предпочитаю держать часть чувств при себе.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 10, text: 'Я уверен(а), что я достоин(а) любви и заботы.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 11, text: 'Мне нужно много времени наедине с собой, чтобы восстановить силы.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 12, text: 'Я часто пишу или звоню партнёру, чтобы убедиться, что всё в порядке.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 13, text: 'Я спокойно реагирую, когда партнёр занят другими делами.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 14, text: 'Я чувствую напряжение, когда партнёр слишком близко подходит эмоционально.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 15, text: 'Я горжусь достижениями партнёра, как своими.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 16, text: 'Мне сложно расслабиться, пока партнёр не подтвердит свою любовь.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 17, text: 'Я могу спокойно попросить о поддержке, когда она мне нужна.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 18, text: 'Я чувствую себя скованно, когда приходится открываться эмоционально.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 19, text: 'Я верю, что партнёр будет рядом в трудную минуту.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 20, text: 'Я чувствую себя в ловушке, когда отношения становятся слишком серьёзными.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 21, text: 'Я легко прощаю партнёру мелкие обиды.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 22, text: 'Мне сложно расслабиться, пока партнёр не подтвердит свою любовь.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 23, text: 'Я ценю свою независимость и личное пространство.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 24, text: 'Я чувствую себя живым(ой), когда делюсь своими мечтами с партнёром.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
    AttachmentQuestion(id: 25, text: 'Я стараюсь не показывать партнёру свои слабости.', options: ['Совсем нет', 'Редко', 'Иногда', 'Часто', 'Всегда']),
  ];

  @override
  void initState() {
    super.initState();
    _answers.addAll(List.filled(_questions.length, 0));
  }

  double get _progress => (_currentIndex + 1) / _questions.length;

  Future<void> _submit() async {
    final fp = context.read<FeaturesProvider>();
    final ok = await fp.submitAttachmentTest(_answers);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _ResultScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Ошибка отправки. Попробуйте ещё раз.'),
      ));
    }
  }

  void _next() {
    if (_answers[_currentIndex] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Выберите вариант ответа'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Тип привязанности',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Вопрос ${_currentIndex + 1} из ${_questions.length}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    Text('${(_progress * 100).round()}%',
                        style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.bgCard,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3D1D7A), Color(0xFF6B35B8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      q.text,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...q.options.asMap().entries.map((e) => _OptionTile(
                        index: e.key + 1,
                        label: e.value,
                        selected: _answers[_currentIndex] == e.key + 1,
                        onTap: () => setState(() => _answers[_currentIndex] = e.key + 1),
                      )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: AppButton(
                      text: 'Назад',
                      onPressed: _prev,
                      isOutlined: true,
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: _currentIndex == _questions.length - 1 ? 'Завершить' : 'Далее',
                    onPressed: _next,
                    isLoading: context.watch<FeaturesProvider>().isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.index, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
                color: selected ? AppColors.primary : Colors.transparent,
              ),
              child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen();

  @override
  Widget build(BuildContext context) {
    final result = context.watch<FeaturesProvider>().attachmentTestResult;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(result?.typeEmoji ?? '🎉', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                result != null ? 'Ваш тип: ${result.typeLabel}' : 'Тест пройден!',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
              ),
              if (result?.recommendation != null) ...[
                const SizedBox(height: 16),
                Text(
                  result!.recommendation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Text(
                  'Результаты теста сохранены. Вы можете обсудить их с партнёром, чтобы лучше понять особенности вашего общения.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                text: 'Вернуться в профиль',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
