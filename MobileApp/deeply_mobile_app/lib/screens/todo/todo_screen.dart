import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/features_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/couple_provider.dart';
import '../../data/models/todo_model.dart';
import '../../widgets/common/app_button.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  String _filter = 'Все';
  final _filters = ['Все', 'Мои', 'Партнёр', 'Готово'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeaturesProvider>().fetchTodos();
    });
  }

  List<TodoModel> _filtered(
    List<TodoModel> todos,
    int? myUserId,
    int? partnerId,
  ) {
    switch (_filter) {
      case 'Мои':
        return todos
            .where(
              (t) =>
                  t.responsibleUserId == myUserId ||
                  t.responsibleUserId == null,
            )
            .toList();
      case 'Партнёр':
        return todos.where((t) => t.responsibleUserId == partnerId).toList();
      case 'Готово':
        return todos.where((t) => t.isDone).toList();
      default:
        return todos;
    }
  }

  void _openAddSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    int? selectedUserId; // null = both

    final myUserId = context.read<AuthProvider>().userId;
    final partnerId = context.read<CoupleProvider>().partnerId;
    final partnerName = context.read<CoupleProvider>().partnerName;

    // 0 = Оба, 1 = Я, 2 = Партнёр
    int responsibleMode = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textHint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Новая задача',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Что нужно сделать?',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: AppColors.bgInput,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Кто отвечает?',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ResponsibleToggleButton(
                        label: 'Я',
                        isActive: responsibleMode == 1,
                        onTap: () => setSheetState(() {
                          responsibleMode = 1;
                          selectedUserId = myUserId;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _ResponsibleToggleButton(
                        label: partnerName ?? 'Партнёр',
                        isActive: responsibleMode == 2,
                        onTap: () => setSheetState(() {
                          responsibleMode = 2;
                          selectedUserId = partnerId;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _ResponsibleToggleButton(
                        label: 'Оба',
                        isActive: responsibleMode == 0,
                        onTap: () => setSheetState(() {
                          responsibleMode = 0;
                          selectedUserId = null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Добавить',
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Введите название задачи'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      final fp = context.read<FeaturesProvider>();
                      await fp.createTodo(
                        title: title,
                        responsibleUserId: selectedUserId,
                      );
                      if (ctx.mounted) Navigator.of(ctx).pop();
                      await fp.fetchTodos();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FeaturesProvider>();
    final auth = context.watch<AuthProvider>();
    final couple = context.watch<CoupleProvider>();

    final myUserId = auth.userId;
    final partnerId = couple.partnerId;
    final partnerName = couple.partnerName;

    final filtered = _filtered(fp.todos, myUserId, partnerId);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'To-Do для двоих',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _openAddSheet(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: isActive ? AppColors.primaryGradient : null,
                          color: isActive ? null : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Todo list
          Expanded(
            child: fp.isLoading && fp.todos.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('📝', style: TextStyle(fontSize: 40)),
                            SizedBox(height: 12),
                            Text(
                              'Нет задач 📝',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final todo = filtered[index];
                          return _TodoCard(
                            todo: todo,
                            myUserId: myUserId,
                            partnerId: partnerId,
                            partnerName: partnerName,
                            onToggle: () {
                              context
                                  .read<FeaturesProvider>()
                                  .updateTodoStatus(todo.id, !todo.isDone);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _TodoCard extends StatelessWidget {
  final TodoModel todo;
  final int? myUserId;
  final int? partnerId;
  final String? partnerName;
  final VoidCallback onToggle;

  const _TodoCard({
    required this.todo,
    required this.myUserId,
    required this.partnerId,
    required this.partnerName,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = todo.responsibleUserId == myUserId;
    final isPartner =
        partnerId != null && todo.responsibleUserId == partnerId;
    final isBoth = todo.responsibleUserId == null;

    return Opacity(
      opacity: todo.isDone ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Checkbox circle
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.isDone ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color:
                        todo.isDone ? AppColors.primary : AppColors.textHint,
                    width: 2,
                  ),
                ),
                child: todo.isDone
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  color: todo.isDone ? AppColors.textHint : AppColors.textPrimary,
                  fontSize: 15,
                  decoration: todo.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Responsible badge
            if (isMine)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Я',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isPartner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD63AF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  partnerName ?? 'Партнёр',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isBoth)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Оба',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResponsibleToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ResponsibleToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : AppColors.bgInput,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
