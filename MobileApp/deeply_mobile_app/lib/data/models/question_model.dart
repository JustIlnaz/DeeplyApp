class QuestionModel {
  final int id;
  final String text;
  final String? category;
  final String? myAnswer;
  final String? partnerAnswer;

  QuestionModel({
    required this.id,
    required this.text,
    this.category,
    this.myAnswer,
    this.partnerAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> j) => QuestionModel(
    id: j['id'],
    text: j['text'] ?? '',
    category: j['category'],
    myAnswer: j['myAnswer'],
    partnerAnswer: j['partnerAnswer'],
  );
}
