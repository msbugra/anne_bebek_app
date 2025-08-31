import '../../shared/models/sleep_tracking_model.dart';
import '../../shared/models/growth_tracking_model.dart';
import '../../shared/models/feeding_tracking_model.dart';
import '../../shared/models/breastfeeding_tracking_model.dart';
import '../../shared/models/vaccination_model.dart';

abstract class HealthRepository {
  Future<List<SleepTrackingModel>> getSleepRecords(String babyId);
  Future<String> addSleepRecord(String babyId, SleepTrackingModel record);
  Future<bool> updateSleepRecord(String babyId, SleepTrackingModel record);
  Future<bool> deleteSleepRecord(String recordId, String babyId);

  Future<List<GrowthTrackingModel>> getGrowthRecords(String babyId);
  Future<String> addGrowthRecord(String babyId, GrowthTrackingModel record);
  Future<bool> updateGrowthRecord(String babyId, GrowthTrackingModel record);
  Future<bool> deleteGrowthRecord(String recordId, String babyId);

  Future<List<FeedingTrackingModel>> getFeedingRecords(String babyId);
  Future<String> addFeedingRecord(String babyId, FeedingTrackingModel record);
  Future<bool> updateFeedingRecord(String babyId, FeedingTrackingModel record);
  Future<bool> deleteFeedingRecord(String recordId, String babyId);

  Future<List<BreastfeedingTrackingModel>> getBreastfeedingRecords(
    String babyId,
  );
  Future<String> addBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  );
  Future<bool> updateBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  );
  Future<bool> deleteBreastfeedingRecord(String recordId, String babyId);

  Future<List<VaccinationModel>> getVaccinations(String babyId);
  Future<List<VaccinationModel>> generateVaccinationSchedule(
    String babyId,
    DateTime birthDate,
  );
  Future<String> addVaccination(String babyId, VaccinationModel vaccination);
  Future<bool> updateVaccination(String babyId, VaccinationModel vaccination);
  Future<bool> deleteVaccination(String recordId, String babyId);
}
