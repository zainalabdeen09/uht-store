class AppUser {
  final int? id;
  final String username;
  final String password;
  final String email;
  final String phone;
  final String gender;
  final String address;
  final String avatarPath;
  final String createdAt;

  AppUser({
    this.id,
    required this.username,
    required this.password,
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.address = '',
    this.avatarPath = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
        'gender': gender,
        'address': address,
        'avatarPath': avatarPath,
        'createdAt': createdAt,
      };

  static AppUser fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'],
        username: m['username'],
        password: m['password'],
        email: m['email'] ?? '',
        phone: m['phone'] ?? '',
        gender: m['gender'] ?? '',
        address: m['address'] ?? '',
        avatarPath: m['avatarPath'] ?? '',
        createdAt: m['createdAt'],
      );
}
