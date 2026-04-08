enum UserRole { student, admin }

class User {
  final String id;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? 'User ${json['id']}',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.student,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role == UserRole.admin ? 'admin' : 'student',
    };
  }
}
