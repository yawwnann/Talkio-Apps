/// User Model
/// Model untuk data user (orang tua, terapis, admin)
/// Matches backend API response format
class UserModel {
  final String id;
  final String email;
  final String? name;
  final String role; // PARENT, THERAPIST, ADMIN
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON - matches backend response format
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      role: json['role'] ?? 'PARENT',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Copy with new values
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check user role
  bool get isParent => role == 'PARENT';
  bool get isTherapist => role == 'THERAPIST';
  bool get isAdmin => role == 'ADMIN';

  // Legacy role mapping for backward compatibility
  String get legacyRole {
    switch (role) {
      case 'PARENT':
        return 'orang_tua';
      case 'THERAPIST':
        return 'terapis';
      case 'ADMIN':
        return 'admin';
      default:
        return role.toLowerCase();
    }
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        role.hashCode;
  }
}