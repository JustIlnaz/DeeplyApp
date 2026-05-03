class LoveMapPointModel {
  final int id;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String? description;
  final String? address;

  LoveMapPointModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.description,
    this.address,
  });

  factory LoveMapPointModel.fromJson(Map<String, dynamic> j) => LoveMapPointModel(
    id: j['id'],
    latitude: (j['latitude'] ?? 0).toDouble(),
    longitude: (j['longitude'] ?? 0).toDouble(),
    photoUrl: j['photoUrl'],
    description: j['description'],
    address: j['address'],
  );
}
