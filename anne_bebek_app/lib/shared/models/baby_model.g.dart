// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BabyModel _$BabyModelFromJson(Map<String, dynamic> json) => BabyModel(
  id: (json['id'] as num?)?.toInt(),
  motherId: (json['motherId'] as num).toInt(),
  name: json['name'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  birthTime: json['birthTime'] as String?,
  birthWeight: (json['birthWeight'] as num?)?.toDouble(),
  birthHeight: (json['birthHeight'] as num?)?.toDouble(),
  birthHeadCircumference: (json['birthHeadCircumference'] as num?)?.toDouble(),
  birthCity: json['birthCity'] as String?,
  gender: $enumDecodeNullable(_$BabyGenderEnumMap, json['gender']),
  zodiacSign: json['zodiacSign'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BabyModelToJson(BabyModel instance) => <String, dynamic>{
  'id': instance.id,
  'motherId': instance.motherId,
  'name': instance.name,
  'birthDate': instance.birthDate.toIso8601String(),
  'birthTime': instance.birthTime,
  'birthWeight': instance.birthWeight,
  'birthHeight': instance.birthHeight,
  'birthHeadCircumference': instance.birthHeadCircumference,
  'birthCity': instance.birthCity,
  'gender': _$BabyGenderEnumMap[instance.gender],
  'zodiacSign': instance.zodiacSign,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$BabyGenderEnumMap = {
  BabyGender.male: 'male',
  BabyGender.female: 'female',
  BabyGender.unknown: 'unknown',
};
