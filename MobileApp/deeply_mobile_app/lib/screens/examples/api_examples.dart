import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/core.dart';

/// Пример экрана авторизации с использованием провайдеров
class LoginExampleScreen extends ConsumerWidget {
  const LoginExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (authState.isLoading)
              const CircularProgressIndicator()
            else if (authState.isAuthenticated)
              const Text('Вы авторизованы!')
            else if (authState.error != null)
              Text('Ошибка: ${authState.error}')
            else
              ElevatedButton(
                onPressed: () async {
                  try {
                    await authNotifier.login('test@example.com', 'password123');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Вход успешен!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
                    }
                  }
                },
                child: const Text('Войти'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Пример экрана чата
class ChatExampleScreen extends ConsumerWidget {
  const ChatExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Чат')),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? const Center(child: Text('Нет сообщений'))
                : ListView.builder(
                    reverse: true,
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return ListTile(
                        title: Text(message.content ?? ''),
                        subtitle: Text(message.createdAt.toString()),
                        trailing: message.isRead
                            ? const Icon(Icons.done_all)
                            : null,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await chatNotifier.sendMessage('Привет!');
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Пример экрана воспоминаний
class MemoriesExampleScreen extends ConsumerWidget {
  const MemoriesExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);
    final memoriesNotifier = ref.read(memoriesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Воспоминания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await memoriesNotifier.createMemory('Новое воспоминание', null);
            },
          ),
        ],
      ),
      body: memoriesAsync.when(
        data: (memories) {
          if (memories.isEmpty) {
            return const Center(
              child: Text('Нет воспоминаний. Добавьте первое!'),
            );
          }
          return ListView.builder(
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return Card(
                child: ListTile(
                  title: Text(memory.content ?? 'Без текста'),
                  subtitle: Text(memory.createdAt.toString()),
                  trailing: IconButton(
                    icon: Icon(
                      memory.isPinned
                          ? Icons.push_pin
                          : Icons.push_pin_outlined,
                    ),
                    onPressed: () {
                      memoriesNotifier.togglePin(memory.id);
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}

/// Пример экрана финансов
class FinanceExampleScreen extends ConsumerWidget {
  const FinanceExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(financeGoalsProvider);
    final goalNotifier = ref.read(createFinanceGoalProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовые цели'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await goalNotifier.createGoal(
                'Отпуск',
                10000.0,
                'travel',
                DateTime.now().add(const Duration(days: 180)),
              );
            },
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(child: Text('Нет целей. Добавьте первую!'));
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = goal.currentAmount / goal.targetAmount;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 8),
                      Text(
                        '${goal.currentAmount} / ${goal.targetAmount}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
    );
  }
}
