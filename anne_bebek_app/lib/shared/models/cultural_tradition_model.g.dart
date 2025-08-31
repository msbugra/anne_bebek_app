// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cultural_tradition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CulturalTraditionModel _$CulturalTraditionModelFromJson(
  Map<String, dynamic> json,
) => CulturalTraditionModel(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  history: json['history'] as String?,
  howToApply: json['howToApply'] as String?,
  importance: json['importance'] as String,
  origin: $enumDecode(_$CulturalOriginEnumMap, json['origin']),
  category: $enumDecode(_$TraditionCategoryEnumMap, json['category']),
  ageRange: $enumDecode(_$AgeRangeEnumMap, json['ageRange']),
  imageUrl: json['imageUrl'] as String?,
  source: json['source'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CulturalTraditionModelToJson(
  CulturalTraditionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'history': instance.history,
  'howToApply': instance.howToApply,
  'importance': instance.importance,
  'origin': _$CulturalOriginEnumMap[instance.origin]!,
  'category': _$TraditionCategoryEnumMap[instance.category]!,
  'ageRange': _$AgeRangeEnumMap[instance.ageRange]!,
  'imageUrl': instance.imageUrl,
  'source': instance.source,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$CulturalOriginEnumMap = {
  CulturalOrigin.turkish: 'turkish',
  CulturalOrigin.world: 'world',
};

const _$TraditionCategoryEnumMap = {
  TraditionCategory.birthTraditions: 'birth_traditions',
  TraditionCategory.namingCeremonies: 'naming_ceremonies',
  TraditionCategory.nutritionTraditions: 'nutrition_traditions',
  TraditionCategory.educationTeaching: 'education_teaching',
  TraditionCategory.gamesEntertainment: 'games_entertainment',
  TraditionCategory.religiousSpiritual: 'religious_spiritual',
};

const _$AgeRangeEnumMap = {
  AgeRange.pregnancy: 'pregnancy',
  AgeRange.newborn: 'newborn',
  AgeRange.infant: 'infant',
  AgeRange.toddler: 'toddler',
  AgeRange.preschool: 'preschool',
  AgeRange.allAges: 'all_ages',
};
