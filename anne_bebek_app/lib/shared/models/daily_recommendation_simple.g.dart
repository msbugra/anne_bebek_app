// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_recommendation_simple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecommendationSimple _$DailyRecommendationSimpleFromJson(
  Map<String, dynamic> json,
) => DailyRecommendationSimple(
  id: (json['id'] as num?)?.toInt(),
  babyId: (json['babyId'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  category: json['category'] as String?,
  isFavorite: json['isFavorite'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DailyRecommendationSimpleToJson(
  DailyRecommendationSimple instance,
) => <String, dynamic>{
  'id': instance.id,
  'babyId': instance.babyId,
  'title': instance.title,
  'content': instance.content,
  'category': instance.category,
  'isFavorite': instance.isFavorite,
  'createdAt': instance.createdAt.toIso8601String(),
};
