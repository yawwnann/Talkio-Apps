/// Anak Model
/// Model untuk data anak yang akan diterapi
class AnakModel {
  final String id;
  final String parentId; // ID orang tua
  final String name;
  final DateTime birthDate;
  final String gender; // L/P
  final String? profileImage;
  final String? medicalHistory;
  final String? currentCondition;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  AnakModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.birthDate,
    required this.gender,
    this.profileImage,
    this.medicalHistory,
    this.currentCondition,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }
  
  // Get age in months for more precise calculation
  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12;
    months += now.month - birthDate.month;
    
    if (now.day < birthDate.day) {
      months--;
    }
    
    return months;
  }
  
  // Convert from JSON
  factory AnakModel.fromJson(Map<String, dynamic> json) {
    return AnakModel(
      id: json['id'] ?? '',
      parentId: json['parent_id'] ?? '',
      name: json['name'] ?? '',
      birthDate: DateTime.parse(json['birth_date'] ?? DateTime.now().toIso8601String()),
      gender: json['gender'] ?? '',
      profileImage: json['profile_image'],
      medicalHistory: json['medical_history'],
      currentCondition: json['current_condition'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'profile_image': profileImage,
      'medical_history': medicalHistory,
      'current_condition': currentCondition,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Copy with new values
  AnakModel copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? profileImage,
    String? medicalHistory,
    String? currentCondition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnakModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      currentCondition: currentCondition ?? this.currentCondition,
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
        other.birthDate == birthDate &&
        other.gender == gender;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        parentId.hashCode ^
        name.hashCode ^
        birthDate.hashCode ^
        gender.hashCode;
  }
}