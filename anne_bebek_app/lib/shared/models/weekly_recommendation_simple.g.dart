// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_recommendation_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyRecommendationSimple _$WeeklyRecommendationSimpleFromJson(
  Map<String, dynamic> json,
) => WeeklyRecommendationSimple(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  weekNumber: (json['weekNumber'] as num).toInt(),
  ageYears: (json['ageYears'] as num).toInt(),
  activities: (json['activities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  estimatedDuration: (json['estimatedDuration'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$WeeklyRecommendationSimpleToJson(
  WeeklyRecommendationSimple instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'weekNumber': instance.weekNumber,
  'ageYears': instance.ageYears,
  'activities': instance.activities,
  'estimatedDuration': instance.estimatedDuration,
  'createdAt': instance.createdAt.toIso8601String(),
};
