import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/event_model.dart';
import '../../widgets/common/app_button.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<String> _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  late DateTime _currentMonth;
  int? _selectedDay;

  static const _monthNames = [
    '',
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  static const _monthNamesGenitive = [
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
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturesProvider>().fetchEvents();
    });
  }

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  int get _firstWeekdayOffset => _currentMonth.weekday - 1;

  String get _monthYearLabel =>
      '${_monthNames[_currentMonth.month]} ${_currentMonth.year}';

  String _formatEventDate(String utcStr) {
    try {
      final dt = DateTime.parse(utcStr).toLocal();
      return '${dt.day} ${_monthNamesGenitive[dt.month]}';
    } catch (_) {
      return utcStr;
    }
  }

  Set<int> _eventDaysForCurrentMonth(List<EventModel> events) {
    final result = <int>{};
    for (final e in events) {
      try {
        final dt = DateTime.parse(e.startsAtUtc).toLocal();
        if (dt.year == _currentMonth.year &&
            dt.month == _currentMonth.month) {
          result.add(dt.day);
        }
      } catch (_) {}
    }
    return result;
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String dateLabel =
        '${selectedDate.day} ${_monthNamesGenitive[selectedDate.month]} ${selectedDate.year}';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Новое событие',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Название события',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                          dateLabel =
                              '${picked.day} ${_monthNamesGenitive[picked.month]} ${picked.year}';
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgInput,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Text(dateLabel,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios,
                              color: AppColors.textHint, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Отмена',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                AppButton(
                  text: 'Создать',
                  width: 110,
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    Navigator.pop(ctx);
                    final fp = context.read<FeaturesProvider>();
                    final scaffoldMsg = ScaffoldMessenger.of(context);
                    final ok = await fp.createEvent(
                        title: title, startsAt: selectedDate);
                    await fp.fetchEvents();
                    if (ok) {
                      scaffoldMsg.showSnackBar(
                        const SnackBar(content: Text('Событие создано! 📅')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
          'Общий календарь',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: _showAddDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<FeaturesProvider>(
        builder: (context, fp, _) {
          final now = DateTime.now();
          final eventDays = _eventDaysForCurrentMonth(fp.events);
          final upcoming = fp.events.where((e) {
            try {
              return DateTime.parse(e.startsAtUtc).isAfter(now);
            } catch (_) {
              return false;
            }
          }).toList()
            ..sort((a, b) => a.startsAtUtc.compareTo(b.startsAtUtc));

          // Show at most top 5 upcoming
          final topUpcoming = upcoming.take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  _monthYearLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                // Week days header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _weekDays
                      .map((d) => SizedBox(
                            width: 36,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),

                _buildCalendarGrid(eventDays, now),

                const SizedBox(height: 28),
                const Text(
                  'Ближайшие события',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                if (topUpcoming.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Нет предстоящих событий',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                  )
                else
                  ...topUpcoming.map((e) => _EventCard(
                        event: e,
                        formattedDate: _formatEventDate(e.startsAtUtc),
                      )),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(Set<int> eventDays, DateTime now) {
    final cells = <Widget>[];

    // Empty leading cells for alignment
    for (int i = 0; i < _firstWeekdayOffset; i++) {
      cells.add(const SizedBox(width: 36, height: 36));
    }

    for (int day = 1; day <= _daysInMonth; day++) {
      final isSelected = day == _selectedDay;
      final hasEvent = eventDays.contains(day);
      final isToday = now.year == _currentMonth.year &&
          now.month == _currentMonth.month &&
          day == now.day;

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
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.normal,
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

    return Wrap(spacing: 4, runSpacing: 4, children: cells);
  }
}

// ── Event Card ─────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final EventModel event;
  final String formattedDate;

  const _EventCard({required this.event, required this.formattedDate});

  String get _emoji {
    final t = event.title.toLowerCase();
    if (t.contains('годовщин') || t.contains('anniversar')) return '💍';
    if (t.contains('кино') || t.contains('film')) return '🎬';
    if (t.contains('ужин') || t.contains('ресторан')) return '🍕';
    return '📅';
  }

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
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Center(child: Text(_emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
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
