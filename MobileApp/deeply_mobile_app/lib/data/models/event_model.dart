class EventModel {
  final int id;
  final String title;
  final String? description;
  final String startsAtUtc;
  final String? endsAtUtc;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startsAtUtc,
    this.endsAtUtc,
  });

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
    id: j['id'],
    title: j['title'] ?? '',
    description: j['description'],
    startsAtUtc: j['startsAtUtc'] ?? '',
    endsAtUtc: j['endsAtUtc'],
  );
}
