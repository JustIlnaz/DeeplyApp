import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/couple_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/features_provider.dart';
import '../../widgets/common/app_button.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _answerController = TextEditingController();

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
      await context.read<FeaturesProvider>().fetchQuestionToday();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _categoryDisplay(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'romantic':
      case 'романтический':
        return '💜 Романтический';
      case 'trust':
      case 'доверие':
        return '🤝 Доверие';
      case 'future':
      case 'будущее':
        return '🌟 Будущее';
      case 'fun':
      case 'весёлый':
        return '😄 Весёлый';
      case 'communication':
      case 'общение':
        return '💬 Общение';
      default:
        return category != null && category.isNotEmpty
            ? '💜 $category'
            : '💬 Общий';
    }
  }

  Future<void> _submitAnswer(int questionId) async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;
    final features = context.read<FeaturesProvider>();
    // answerQuestion internally calls fetchQuestionToday() on success
    final ok = await features.answerQuestion(questionId, answer);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          'Не удалось отправить ответ. Попробуйте ещё раз.',
          style: TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final features = context.watch<FeaturesProvider>();
    final partnerName =
        context.watch<CoupleProvider>().partnerName ?? 'Партнёр';
    final question = features.questionToday;

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
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: features.isLoading && question == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Streak badge ────────────────────────────────────────
                  _StreakBadge(),

                  const SizedBox(height: 20),

                  // ── Question card ───────────────────────────────────────
                  _buildQuestionCard(question),

                  const SizedBox(height: 24),

                  // ── My answer ───────────────────────────────────────────
                  const Text(
                    'Твой ответ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _buildMyAnswerSection(question),

                  const SizedBox(height: 24),

                  // ── Partner answer ──────────────────────────────────────
                  Text(
                    'Ответ $partnerName',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  _buildPartnerAnswerSection(question),

                  const SizedBox(height: 32),

                  // ── Submit button (only shown before answering) ─────────
                  if (question != null && question.myAnswer == null)
                    AppButton(
                      text: 'Отправить ответ',
                      onPressed: () => _submitAnswer(question.id),
                      isLoading: features.isLoading,
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ── Question card ───────────────────────────────────────────────────────────
  Widget _buildQuestionCard(dynamic question) {
    final text = question?.text as String? ??
        'Загрузка вопроса...';
    final category = question?.category as String?;

    return Container(
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
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _categoryDisplay(category),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── My answer section ───────────────────────────────────────────────────────
  Widget _buildMyAnswerSection(dynamic question) {
    final myAnswer = question?.myAnswer as String?;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: myAnswer != null
          // Already answered — show as read-only text
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                myAnswer,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, height: 1.5),
              ),
            )
          // Not answered — show input field
          : TextField(
              controller: _answerController,
              style:
                  const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Напишите свой ответ...',
                hintStyle: TextStyle(
                    color: AppColors.textHint, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
    );
  }

  // ── Partner answer section ─────────────────────────────────────────────────
  Widget _buildPartnerAnswerSection(dynamic question) {
    final myAnswer = question?.myAnswer as String?;
    final partnerAnswer = question?.partnerAnswer as String?;

    Widget content;

    if (myAnswer == null) {
      // User hasn't answered — partner's answer is locked
      content = Column(
        children: [
          const Icon(Icons.lock_outline,
              color: AppColors.textHint, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Появится после вашего ответа',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      );
    } else if (partnerAnswer == null) {
      // User answered, partner hasn't yet
      content = Row(
        children: const [
          Icon(Icons.hourglass_empty,
              color: AppColors.textHint, size: 20),
          SizedBox(width: 8),
          Text(
            'Партнёр ещё не ответил',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      );
    } else {
      // Both answered — show partner's answer
      content = Text(
        partnerAnswer,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, height: 1.5),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: content,
    );
  }
}

// ─── Streak badge ─────────────────────────────────────────────────────────────
class _StreakBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
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
    );
  }
}
