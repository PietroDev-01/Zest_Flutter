class UserModel {
  String id;
  String name;
  String email;
  String emoji;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.emoji,
  });

  // Do App para o firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'emoji': emoji,
    };
  }

  // Do Firebase para o App
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      emoji: map['emoji'] ?? '😊',
    );
  }
}