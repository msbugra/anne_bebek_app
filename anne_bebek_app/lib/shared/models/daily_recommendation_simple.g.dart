// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recommendation_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecommendationSimple _$DailyRecommendationSimpleFromJson(
  Map<String, dynamic> json,
) => DailyRecommendationSimple(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  dayNumber: (json['dayNumber'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DailyRecommendationSimpleToJson(
  DailyRecommendationSimple instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'dayNumber': instance.dayNumber,
  'createdAt': instance.createdAt.toIso8601String(),
};
