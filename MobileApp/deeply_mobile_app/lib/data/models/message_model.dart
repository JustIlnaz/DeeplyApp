class MessageModel {
  final int id;
  final int coupleId;
  final int senderUserId;
  final String? text;
  final String? photoUrl;
  final bool isRead;
  final String sentAtUtc;

  MessageModel({
    required this.id,
    required this.coupleId,
    required this.senderUserId,
    this.text,
    this.photoUrl,
    required this.isRead,
    required this.sentAtUtc,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id: j['id'],
    coupleId: j['coupleId'],
    senderUserId: j['senderUserId'],
    text: j['text'],
    photoUrl: j['photoUrl'],
    isRead: j['isRead'] ?? false,
    sentAtUtc: j['sentAtUtc'] ?? '',
  );
}
