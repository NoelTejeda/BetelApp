class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.alumno,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: _parseRole(map['role']),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'isActive': isActive,
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
