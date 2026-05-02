import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_button.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _answerController = TextEditingController();
  bool _answered = false;

  @override
  void dispose() {
    _answerController.dispose();
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
          'Вопрос дня',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Streak badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔥', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'Серия ответов: 12',
                    style: TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Question card
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '❝',
                    style: TextStyle(color: Colors.white54, fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Какое воспоминание о нас ты хранишь особенно бережно?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '💜 Романтический',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // My answer
            const Text(
              'Твой ответ',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: _answered
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _answerController.text,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                      ),
                    )
                  : TextField(
                      controller: _answerController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Наш первый поход в горы...',
                        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Partner's answer
            const Text(
              'Ответ Насти',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: _answered
                  ? const Text(
                      'Тогда ты улыбнулась на закате и я понял что влюблён.',
                      style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                    )
                  : Column(
                      children: [
                        const Icon(Icons.lock_outline, color: AppColors.textHint, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'Появится после вашего ответа',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 32),
            if (!_answered)
              AppButton(
                text: 'Отправить ответ',
                onPressed: () {
                  if (_answerController.text.trim().isNotEmpty) {
                    setState(() => _answered = true);
                  }
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
