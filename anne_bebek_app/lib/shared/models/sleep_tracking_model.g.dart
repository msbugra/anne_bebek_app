// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepTrackingModel _$SleepTrackingModelFromJson(Map<String, dynamic> json) =>
    SleepTrackingModel(
      id: (json['id'] as num?)?.toInt(),
      babyId: (json['babyId'] as num).toInt(),
      sleepDate: DateTime.parse(json['sleepDate'] as String),
      bedTime: json['bedTime'] as String?,
      wakeTime: json['wakeTime'] as String?,
      napCount: (json['napCount'] as num?)?.toInt(),
      napDurationMinutes: (json['napDurationMinutes'] as num?)?.toInt(),
      sleepQuality: $enumDecodeNullable(
        _$SleepQualityEnumMap,
        json['sleepQuality'],
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SleepTrackingModelToJson(SleepTrackingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'sleepDate': instance.sleepDate.toIso8601String(),
      'bedTime': instance.bedTime,
      'wakeTime': instance.wakeTime,
      'napCount': instance.napCount,
      'napDurationMinutes': instance.napDurationMinutes,
      'sleepQuality': _$SleepQualityEnumMap[instance.sleepQuality],
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$SleepQualityEnumMap = {
  SleepQuality.excellent: 'excellent',
  SleepQuality.good: 'good',
  SleepQuality.fair: 'fair',
  SleepQuality.poor: 'poor',
  SleepQuality.veryPoor: 'very_poor',
};
