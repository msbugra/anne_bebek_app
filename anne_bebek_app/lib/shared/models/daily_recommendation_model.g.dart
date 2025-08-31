// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecommendationModel _$DailyRecommendationModelFromJson(
  Map<String, dynamic> json,
) => DailyRecommendationModel(
  id: (json['id'] as num?)?.toInt(),
  dayNumber: (json['dayNumber'] as num).toInt(),
  category: $enumDecode(_$RecommendationCategoryEnumMap, json['category']),
  title: json['title'] as String,
  description: json['description'] as String,
  details: json['details'] as String?,
  scientificSource: json['scientificSource'] as String?,
  ageGroup: $enumDecode(_$AgeGroupEnumMap, json['ageGroup']),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DailyRecommendationModelToJson(
  DailyRecommendationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'dayNumber': instance.dayNumber,
  'category': _$RecommendationCategoryEnumMap[instance.category]!,
  'title': instance.title,
  'description': instance.description,
  'details': instance.details,
  'scientificSource': instance.scientificSource,
  'ageGroup': _$AgeGroupEnumMap[instance.ageGroup]!,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$RecommendationCategoryEnumMap = {
  RecommendationCategory.book: 'book',
  RecommendationCategory.music: 'music',
  RecommendationCategory.game: 'game',
  RecommendationCategory.toy: 'toy',
  RecommendationCategory.activity: 'activity',
  RecommendationCategory.development: 'development',
};

const _$AgeGroupEnumMap = {
  AgeGroup.newborn: 'newborn',
  AgeGroup.infant: 'infant',
  AgeGroup.toddler: 'toddler',
};
