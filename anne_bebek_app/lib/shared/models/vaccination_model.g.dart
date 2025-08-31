// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VaccinationModel _$VaccinationModelFromJson(Map<String, dynamic> json) =>
    VaccinationModel(
      id: (json['id'] as num?)?.toInt(),
      babyId: (json['babyId'] as num).toInt(),
      vaccineName: json['vaccineName'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      administeredDate: json['administeredDate'] == null
          ? null
          : DateTime.parse(json['administeredDate'] as String),
      doseNumber: (json['doseNumber'] as num?)?.toInt() ?? 1,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      status:
          $enumDecodeNullable(_$VaccineStatusEnumMap, json['status']) ??
          VaccineStatus.scheduled,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VaccinationModelToJson(VaccinationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'babyId': instance.babyId,
      'vaccineName': instance.vaccineName,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'administeredDate': instance.administeredDate?.toIso8601String(),
      'doseNumber': instance.doseNumber,
      'location': instance.location,
      'notes': instance.notes,
      'status': _$VaccineStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$VaccineStatusEnumMap = {
  VaccineStatus.scheduled: 'scheduled',
  VaccineStatus.completed: 'completed',
  VaccineStatus.delayed: 'delayed',
  VaccineStatus.skipped: 'skipped',
};
