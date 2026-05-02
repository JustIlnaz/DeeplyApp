class UserModel {
  final int id;
  final String email;
  final String name;
  final String? gender;

  UserModel({required this.id, required this.email, required this.name, this.gender});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'],
    email: j['email'] ?? '',
    name: j['name'] ?? '',
    gender: j['gender'],
  );
}
