import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = 17;
  final List<String> _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  final List<Map<String, dynamic>> _events = [
    {'emoji': '💍', 'title': 'Годовщина', 'date': '14 апреля', 'color': Color(0xFFD63AF5)},
    {'emoji': '🎬', 'title': 'Кино вместе', 'date': '22 апреля', 'color': Color(0xFF5B6AF5)},
    {'emoji': '🍕', 'title': 'Ужин в ресторане', 'date': '28 апреля', 'color': Color(0xFFFF9800)},
  ];

  // days with events
  final Set<int> _eventDays = {14, 17, 22, 28};

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
          'Общий календарь',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Апрель 2026',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Week days header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekDays.map((d) => SizedBox(
                width: 36,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),

            // Calendar grid
            _buildCalendarGrid(),

            const SizedBox(height: 28),

            const Text(
              'Ближайшие события',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ..._events.map((e) => _EventCard(event: e)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // April 2026 starts on Wednesday (index 2)
    const startOffset = 2;
    const daysInMonth = 30;

    final cells = <Widget>[];

    // Empty cells before start
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox(width: 36, height: 36));
    }

    // Day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final isSelected = day == _selectedDay;
      final hasEvent = _eventDays.contains(day);
      final isToday = day == 17;

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDay = day),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.primary : Colors.transparent,
            border: isToday && !isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              if (hasEvent && !isSelected)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ));
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: cells,
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (event['color'] as Color).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(event['emoji'], style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  event['date'],
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
        ],
      ),
    );
  }
}
