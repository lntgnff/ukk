class User {
  final int? id;
  final String email;
  final String password;
  final int isAdmin;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.isAdmin,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'].toString(),
      password: map['password'].toString(),
      isAdmin: map['is_admin'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'is_admin': isAdmin,
    };
  }
}