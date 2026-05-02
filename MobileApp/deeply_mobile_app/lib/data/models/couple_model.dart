class CoupleModel {
  final int id;
  final int user1Id;
  final int? user2Id;
  final String inviteCode;
  final String? anniversaryDate;

  CoupleModel({
    required this.id,
    required this.user1Id,
    this.user2Id,
    required this.inviteCode,
    this.anniversaryDate,
  });

  factory CoupleModel.fromJson(Map<String, dynamic> j) => CoupleModel(
    id: j['id'],
    user1Id: j['user1Id'],
    user2Id: j['user2Id'],
    inviteCode: j['inviteCode'] ?? '',
    anniversaryDate: j['anniversaryDate'],
  );
}
