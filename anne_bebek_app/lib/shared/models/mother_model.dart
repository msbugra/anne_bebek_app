import 'package:json_annotation/json_annotation.dart';

part 'mother_model.g.dart';

@JsonSerializable()
class MotherModel {
  final int? id;
  final String name;
  final DateTime? birthDate;
  final String? birthCity;
  final bool astrologyEnabled;
  final String? zodiacSign;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MotherModel({
    this.id,
    required this.name,
    this.birthDate,
    this.birthCity,
    this.astrologyEnabled = false,
    this.zodiacSign,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory MotherModel.fromJson(Map<String, dynamic> json) =>
      _$MotherModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$MotherModelToJson(this);

  // Factory constructor from database map
  factory MotherModel.fromMap(Map<String, dynamic> map) {
    return MotherModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'] as String)
          : null,
      birthCity: map['birth_city'] as String?,
      astrologyEnabled: (map['astrology_enabled'] as int) == 1,
      zodiacSign: map['zodiac_sign'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate?.toIso8601String(),
      'birth_city': birthCity,
      'astrology_enabled': astrologyEnabled ? 1 : 0,
      'zodiac_sign': zodiacSign,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  MotherModel copyWith({
    int? id,
    String? name,
    DateTime? birthDate,
    String? birthCity,
    bool? astrologyEnabled,
    String? zodiacSign,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MotherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthCity: birthCity ?? this.birthCity,
      astrologyEnabled: astrologyEnabled ?? this.astrologyEnabled,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MotherModel &&
        other.id == id &&
        other.name == name &&
        other.birthDate == birthDate &&
        other.birthCity == birthCity &&
        other.astrologyEnabled == astrologyEnabled &&
        other.zodiacSign == zodiacSign;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      birthDate,
      birthCity,
      astrologyEnabled,
      zodiacSign,
    );
  }

  @override
  String toString() {
    return 'MotherModel(id: $id, name: $name, birthDate: $birthDate, '
        'birthCity: $birthCity, astrologyEnabled: $astrologyEnabled, '
        'zodiacSign: $zodiacSign)';
  }
}
