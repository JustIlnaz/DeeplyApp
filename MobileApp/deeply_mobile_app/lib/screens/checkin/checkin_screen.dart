import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_button.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final _goodController = TextEditingController();
  final _tensionController = TextEditingController();
  final _improveController = TextEditingController();

  @override
  void dispose() {
    _goodController.dispose();
    _tensionController.dispose();
    _improveController.dispose();
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
          'Еженедельный чек-ин',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Неделя 15 апреля — 21 апреля',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            _buildQuestion(
              emoji: '⭐',
              question: 'Что было классно?',
              controller: _goodController,
              hint: 'Вспомни лучший момент недели...',
            ),
            const SizedBox(height: 20),

            _buildQuestion(
              emoji: '⚡',
              question: 'Где было напряжение?',
              controller: _tensionController,
              hint: 'Что было непростым?',
            ),
            const SizedBox(height: 20),

            _buildQuestion(
              emoji: '💡',
              question: 'Что можно улучшить?',
              controller: _improveController,
              hint: 'Идеи для следующей недели...',
            ),

            const SizedBox(height: 24),

            // Partner status
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  const Text(
                    'Настя уже заполнила чек-ин',
                    style: TextStyle(color: Color(0xFF4CAF50), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ответы появятся после твоего',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),

            const SizedBox(height: 28),
            AppButton(text: 'Отправить чек-ин', onPressed: () {}),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required String emoji,
    required String question,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }
}
