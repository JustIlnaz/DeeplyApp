class ChallengeTemplateModel {
  final int id;
  final String title;
  final int durationDays;

  ChallengeTemplateModel({required this.id, required this.title, required this.durationDays});

  factory ChallengeTemplateModel.fromJson(Map<String, dynamic> j) => ChallengeTemplateModel(
    id: j['id'],
    title: j['title'] ?? '',
    durationDays: j['durationDays'] ?? 7,
  );
}

class ChallengeProgressModel {
  final int id;
  final int templateId;
  final String title;
  final int durationDays;
  final List<String> completedDays;
  final bool isCompleted;

  ChallengeProgressModel({
    required this.id,
    required this.templateId,
    required this.title,
    required this.durationDays,
    required this.completedDays,
    required this.isCompleted,
  });

  factory ChallengeProgressModel.fromJson(Map<String, dynamic> j) => ChallengeProgressModel(
    id: j['id'],
    templateId: j['templateId'] ?? 0,
    title: j['title'] ?? '',
    durationDays: j['durationDays'] ?? 7,
    completedDays: List<String>.from(j['completedDays'] ?? []),
    isCompleted: j['isCompleted'] ?? false,
  );
}
