import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/secret_message_model.dart';
import '../../widgets/common/app_button.dart';

class SecretMessageScreen extends StatefulWidget {
  const SecretMessageScreen({super.key});

  @override
  State<SecretMessageScreen> createState() => _SecretMessageScreenState();
}

class _SecretMessageScreenState extends State<SecretMessageScreen> {
  final _messageController = TextEditingController();
  String _openMode = 'hours'; // 'hours' or 'date'
  int _selectedHours = 24;
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  Timer? _ticker;

  static const List<int> _hourOptions = [6, 12, 24, 48, 72];

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
      context.read<FeaturesProvider>().fetchAllSecretMessages();
    });
    // Tick every second to update countdowns
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  String _formatRemaining(String openAtUtc) {
    try {
      final openAt = DateTime.parse(openAtUtc).toLocal();
      final remaining = openAt.difference(DateTime.now());
      if (remaining.isNegative || remaining.inSeconds <= 0) {
        return 'Открыто';
      }
      if (remaining.inHours >= 24) {
        final days = remaining.inDays;
        return 'Через $days ${_daysWord(days)}';
      }
      final h = remaining.inHours.toString().padLeft(2, '0');
      final m = (remaining.inMinutes % 60).toString().padLeft(2, '0');
      final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    } catch (_) {
      return '—';
    }
  }

  bool _isExpired(String openAtUtc) {
    try {
      final openAt = DateTime.parse(openAtUtc).toLocal();
      return openAt.difference(DateTime.now()).isNegative;
    } catch (_) {
      return false;
    }
  }

  String _daysWord(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod100 >= 11 && mod100 <= 19) return 'дней';
    if (mod10 == 1) return 'день';
    if (mod10 >= 2 && mod10 <= 4) return 'дня';
    return 'дней';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_monthNames[dt.month]} ${dt.year}';
  }

  Future<void> _pickDate() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final initial = _selectedDate != null && _selectedDate!.isAfter(tomorrow)
        ? _selectedDate!
        : tomorrow;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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

  Future<void> _send() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Напишите сообщение')),
      );
      return;
    }

    DateTime openAt;
    if (_openMode == 'hours') {
      openAt = DateTime.now().add(Duration(hours: _selectedHours));
    } else {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите дату открытия')),
        );
        return;
      }
      openAt = _selectedDate!;
    }

    setState(() => _isSubmitting = true);
    final fp = context.read<FeaturesProvider>();
    final ok =
        await fp.createSecretMessage(message: message, openAt: openAt);
    if (ok) {
      await fp.fetchAllSecretMessages();
      if (mounted) {
        _messageController.clear();
        setState(() {
          _selectedHours = 24;
          _selectedDate = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Послание отправлено! 💌')),
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
          'Тайные сообщения',
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

            // Header icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgCard,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child:
                    const Center(child: Text('🤫', style: TextStyle(fontSize: 38))),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Сообщение с таймером',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const Center(
              child: Text(
                'Откроется в нужный момент',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),

            const SizedBox(height: 28),

            // Message input
            const Text(
              'Твоё послание',
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
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Напиши что-то особенное...',
                  hintStyle:
                      TextStyle(color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Open mode toggle
            const Text(
              'Способ открытия',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _openMode = 'hours'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _openMode == 'hours'
                            ? AppColors.primaryGradient
                            : null,
                        color: _openMode == 'hours' ? null : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _openMode == 'hours'
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '● Через часы',
                          style: TextStyle(
                            color: _openMode == 'hours'
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _openMode = 'date'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _openMode == 'date'
                            ? AppColors.primaryGradient
                            : null,
                        color: _openMode == 'date' ? null : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _openMode == 'date'
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '📅 По дате',
                          style: TextStyle(
                            color: _openMode == 'date'
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Hours mode: chip row
            if (_openMode == 'hours') ...[
              const Text(
                'Открыть через',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _hourOptions.map((h) {
                  final selected = _selectedHours == h;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedHours = h),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient:
                            selected ? AppColors.primaryGradient : null,
                        color: selected ? null : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        // ignore: unnecessary_brace_in_string_interps
                        '${h}ч',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Date mode: date picker
            if (_openMode == 'date') ...[
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!)
                            : 'Выберите дату',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Colors.white
                              : AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios,
                          color: AppColors.textHint, size: 14),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Pending messages list
            const Text(
              'Ожидающие сообщения',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Consumer<FeaturesProvider>(
              builder: (context, fp, _) {
                final mine = fp.allSecretMessages
                    .where((m) => m.isMine)
                    .toList();

                if (mine.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Нет отправленных сообщений',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  );
                }

                return Column(
                  children: mine
                      .map((m) => _SecretMessageCard(
                            msg: m,
                            remaining: _formatRemaining(m.openAtUtc),
                            isExpired: _isExpired(m.openAtUtc),
                          ))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            AppButton(
              text: 'Отправить послание 💌',
              isLoading: _isSubmitting,
              onPressed: _send,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Secret Message Card ────────────────────────────────────────────────────

class _SecretMessageCard extends StatelessWidget {
  final SecretMessageModel msg;
  final String remaining;
  final bool isExpired;

  const _SecretMessageCard({
    required this.msg,
    required this.remaining,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text('🤫', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Сообщение для партнёра',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isExpired
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              remaining,
              style: TextStyle(
                color: isExpired ? AppColors.accentGreen : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
