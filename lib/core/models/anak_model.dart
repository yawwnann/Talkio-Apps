/// Anak Model
/// Model untuk data anak yang akan diterapi
/// Matches backend API response format
class AnakModel {
  final String id;
  final String parentId; // ID orang tua
  final String name;
  final DateTime dateOfBirth;
  final String gender; // MALE or FEMALE
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnakModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.createdAt,
    this.updatedAt,
  });

  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  // Get age in months for more precise calculation
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12;
    months += now.month - dateOfBirth.month;

    if (now.day < dateOfBirth.day) {
      months--;
    }

    return months;
  }

  // Gender display value
  String get genderDisplay {
    switch (gender) {
      case 'MALE':
        return 'Laki-laki';
      case 'FEMALE':
        return 'Perempuan';
      default:
        return gender;
    }
  }

  // Convert from JSON - matches backend response format
  factory AnakModel.fromJson(Map<String, dynamic> json) {
    return AnakModel(
      id: json['id'] ?? '',
      parentId: json['parentId'] ?? json['parent_id'] ?? '',
      name: json['name'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? json['date_of_birth'] ?? DateTime.now().toIso8601String()),
      gender: json['gender'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  // Convert to JSON - for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'gender': gender,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Copy with new values
  AnakModel copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnakModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AnakModel(id: $id, name: $name, age: $age, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnakModel &&
        other.id == id &&
        other.parentId == parentId &&
        other.name == name &&
        other.dateOfBirth == dateOfBirth &&
        other.gender == gender;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        parentId.hashCode ^
        name.hashCode ^
        dateOfBirth.hashCode ^
        gender.hashCode;
  }
}