class TodoModel {
  final int id;
  final String title;
  final int? responsibleUserId;
  final String status; // 'todo', 'done'

  TodoModel({
    required this.id,
    required this.title,
    this.responsibleUserId,
    required this.status,
  });

  bool get isDone => status == 'done';

  factory TodoModel.fromJson(Map<String, dynamic> j) => TodoModel(
    id: j['id'],
    title: j['title'] ?? '',
    responsibleUserId: j['responsibleUserId'],
    status: j['status'] ?? 'todo',
  );
}
