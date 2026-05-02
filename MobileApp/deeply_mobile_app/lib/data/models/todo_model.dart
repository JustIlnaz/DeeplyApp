class TodoModel {
  final int id;
  final String title;
  final int? responsibleUserId;
  final bool isDone;

  TodoModel({
    required this.id,
    required this.title,
    this.responsibleUserId,
    required this.isDone,
  });

  factory TodoModel.fromJson(Map<String, dynamic> j) => TodoModel(
    id: j['id'],
    title: j['title'] ?? '',
    responsibleUserId: j['responsibleUserId'],
    isDone: j['isDone'] ?? false,
  );
}
