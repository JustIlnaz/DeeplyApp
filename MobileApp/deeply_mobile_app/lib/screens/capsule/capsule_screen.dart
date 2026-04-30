import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_button.dart';

class CapsuleScreen extends StatefulWidget {
  const CapsuleScreen({super.key});

  @override
  State<CapsuleScreen> createState() => _CapsuleScreenState();
}

class _CapsuleScreenState extends State<CapsuleScreen> {
  final _letterController = TextEditingController();
  String _openDate = '17 апреля 2027';

  final List<Map<String, dynamic>> _capsules = [
    {'title': 'Наш первый год', 'date': 'Откроется 14 февраля 2027', 'locked': true},
  ];

  @override
  void dispose() {
    _letterController.dispose();
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
          'Капсула времени',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(child: Text('⏳', style: TextStyle(fontSize: 36))),
              ),
            ),
            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Напиши письмо в будущее',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            Center(
              child: Text(
                'Оно откроется в выбранную дату',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Ваше письмо',
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
                controller: _letterController,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Дорогая Настя...\n\nЧерез год, когда ты откроешь это письмо, мы уже...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Дата открытия',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2027, 4, 17),
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime(2035),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.dark(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  setState(() {
                    _openDate =
                        '${picked.day} ${_monthName(picked.month)} ${picked.year}';
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      _openDate,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.textHint, size: 14),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Existing capsules
            const Text(
              'Созданные капсулы',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ..._capsules.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['title'],
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c['date'],
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🔒 Закрыт',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 24),
            AppButton(text: 'Запечатать капсулу 🕰', onPressed: () {}),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = ['', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
    return months[m];
  }
}
