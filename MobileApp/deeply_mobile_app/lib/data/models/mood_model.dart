class MoodModel {
  final int id;
  final int userId;
  final String moodType;
  final String? comment;
  final String day;

  MoodModel({
    required this.id,
    required this.userId,
    required this.moodType,
    this.comment,
    required this.day,
  });

  factory MoodModel.fromJson(Map<String, dynamic> j) => MoodModel(
    id: j['id'],
    userId: j['userId'],
    moodType: j['moodType'] ?? 'neutral',
    comment: j['comment'],
    day: j['day'] ?? '',
  );
}
