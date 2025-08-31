// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecommendationModel _$RecommendationModelFromJson(Map<String, dynamic> json) =>
    RecommendationModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      dayNumber: (json['dayNumber'] as num).toInt(),
      details: json['details'] as String?,
      scientificSource: json['scientificSource'] as String?,
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecommendationModelToJson(
  RecommendationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'dayNumber': instance.dayNumber,
  'details': instance.details,
  'scientificSource': instance.scientificSource,
  'benefits': instance.benefits,
  'source': instance.source,
  'createdAt': instance.createdAt.toIso8601String(),
};
