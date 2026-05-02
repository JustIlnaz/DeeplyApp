import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../providers/couple_provider.dart';
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
  bool _isSubmitting = false;

  static const _monthNames = [
    '',
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturesProvider>().fetchCheckinStatus();
    });
  }

  @override
  void dispose() {
    _goodController.dispose();
    _tensionController.dispose();
    _improveController.dispose();
    super.dispose();
  }

  String _weekLabel() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return 'Неделя ${monday.day} ${_monthNames[monday.month]} — '
        '${sunday.day} ${_monthNames[sunday.month]}';
  }

  Future<void> _submit() async {
    final great = _goodController.text.trim();
    final tension = _tensionController.text.trim();
    final improve = _improveController.text.trim();
    if (great.isEmpty || tension.isEmpty || improve.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final fp = context.read<FeaturesProvider>();
    final ok = await fp.submitCheckIn(
      whatWasGreat: great,
      whereWasTension: tension,
      whatToImprove: improve,
    );
    if (ok) {
      await fp.fetchCheckinStatus();
      if (mounted) {
        _goodController.clear();
        _tensionController.clear();
        _improveController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Чек-ин отправлен! ✅')),
        );
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
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
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer2<FeaturesProvider, CoupleProvider>(
        builder: (context, fp, cp, _) {
          final partnerName = cp.partnerName ?? 'Партнёр';
          final alreadySubmitted = fp.myCheckinSubmitted;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _weekLabel(),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Question 1
                _buildQuestion(
                  label: '⭐ Что было классно?',
                  controller: _goodController,
                  hint: 'Вспомни лучший момент недели...',
                  enabled: !alreadySubmitted,
                ),
                const SizedBox(height: 20),

                // Question 2
                _buildQuestion(
                  label: '⚡ Где было напряжение?',
                  controller: _tensionController,
                  hint: 'Что было непростым?',
                  enabled: !alreadySubmitted,
                ),
                const SizedBox(height: 20),

                // Question 3
                _buildQuestion(
                  label: '💡 Что можно улучшить?',
                  controller: _improveController,
                  hint: 'Идеи для следующей недели...',
                  enabled: !alreadySubmitted,
                ),

                const SizedBox(height: 24),

                // Partner status banner
                if (fp.partnerCheckinSubmitted)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$partnerName уже заполнила чек-ин\nОтветы появятся после твоего',
                            style: const TextStyle(
                                color: AppColors.accentGreen, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Text('⏳', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Партнёр ещё не заполнил чек-ин',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                // Submit button
                if (alreadySubmitted)
                  Opacity(
                    opacity: 0.5,
                    child: AppButton(
                      text: 'Вы уже отправили чек-ин',
                      onPressed: () {},
                    ),
                  )
                else
                  AppButton(
                    text: 'Отправить чек-ин',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestion({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
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
            enabled: enabled,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: AppColors.textHint, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }
}
