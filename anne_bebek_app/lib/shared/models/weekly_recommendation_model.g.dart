// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyRecommendationModel _$WeeklyRecommendationModelFromJson(
  Map<String, dynamic> json,
) => WeeklyRecommendationModel(
  id: (json['id'] as num?)?.toInt(),
  weekNumber: (json['weekNumber'] as num).toInt(),
  ageYears: (json['ageYears'] as num).toInt(),
  category: $enumDecode(_$RecommendationCategoryEnumMap, json['category']),
  title: json['title'] as String,
  description: json['description'] as String,
  details: json['details'] as String?,
  scientificSource: json['scientificSource'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WeeklyRecommendationModelToJson(
  WeeklyRecommendationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'weekNumber': instance.weekNumber,
  'ageYears': instance.ageYears,
  'category': _$RecommendationCategoryEnumMap[instance.category]!,
  'title': instance.title,
  'description': instance.description,
  'details': instance.details,
  'scientificSource': instance.scientificSource,
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
