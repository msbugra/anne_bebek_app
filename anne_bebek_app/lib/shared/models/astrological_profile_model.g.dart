// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'astrological_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AstrologicalProfile _$AstrologicalProfileFromJson(Map<String, dynamic> json) =>
    AstrologicalProfile(
      id: (json['id'] as num?)?.toInt(),
      personId: (json['personId'] as num).toInt(),
      personType: $enumDecode(_$PersonTypeEnumMap, json['personType']),
      zodiacSign: $enumDecode(_$ZodiacSignEnumMap, json['zodiacSign']),
      birthDate: DateTime.parse(json['birthDate'] as String),
      birthTime: json['birthTime'] as String?,
      birthCity: json['birthCity'] as String?,
      birthCountry: json['birthCountry'] as String?,
      personalityTraits:
          (json['personalityTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      compatibilityNotes: json['compatibilityNotes'] as String?,
      birthChartData: json['birthChartData'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AstrologicalProfileToJson(
  AstrologicalProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'personId': instance.personId,
  'personType': _$PersonTypeEnumMap[instance.personType]!,
  'zodiacSign': _$ZodiacSignEnumMap[instance.zodiacSign]!,
  'birthDate': instance.birthDate.toIso8601String(),
  'birthTime': instance.birthTime,
  'birthCity': instance.birthCity,
  'birthCountry': instance.birthCountry,
  'personalityTraits': instance.personalityTraits,
  'compatibilityNotes': instance.compatibilityNotes,
  'birthChartData': instance.birthChartData,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$PersonTypeEnumMap = {
  PersonType.mother: 'mother',
  PersonType.baby: 'baby',
};

const _$ZodiacSignEnumMap = {
  ZodiacSign.aries: 'aries',
  ZodiacSign.taurus: 'taurus',
  ZodiacSign.gemini: 'gemini',
  ZodiacSign.cancer: 'cancer',
  ZodiacSign.leo: 'leo',
  ZodiacSign.virgo: 'virgo',
  ZodiacSign.libra: 'libra',
  ZodiacSign.scorpio: 'scorpio',
  ZodiacSign.sagittarius: 'sagittarius',
  ZodiacSign.capricorn: 'capricorn',
  ZodiacSign.aquarius: 'aquarius',
  ZodiacSign.pisces: 'pisces',
};
