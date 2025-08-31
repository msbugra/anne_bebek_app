import 'package:json_annotation/json_annotation.dart';

part 'baby_model.g.dart';

enum BabyGender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('unknown')
  unknown,
}

@JsonSerializable()
class BabyModel {
  final int? id;
  final int motherId;
  final String name;
  final DateTime birthDate;
  final String? birthTime;
  final double? birthWeight; // gram cinsinden
  final double? birthHeight; // cm cinsinden
  final double? birthHeadCircumference; // cm cinsinden
  final String? birthCity;
  final BabyGender? gender;
  final String? zodiacSign;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BabyModel({
    this.id,
    required this.motherId,
    required this.name,
    required this.birthDate,
    this.birthTime,
    this.birthWeight,
    this.birthHeight,
    this.birthHeadCircumference,
    this.birthCity,
    this.gender,
    this.zodiacSign,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory BabyModel.fromJson(Map<String, dynamic> json) =>
      _$BabyModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$BabyModelToJson(this);

  // Factory constructor from database map
  factory BabyModel.fromMap(Map<String, dynamic> map) {
    return BabyModel(
      id: map['id'] as int?,
      motherId: map['mother_id'] as int,
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birth_date'] as String),
      birthTime: map['birth_time'] as String?,
      birthWeight: map['birth_weight'] as double?,
      birthHeight: map['birth_height'] as double?,
      birthHeadCircumference: map['birth_head_circumference'] as double?,
      birthCity: map['birth_city'] as String?,
      gender: map['gender'] != null
          ? BabyGender.values.firstWhere(
              (e) => e.toString().split('.').last == map['gender'],
              orElse: () => BabyGender.unknown,
            )
          : null,
      zodiacSign: map['zodiac_sign'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mother_id': motherId,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'birth_time': birthTime,
      'birth_weight': birthWeight,
      'birth_height': birthHeight,
      'birth_head_circumference': birthHeadCircumference,
      'birth_city': birthCity,
      'gender': gender?.toString().split('.').last,
      'zodiac_sign': zodiacSign,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method
  BabyModel copyWith({
    int? id,
    int? motherId,
    String? name,
    DateTime? birthDate,
    String? birthTime,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    String? birthCity,
    BabyGender? gender,
    String? zodiacSign,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BabyModel(
      id: id ?? this.id,
      motherId: motherId ?? this.motherId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthWeight: birthWeight ?? this.birthWeight,
      birthHeight: birthHeight ?? this.birthHeight,
      birthHeadCircumference:
          birthHeadCircumference ?? this.birthHeadCircumference,
      birthCity: birthCity ?? this.birthCity,
      gender: gender ?? this.gender,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Yaş hesaplama metodları
  int get ageInDays {
    return DateTime.now().difference(birthDate).inDays;
  }

  int get ageInWeeks {
    return (ageInDays / 7).floor();
  }

  int get ageInMonths {
    DateTime now = DateTime.now();
    int months = now.month - birthDate.month;
    int years = now.year - birthDate.year;
    return months + (years * 12);
  }

  int get ageInYears {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Yaş grubu belirleme
  String get ageGroup {
    int days = ageInDays;
    if (days <= 28) return 'Yenidoğan';
    if (days <= 365) return 'Bebek';
    if (days <= 1095) return '1-3 Yaş';
    if (days <= 1825) return '3-5 Yaş';
    return '5+ Yaş';
  }

  // Prematüre olup olmadığını kontrol et
  bool get isPremature {
    // Gebelik 40 hafta (280 gün) olarak kabul edilir
    // 37 haftadan (259 gün) önce doğanlar prematüre sayılır
    return ageInDays < 0; // Bu hesaplama için ek bilgi gerekebilir
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BabyModel &&
        other.id == id &&
        other.motherId == motherId &&
        other.name == name &&
        other.birthDate == birthDate &&
        other.birthTime == birthTime &&
        other.birthWeight == birthWeight &&
        other.birthHeight == birthHeight &&
        other.birthHeadCircumference == birthHeadCircumference &&
        other.birthCity == birthCity &&
        other.gender == gender &&
        other.zodiacSign == zodiacSign;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      motherId,
      name,
      birthDate,
      birthTime,
      birthWeight,
      birthHeight,
      birthHeadCircumference,
      birthCity,
      gender,
      zodiacSign,
    );
  }

  @override
  String toString() {
    return 'BabyModel(id: $id, motherId: $motherId, name: $name, '
        'birthDate: $birthDate, birthTime: $birthTime, '
        'birthWeight: $birthWeight, birthHeight: $birthHeight, '
        'birthHeadCircumference: $birthHeadCircumference, '
        'birthCity: $birthCity, gender: $gender, zodiacSign: $zodiacSign, '
        'ageInDays: $ageInDays, ageGroup: $ageGroup)';
  }
}
