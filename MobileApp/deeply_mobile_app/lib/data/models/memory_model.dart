class MemoryModel {
  final int id;
  final int coupleId;
  final String? text;
  final String? photoUrl;
  final String? videoUrl;
  final bool isPinned;
  final String createdAtUtc;

  MemoryModel({
    required this.id,
    required this.coupleId,
    this.text,
    this.photoUrl,
    this.videoUrl,
    required this.isPinned,
    required this.createdAtUtc,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> j) => MemoryModel(
    id: j['id'],
    coupleId: j['coupleId'],
    text: j['text'],
    photoUrl: j['photoUrl'],
    videoUrl: j['videoUrl'],
    isPinned: j['isPinned'] ?? false,
    createdAtUtc: j['createdAtUtc'] ?? '',
  );
}
