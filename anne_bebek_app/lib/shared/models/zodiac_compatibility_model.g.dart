// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zodiac_compatibility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZodiacCompatibility _$ZodiacCompatibilityFromJson(Map<String, dynamic> json) =>
    ZodiacCompatibility(
      id: (json['id'] as num?)?.toInt(),
      motherSign: $enumDecode(_$ZodiacSignEnumMap, json['motherSign']),
      babySign: $enumDecode(_$ZodiacSignEnumMap, json['babySign']),
      compatibilityScore: (json['compatibilityScore'] as num).toInt(),
      compatibilityLevel: $enumDecode(
        _$CompatibilityLevelEnumMap,
        json['compatibilityLevel'],
      ),
      compatibilityDescription: json['compatibilityDescription'] as String,
      strengths:
          (json['strengths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      challenges:
          (json['challenges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      parentingTips:
          (json['parentingTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      communicationTips:
          (json['communicationTips'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dailyAdvice: json['dailyAdvice'] as String?,
      monthlyForecast: json['monthlyForecast'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ZodiacCompatibilityToJson(
  ZodiacCompatibility instance,
) => <String, dynamic>{
  'id': instance.id,
  'motherSign': _$ZodiacSignEnumMap[instance.motherSign]!,
  'babySign': _$ZodiacSignEnumMap[instance.babySign]!,
  'compatibilityScore': instance.compatibilityScore,
  'compatibilityLevel':
      _$CompatibilityLevelEnumMap[instance.compatibilityLevel]!,
  'compatibilityDescription': instance.compatibilityDescription,
  'strengths': instance.strengths,
  'challenges': instance.challenges,
  'parentingTips': instance.parentingTips,
  'communicationTips': instance.communicationTips,
  'dailyAdvice': instance.dailyAdvice,
  'monthlyForecast': instance.monthlyForecast,
  'createdAt': instance.createdAt.toIso8601String(),
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

const _$CompatibilityLevelEnumMap = {
  CompatibilityLevel.excellent: 'excellent',
  CompatibilityLevel.veryGood: 'very_good',
  CompatibilityLevel.good: 'good',
  CompatibilityLevel.moderate: 'moderate',
  CompatibilityLevel.challenging: 'challenging',
};
