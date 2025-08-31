// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zodiac_characteristics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZodiacCharacteristics _$ZodiacCharacteristicsFromJson(
  Map<String, dynamic> json,
) => ZodiacCharacteristics(
  id: (json['id'] as num?)?.toInt(),
  zodiacSign: $enumDecode(_$ZodiacSignEnumMap, json['zodiacSign']),
  element: $enumDecode(_$ZodiacElementEnumMap, json['element']),
  rulingPlanet: json['rulingPlanet'] as String,
  positiveTraits:
      (json['positiveTraits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  challengingTraits:
      (json['challengingTraits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  childDevelopmentTips:
      (json['childDevelopmentTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  parentChildCommunicationTips:
      (json['parentChildCommunicationTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  earlyChildhoodTips:
      (json['earlyChildhoodTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  preschoolTips:
      (json['preschoolTips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  generalDescription: json['generalDescription'] as String,
  strengthsDescription: json['strengthsDescription'] as String,
  parentingApproach: json['parentingApproach'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ZodiacCharacteristicsToJson(
  ZodiacCharacteristics instance,
) => <String, dynamic>{
  'id': instance.id,
  'zodiacSign': _$ZodiacSignEnumMap[instance.zodiacSign]!,
  'element': _$ZodiacElementEnumMap[instance.element]!,
  'rulingPlanet': instance.rulingPlanet,
  'positiveTraits': instance.positiveTraits,
  'challengingTraits': instance.challengingTraits,
  'childDevelopmentTips': instance.childDevelopmentTips,
  'parentChildCommunicationTips': instance.parentChildCommunicationTips,
  'earlyChildhoodTips': instance.earlyChildhoodTips,
  'preschoolTips': instance.preschoolTips,
  'generalDescription': instance.generalDescription,
  'strengthsDescription': instance.strengthsDescription,
  'parentingApproach': instance.parentingApproach,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
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

const _$ZodiacElementEnumMap = {
  ZodiacElement.fire: 'fire',
  ZodiacElement.earth: 'earth',
  ZodiacElement.air: 'air',
  ZodiacElement.water: 'water',
};
