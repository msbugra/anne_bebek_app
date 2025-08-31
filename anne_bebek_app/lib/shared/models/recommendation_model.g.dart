// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationModel _$RecommendationModelFromJson(Map<String, dynamic> json) =>
    RecommendationModel(
      id: (json['id'] as num?)?.toInt(),
      babyId: (json['babyId'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecommendationModelToJson(
  RecommendationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'babyId': instance.babyId,
  'title': instance.title,
  'content': instance.content,
  'category': instance.category,
  'isFavorite': instance.isFavorite,
  'createdAt': instance.createdAt.toIso8601String(),
};
