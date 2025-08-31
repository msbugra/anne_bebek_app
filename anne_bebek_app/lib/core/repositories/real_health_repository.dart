import 'package:anne_bebek_app/core/constants/vaccination_schedule.dart';
import 'package:anne_bebek_app/core/repositories/health_repository.dart';
import 'package:anne_bebek_app/core/services/database_service.dart';
import 'package:anne_bebek_app/core/utils/error_handler.dart';
import 'package:anne_bebek_app/shared/models/breastfeeding_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/feeding_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/growth_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/sleep_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/vaccination_model.dart';

class RealHealthRepository implements HealthRepository {
  final DatabaseService _databaseService;

  RealHealthRepository({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  @override
  Future<List<SleepTrackingModel>> getSleepRecords(String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final records = await _databaseService.query(
          'sleep_tracking',
          where: 'baby_id = ?',
          whereArgs: [babyId],
          orderBy: 'sleep_start DESC',
        );

        return records
            .map((json) => SleepTrackingModel.fromJson(json))
            .toList();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Uyku kayıtları alınırken hata oluştu: $e');
      }
    }, context: 'getSleepRecords');
  }

  @override
  Future<String> addSleepRecord(
    String babyId,
    SleepTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        json['baby_id'] = babyId;
        final id = await _databaseService.insert('sleep_tracking', json);
        return id.toString();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Uyku kaydı eklenirken hata oluştu: $e');
      }
    }, context: 'addSleepRecord');
  }

  @override
  Future<bool> updateSleepRecord(
    String babyId,
    SleepTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        final count = await _databaseService.update(
          'sleep_tracking',
          json,
          where: 'id = ? AND baby_id = ?',
          whereArgs: [record.id, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Uyku kaydı güncellenirken hata oluştu: $e');
      }
    }, context: 'updateSleepRecord');
  }

  @override
  Future<bool> deleteSleepRecord(String recordId, String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final count = await _databaseService.delete(
          'sleep_tracking',
          where: 'id = ? AND baby_id = ?',
          whereArgs: [recordId, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Uyku kaydı silinirken hata oluştu: $e');
      }
    }, context: 'deleteSleepRecord');
  }

  @override
  Future<List<GrowthTrackingModel>> getGrowthRecords(String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final records = await _databaseService.query(
          'growth_tracking',
          where: 'baby_id = ?',
          whereArgs: [babyId],
          orderBy: 'measurement_date DESC',
        );

        return records
            .map((json) => GrowthTrackingModel.fromJson(json))
            .toList();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Büyüme kayıtları alınırken hata oluştu: $e');
      }
    }, context: 'getGrowthRecords');
  }

  @override
  Future<String> addGrowthRecord(
    String babyId,
    GrowthTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        json['baby_id'] = babyId;
        final id = await _databaseService.insert('growth_tracking', json);
        return id.toString();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Büyüme kaydı eklenirken hata oluştu: $e');
      }
    }, context: 'addGrowthRecord');
  }

  @override
  Future<bool> updateGrowthRecord(
    String babyId,
    GrowthTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        final count = await _databaseService.update(
          'growth_tracking',
          json,
          where: 'id = ? AND baby_id = ?',
          whereArgs: [record.id, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Büyüme kaydı güncellenirken hata oluştu: $e');
      }
    }, context: 'updateGrowthRecord');
  }

  @override
  Future<bool> deleteGrowthRecord(String recordId, String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final count = await _databaseService.delete(
          'growth_tracking',
          where: 'id = ? AND baby_id = ?',
          whereArgs: [recordId, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Büyüme kaydı silinirken hata oluştu: $e');
      }
    }, context: 'deleteGrowthRecord');
  }

  @override
  Future<List<FeedingTrackingModel>> getFeedingRecords(String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final records = await _databaseService.query(
          'feeding_tracking',
          where: 'baby_id = ?',
          whereArgs: [babyId],
          orderBy: 'feeding_time DESC',
        );

        return records
            .map((json) => FeedingTrackingModel.fromJson(json))
            .toList();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Beslenme kayıtları alınırken hata oluştu: $e');
      }
    }, context: 'getFeedingRecords');
  }

  @override
  Future<String> addFeedingRecord(
    String babyId,
    FeedingTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        json['baby_id'] = babyId;
        final id = await _databaseService.insert('feeding_tracking', json);
        return id.toString();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Beslenme kaydı eklenirken hata oluştu: $e');
      }
    }, context: 'addFeedingRecord');
  }

  @override
  Future<bool> updateFeedingRecord(
    String babyId,
    FeedingTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        final count = await _databaseService.update(
          'feeding_tracking',
          json,
          where: 'id = ? AND baby_id = ?',
          whereArgs: [record.id, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException(
          'Beslenme kaydı güncellenirken hata oluştu: $e',
        );
      }
    }, context: 'updateFeedingRecord');
  }

  @override
  Future<bool> deleteFeedingRecord(String recordId, String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final count = await _databaseService.delete(
          'feeding_tracking',
          where: 'id = ? AND baby_id = ?',
          whereArgs: [recordId, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Beslenme kaydı silinirken hata oluştu: $e');
      }
    }, context: 'deleteFeedingRecord');
  }

  @override
  Future<List<BreastfeedingTrackingModel>> getBreastfeedingRecords(
    String babyId,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final records = await _databaseService.query(
          'breastfeeding_tracking',
          where: 'baby_id = ?',
          whereArgs: [babyId],
          orderBy: 'start_time DESC',
        );

        return records
            .map((json) => BreastfeedingTrackingModel.fromJson(json))
            .toList();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Emzirme kayıtları alınırken hata oluştu: $e');
      }
    }, context: 'getBreastfeedingRecords');
  }

  @override
  Future<String> addBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        json['baby_id'] = babyId;
        final id = await _databaseService.insert(
          'breastfeeding_tracking',
          json,
        );
        return id.toString();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Emzirme kaydı eklenirken hata oluştu: $e');
      }
    }, context: 'addBreastfeedingRecord');
  }

  @override
  Future<bool> updateBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = record.toJson();
        final count = await _databaseService.update(
          'breastfeeding_tracking',
          json,
          where: 'id = ? AND baby_id = ?',
          whereArgs: [record.id, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Emzirme kaydı güncellenirken hata oluştu: $e');
      }
    }, context: 'updateBreastfeedingRecord');
  }

  @override
  Future<bool> deleteBreastfeedingRecord(String recordId, String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final count = await _databaseService.delete(
          'breastfeeding_tracking',
          where: 'id = ? AND baby_id = ?',
          whereArgs: [recordId, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Emzirme kaydı silinirken hata oluştu: $e');
      }
    }, context: 'deleteBreastfeedingRecord');
  }

  @override
  Future<List<VaccinationModel>> getVaccinations(String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final records = await _databaseService.query(
          'vaccination_tracking',
          where: 'baby_id = ?',
          whereArgs: [babyId],
          orderBy: 'vaccine_date ASC',
        );

        return records.map((json) => VaccinationModel.fromJson(json)).toList();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Aşı kayıtları alınırken hata oluştu: $e');
      }
    }, context: 'getVaccinations');
  }

  @override
  Future<List<VaccinationModel>> generateVaccinationSchedule(
    String babyId,
    DateTime birthDate,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        // Mevcut aşı takvimini temizle
        await _databaseService.delete(
          'vaccination_tracking',
          where: 'baby_id = ?',
          whereArgs: [babyId],
        );

        final List<VaccinationModel> schedule = [];
        for (var vaccineInfo in standardVaccinationSchedule) {
          final scheduledDate = DateTime(
            birthDate.year,
            birthDate.month + vaccineInfo.dueMonth,
            birthDate.day,
          );

          final intBabyId = int.tryParse(babyId);
          if (intBabyId == null) {
            throw DatabaseException('Geçersiz bebek ID formatı: $babyId');
          }

          final newVaccine = VaccinationModel(
            babyId: intBabyId,
            vaccineName: vaccineInfo.name,
            scheduledDate: scheduledDate,
            notes: '${vaccineInfo.description} - ${vaccineInfo.details}',
            status: VaccineStatus.scheduled,
            createdAt: DateTime.now(),
          );

          final idString = await addVaccination(babyId, newVaccine);
          final newId = int.tryParse(idString);
          schedule.add(newVaccine.copyWith(id: newId));
        }

        return schedule;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Aşı takvimi oluşturulurken hata oluştu: $e');
      }
    }, context: 'generateVaccinationSchedule');
  }

  @override
  Future<String> addVaccination(
    String babyId,
    VaccinationModel vaccination,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = vaccination.toJson();
        json['baby_id'] = babyId;
        final id = await _databaseService.insert('vaccination_tracking', json);
        return id.toString();
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Aşı kaydı eklenirken hata oluştu: $e');
      }
    }, context: 'addVaccination');
  }

  @override
  Future<bool> updateVaccination(
    String babyId,
    VaccinationModel vaccination,
  ) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final json = vaccination.toJson();
        final count = await _databaseService.update(
          'vaccination_tracking',
          json,
          where: 'id = ? AND baby_id = ?',
          whereArgs: [vaccination.id, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Aşı kaydı güncellenirken hata oluştu: $e');
      }
    }, context: 'updateVaccination');
  }

  @override
  Future<bool> deleteVaccination(String recordId, String babyId) async {
    return await ErrorHandler.handleAsyncOperation(() async {
      try {
        final count = await _databaseService.delete(
          'vaccination_tracking',
          where: 'id = ? AND baby_id = ?',
          whereArgs: [recordId, babyId],
        );
        return count > 0;
      } on DatabaseException {
        rethrow;
      } catch (e) {
        throw DatabaseException('Aşı kaydı silinirken hata oluştu: $e');
      }
    }, context: 'deleteVaccination');
  }
}
