class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.alumno,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: _parseRole(map['role']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
    };
  }

  static UserRole _parseRole(String? roleStr) {
    if (roleStr == 'maestro') return UserRole.maestro;
    if (roleStr == 'admin') return UserRole.admin;
    if (roleStr == 'seguridad') return UserRole.seguridad;
    return UserRole.alumno;
  }
}

enum UserRole {
  alumno,
  maestro,
  admin,
  seguridad,
}
