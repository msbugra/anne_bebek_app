import 'package:anne_bebek_app/core/repositories/health_repository.dart';
import 'package:anne_bebek_app/shared/models/breastfeeding_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/feeding_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/growth_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/sleep_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/vaccination_model.dart';

class FakeHealthRepository implements HealthRepository {
  @override
  Future<String> addBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  ) async => 'fake_id';
  @override
  Future<String> addFeedingRecord(
    String babyId,
    FeedingTrackingModel record,
  ) async => 'fake_id';
  @override
  Future<String> addGrowthRecord(
    String babyId,
    GrowthTrackingModel record,
  ) async => 'fake_id';
  @override
  Future<String> addSleepRecord(
    String babyId,
    SleepTrackingModel record,
  ) async => 'fake_id';
  @override
  Future<String> addVaccination(
    String babyId,
    VaccinationModel vaccination,
  ) async => 'fake_id';
  @override
  Future<bool> deleteBreastfeedingRecord(
    String recordId,
    String babyId,
  ) async => true;
  @override
  Future<bool> deleteFeedingRecord(String recordId, String babyId) async =>
      true;
  @override
  Future<bool> deleteGrowthRecord(String recordId, String babyId) async => true;
  @override
  Future<bool> deleteSleepRecord(String recordId, String babyId) async => true;
  @override
  Future<bool> deleteVaccination(String recordId, String babyId) async => true;
  @override
  Future<List<VaccinationModel>> generateVaccinationSchedule(
    String babyId,
    DateTime birthDate,
  ) async => [];
  @override
  Future<List<BreastfeedingTrackingModel>> getBreastfeedingRecords(
    String babyId,
  ) async => [];
  @override
  Future<List<FeedingTrackingModel>> getFeedingRecords(String babyId) async =>
      [];
  @override
  Future<List<GrowthTrackingModel>> getGrowthRecords(String babyId) async => [];
  @override
  Future<List<SleepTrackingModel>> getSleepRecords(String babyId) async => [];
  @override
  Future<List<VaccinationModel>> getVaccinations(String babyId) async => [];
  @override
  Future<bool> updateBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  ) async => true;
  @override
  Future<bool> updateFeedingRecord(
    String babyId,
    FeedingTrackingModel record,
  ) async => true;
  @override
  Future<bool> updateGrowthRecord(
    String babyId,
    GrowthTrackingModel record,
  ) async => true;
  @override
  Future<bool> updateSleepRecord(
    String babyId,
    SleepTrackingModel record,
  ) async => true;
  @override
  Future<bool> updateVaccination(
    String babyId,
    VaccinationModel vaccination,
  ) async => true;
}
