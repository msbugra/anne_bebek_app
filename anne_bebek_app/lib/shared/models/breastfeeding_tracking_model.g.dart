// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breastfeeding_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreastfeedingTrackingModel _$BreastfeedingTrackingModelFromJson(
  Map<String, dynamic> json,
) => BreastfeedingTrackingModel(
  id: (json['id'] as num?)?.toInt(),
  babyId: (json['babyId'] as num).toInt(),
  feedingDateTime: DateTime.parse(json['feedingDateTime'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  breastSide: $enumDecode(_$BreastSideEnumMap, json['breastSide']),
  feedingQuality: $enumDecodeNullable(
    _$BreastfeedingQualityEnumMap,
    json['feedingQuality'],
  ),
  babyWasSatisfied: json['babyWasSatisfied'] as bool?,
  hadDifficulty: json['hadDifficulty'] as bool?,
  difficultyNote: json['difficultyNote'] as String?,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BreastfeedingTrackingModelToJson(
  BreastfeedingTrackingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'babyId': instance.babyId,
  'feedingDateTime': instance.feedingDateTime.toIso8601String(),
  'durationMinutes': instance.durationMinutes,
  'breastSide': _$BreastSideEnumMap[instance.breastSide]!,
  'feedingQuality': _$BreastfeedingQualityEnumMap[instance.feedingQuality],
  'babyWasSatisfied': instance.babyWasSatisfied,
  'hadDifficulty': instance.hadDifficulty,
  'difficultyNote': instance.difficultyNote,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$BreastSideEnumMap = {
  BreastSide.left: 'left',
  BreastSide.right: 'right',
  BreastSide.both: 'both',
};

const _$BreastfeedingQualityEnumMap = {
  BreastfeedingQuality.excellent: 'excellent',
  BreastfeedingQuality.good: 'good',
  BreastfeedingQuality.fair: 'fair',
  BreastfeedingQuality.poor: 'poor',
  BreastfeedingQuality.difficult: 'difficult',
};
