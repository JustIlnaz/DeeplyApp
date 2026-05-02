import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/capsule_model.dart';
import '../../widgets/common/app_button.dart';

class CapsuleScreen extends StatefulWidget {
  const CapsuleScreen({super.key});

  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  final _letterController = TextEditingController();
  late DateTime _selectedDate;
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
    // Default: 1 year from today
    final now = DateTime.now();
    _selectedDate = DateTime(now.year + 1, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturesProvider>().fetchOpenedCapsules();
    });
  }

  @override
  void dispose() {
    _letterController.dispose();
    super.dispose();
  }

  String _formatDate(String utcStr) {
    try {
      final dt = DateTime.parse(utcStr).toLocal();
      return '${dt.day} ${_monthNames[dt.month]} ${dt.year}';
    } catch (_) {
      return utcStr;
    }
  }

  String get _selectedDateLabel {
    return '${_selectedDate.day} ${_monthNames[_selectedDate.month]} ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(tomorrow) ? _selectedDate : tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _seal() async {
    final letter = _letterController.text.trim();
    if (letter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Напишите письмо')),
      );
      return;
    }
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (!_selectedDate.isAfter(tomorrow)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите будущую дату открытия')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final fp = context.read<FeaturesProvider>();
    final ok = await fp.createCapsule(letter: letter, openAt: _selectedDate);
    if (ok) {
      await fp.fetchOpenedCapsules();
      if (mounted) {
        _letterController.clear();
        final now = DateTime.now();
        setState(() {
          _selectedDate = DateTime(now.year + 1, now.month, now.day);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Капсула запечатана! 📬')),
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
          'Капсула времени',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Icon circle
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                    child: Text('⏳', style: TextStyle(fontSize: 36))),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Напиши письмо в будущее',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
            const Center(
              child: Text(
                'Оно откроется в выбранную дату',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 28),

            // Letter field
            const Text(
              'Ваше письмо',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: TextField(
                controller: _letterController,
                style: const TextStyle(
                    color: Colors.white, fontSize: 14, height: 1.6),
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText:
                      'Дорогой партнёр...\n\nЧерез год, когда ты откроешь это письмо...',
                  hintStyle:
                      TextStyle(color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date picker
            const Text(
              'Дата открытия',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.primary, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDateLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppColors.textHint, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Capsules list
            const Text(
              'Созданные капсулы',
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Consumer<FeaturesProvider>(
              builder: (context, fp, _) {
                if (fp.openedCapsules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Нет капсул',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  );
                }
                return Column(
                  children: fp.openedCapsules
                      .map((c) => _CapsuleCard(
                            capsule: c,
                            formattedDate: _formatDate(c.openAtUtc),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            AppButton(
              text: 'Запечатать капсулу 🕰',
              isLoading: _isSubmitting,
              onPressed: _seal,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Capsule Card ───────────────────────────────────────────────────────────

class _CapsuleCard extends StatelessWidget {
  final CapsuleModel capsule;
  final String formattedDate;

  const _CapsuleCard({required this.capsule, required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    // First 40 chars of letter + "..."
    final letter = capsule.letter;
    final title = letter.length > 40
        ? '${letter.substring(0, 40)}...'
        : letter;

    final dateLabel = capsule.isOpened
        ? 'Открыта: $formattedDate'
        : 'Откроется: $formattedDate';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(
            capsule.isOpened ? Icons.lock_open_outlined : Icons.lock_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: capsule.isOpened
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : AppColors.textHint.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              capsule.isOpened ? '🔓 Открыта' : '🔒 Закрыта',
              style: TextStyle(
                color: capsule.isOpened
                    ? AppColors.accentGreen
                    : AppColors.textHint,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
