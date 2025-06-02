// Models
class User {
  final int userId;
  final String email;
  final String fullName;
  final String role;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
    );
  }
}
