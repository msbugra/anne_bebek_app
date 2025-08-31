// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthTrackingModel _$GrowthTrackingModelFromJson(Map<String, dynamic> json) =>
    GrowthTrackingModel(
      id: (json['id'] as num?)?.toInt(),
      babyId: (json['babyId'] as num).toInt(),
      measurementDate: DateTime.parse(json['measurementDate'] as String),
      ageInDays: (json['ageInDays'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      headCircumference: (json['headCircumference'] as num?)?.toDouble(),
      weightPercentile: (json['weightPercentile'] as num?)?.toDouble(),
      heightPercentile: (json['heightPercentile'] as num?)?.toDouble(),
      headPercentile: (json['headPercentile'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$GrowthTrackingModelToJson(
  GrowthTrackingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'babyId': instance.babyId,
  'measurementDate': instance.measurementDate.toIso8601String(),
  'ageInDays': instance.ageInDays,
  'weight': instance.weight,
  'height': instance.height,
  'headCircumference': instance.headCircumference,
  'weightPercentile': instance.weightPercentile,
  'heightPercentile': instance.heightPercentile,
  'headPercentile': instance.headPercentile,
  'createdAt': instance.createdAt.toIso8601String(),
};
