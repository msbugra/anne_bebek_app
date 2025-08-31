// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mother_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MotherModel _$MotherModelFromJson(Map<String, dynamic> json) => MotherModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  birthCity: json['birthCity'] as String?,
  astrologyEnabled: json['astrologyEnabled'] as bool? ?? false,
  zodiacSign: json['zodiacSign'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$MotherModelToJson(MotherModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'birthDate': instance.birthDate?.toIso8601String(),
      'birthCity': instance.birthCity,
      'astrologyEnabled': instance.astrologyEnabled,
      'zodiacSign': instance.zodiacSign,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
