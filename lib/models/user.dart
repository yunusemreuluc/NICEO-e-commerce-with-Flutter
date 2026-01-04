class User {
  final int? id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String password;
  final String? createdAt;
  final String? avatar;

  User({
    this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.password,
    this.createdAt,
    this.avatar,
  });

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as int?,
    name: m['name'] ?? '',
    surname: m['surname'] ?? '',
    email: m['email'] ?? '',
    phone: m['phone'] ?? '',
    password: m['password'] ?? '',
    createdAt: m['created_at']?.toString(),
    avatar: m['avatar']?.toString(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'surname': surname,
    'email': email,
    'phone': phone,
    'password': password,
    'created_at': createdAt,
    'avatar': avatar,
  };
}
