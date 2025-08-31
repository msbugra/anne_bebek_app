// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolidFood _$SolidFoodFromJson(Map<String, dynamic> json) => SolidFood(
  name: json['name'] as String,
  amount: (json['amount'] as num?)?.toDouble(),
  unit: json['unit'] as String?,
);

Map<String, dynamic> _$SolidFoodToJson(SolidFood instance) => <String, dynamic>{
  'name': instance.name,
  'amount': instance.amount,
  'unit': instance.unit,
};

FeedingTrackingModel _$FeedingTrackingModelFromJson(
  Map<String, dynamic> json,
) => FeedingTrackingModel(
  id: (json['id'] as num?)?.toInt(),
  babyId: (json['babyId'] as num).toInt(),
  feedingDateTime: DateTime.parse(json['feedingDateTime'] as String),
  feedingType: $enumDecode(_$FeedingTypeEnumMap, json['feedingType']),
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  amountMl: (json['amountMl'] as num?)?.toDouble(),
  formulaType: $enumDecodeNullable(_$FormulaTypeEnumMap, json['formulaType']),
  breastSide: $enumDecodeNullable(_$BreastSideEnumMap, json['breastSide']),
  solidFoods: (json['solidFoods'] as List<dynamic>?)
      ?.map((e) => SolidFood.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FeedingTrackingModelToJson(
  FeedingTrackingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'babyId': instance.babyId,
  'feedingDateTime': instance.feedingDateTime.toIso8601String(),
  'feedingType': _$FeedingTypeEnumMap[instance.feedingType]!,
  'durationMinutes': instance.durationMinutes,
  'amountMl': instance.amountMl,
  'formulaType': _$FormulaTypeEnumMap[instance.formulaType],
  'breastSide': _$BreastSideEnumMap[instance.breastSide],
  'solidFoods': instance.solidFoods,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$FeedingTypeEnumMap = {
  FeedingType.breastMilk: 'breast_milk',
  FeedingType.formula: 'formula',
  FeedingType.solidFood: 'solid_food',
  FeedingType.mixed: 'mixed',
};

const _$FormulaTypeEnumMap = {
  FormulaType.cowBased: 'cow_based',
  FormulaType.goatBased: 'goat_based',
  FormulaType.soyBased: 'soy_based',
  FormulaType.hydrolyzed: 'hydrolyzed',
  FormulaType.lactoseFree: 'lactose_free',
  FormulaType.hypoallergenic: 'hypoallergenic',
};

const _$BreastSideEnumMap = {
  BreastSide.left: 'left',
  BreastSide.right: 'right',
  BreastSide.both: 'both',
};
