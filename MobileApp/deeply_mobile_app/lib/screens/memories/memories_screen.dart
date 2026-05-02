import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../data/models/memory_model.dart';
import '../../widgets/common/app_button.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  String _filter = 'Все';
  final List<String> _filters = ['Все', 'Фото', 'Видео', 'Заметки'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturesProvider>().fetchMemories();
    });
  }

  List<MemoryModel> _filtered(List<MemoryModel> all) {
    switch (_filter) {
      case 'Фото':
        return all.where((m) => m.photoUrl != null).toList();
      case 'Видео':
        return all.where((m) => m.videoUrl != null).toList();
      case 'Заметки':
        return all
            .where(
                (m) => m.text != null && m.photoUrl == null && m.videoUrl == null)
            .toList();
      default:
        return all;
    }
  }

  void _showAddSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Новое воспоминание',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Что произошло?...',
                    hintStyle: TextStyle(color: AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Сохранить',
                onPressed: () async {
                  final text = ctrl.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(ctx);
                  final fp = context.read<FeaturesProvider>();
                  await fp.addMemory(text: text);
                  await fp.fetchMemories();
                },
              ),
            ],
          ),
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
          'Лента воспоминаний',
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
            onPressed: _showAddSheet,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<FeaturesProvider>(
        builder: (context, fp, _) {
          final filtered = _filtered(fp.memories);

          return Column(
            children: [
              // Filter tabs
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final selected = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Text(
                            f,
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
                ),
              ),

              if (fp.isLoading && fp.memories.isEmpty)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (filtered.isEmpty && !fp.isLoading)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Пока нет воспоминаний 💜',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _MemoryCard(memory: filtered[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Memory Card ────────────────────────────────────────────────────────────

class _MemoryCard extends StatelessWidget {
  final MemoryModel memory;
  const _MemoryCard({required this.memory});

  static const _paletteColors = [
    Color(0xFF5B6AF5),
    Color(0xFFD63AF5),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
  ];

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

  String _formatDate(String utcStr) {
    try {
      final dt = DateTime.parse(utcStr).toLocal();
      return '${dt.day} ${_monthNames[dt.month]} ${dt.year}';
    } catch (_) {
      return utcStr;
    }
  }

  String get _title {
    if (memory.isPinned) {
      // still use content-based label but capped at 30
      if (memory.photoUrl != null) return 'Фото';
      if (memory.videoUrl != null) return 'Видео';
      final t = memory.text ?? '';
      return t.length > 30 ? t.substring(0, 30) : t;
    }
    if (memory.photoUrl != null) return 'Фото';
    if (memory.videoUrl != null) return 'Видео';
    final t = memory.text ?? '';
    return t.length > 30 ? t.substring(0, 30) : t;
  }

  String get _description {
    if (memory.photoUrl != null) return 'Фотография';
    if (memory.videoUrl != null) return 'Видеозапись';
    final t = memory.text ?? '';
    return t.length > 60 ? '${t.substring(0, 60)}...' : t;
  }

  String get _emoji {
    if (memory.isPinned) return '⭐';
    if (memory.photoUrl != null) return '📷';
    if (memory.videoUrl != null) return '🎬';
    return '📝';
  }

  Color get _iconBgColor {
    if (memory.isPinned) return AppColors.primary;
    return _paletteColors[memory.id % _paletteColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          // Left square icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _iconBgColor.withValues(alpha: memory.isPinned ? 0.3 : 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          // Right column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (memory.isPinned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'топ',
                          style: TextStyle(
                              color: AppColors.accentGreen, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(memory.createdAtUtc),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  _description,
                  style: const TextStyle(
                      color: AppColors.textHint, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
