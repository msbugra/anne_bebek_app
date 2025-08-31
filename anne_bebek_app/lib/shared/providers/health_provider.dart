import 'dart:collection';

import 'package:flutter/material.dart';
import '../../core/repositories/health_repository.dart';
import '../models/sleep_tracking_model.dart';
import '../models/growth_tracking_model.dart';
import '../models/feeding_tracking_model.dart';
import '../models/breastfeeding_tracking_model.dart';
import '../models/vaccination_model.dart';

class HealthProvider with ChangeNotifier {
  final HealthRepository _repository;

  HealthProvider({required HealthRepository repository})
    : _repository = repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _currentBabyId;

  List<SleepTrackingModel> _sleepRecords = [];
  List<GrowthTrackingModel> _growthMeasurements = [];
  List<FeedingTrackingModel> _feedingRecords = [];
  List<BreastfeedingTrackingModel> _breastfeedingRecords = [];
  List<VaccinationModel> _vaccinations = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UnmodifiableListView<SleepTrackingModel> get sleepRecords =>
      UnmodifiableListView(_sleepRecords);
  UnmodifiableListView<GrowthTrackingModel> get growthMeasurements =>
      UnmodifiableListView(_growthMeasurements);
  UnmodifiableListView<FeedingTrackingModel> get feedingRecords =>
      UnmodifiableListView(_feedingRecords);
  UnmodifiableListView<BreastfeedingTrackingModel> get breastfeedingRecords =>
      UnmodifiableListView(_breastfeedingRecords);
  UnmodifiableListView<VaccinationModel> get vaccinations =>
      UnmodifiableListView(_vaccinations);

  SleepTrackingModel? get latestSleepRecord =>
      _sleepRecords.isNotEmpty ? _sleepRecords.first : null;
  GrowthTrackingModel? get latestGrowthMeasurement =>
      _growthMeasurements.isNotEmpty ? _growthMeasurements.first : null;
  Map<String, dynamic>? get sleepStatistics =>
      _sleepRecords.isEmpty ? null : {};
  Map<String, dynamic>? get feedingStatistics =>
      _feedingRecords.isEmpty ? null : {};
  List<VaccinationModel> get upcomingVaccinations => [];
  List<VaccinationModel> get overdueVaccinations => [];
  int get completedVaccinationsCount => 0;
  int get pendingVaccinationsCount => 0;
  int get delayedVaccinationsCount => 0;

  Future<void> initializeHealthData(String babyId) async {
    if (_currentBabyId == babyId && _sleepRecords.isNotEmpty) return;
    _currentBabyId = babyId;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    if (_currentBabyId == null) return;
    _setLoading(true);
    try {
      _sleepRecords = await _repository.getSleepRecords(_currentBabyId!);
      _growthMeasurements = await _repository.getGrowthRecords(_currentBabyId!);
      _feedingRecords = await _repository.getFeedingRecords(_currentBabyId!);
      _breastfeedingRecords = await _repository.getBreastfeedingRecords(
        _currentBabyId!,
      );
      _vaccinations = await _repository.getVaccinations(_currentBabyId!);

      _sortAllData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Veriler yüklenirken hata: $e";
    } finally {
      _setLoading(false);
    }
  }

  void _sortAllData() {
    _sleepRecords.sort((a, b) => b.sleepDate.compareTo(a.sleepDate));
    _growthMeasurements.sort((a, b) => b.date.compareTo(a.date));
    _feedingRecords.sort((a, b) => b.time.compareTo(a.time));
    _breastfeedingRecords.sort((a, b) => b.startTime.compareTo(a.startTime));
    _vaccinations.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  // Generic CRUD Operation Helper
  Future<bool> _performCrudOperation(
    Future<bool> operation, {
    String? errorMessage,
  }) async {
    _setLoading(true);
    try {
      final success = await operation;
      if (success) {
        await _fetchData(); // Refresh data on success
      } else {
        _errorMessage = errorMessage ?? "İşlem başarısız oldu.";
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _errorMessage = "${errorMessage ?? "Bir hata oluştu"}: $e";
      _setLoading(false);
      return false;
    }
  }

  // --- Sleep Records ---
  Future<bool> addSleepRecord(SleepTrackingModel record) =>
      _performCrudOperation(
        _repository.addSleepRecord(_currentBabyId!, record).then((_) => true),
      );
  Future<bool> updateSleepRecord(SleepTrackingModel record) =>
      _performCrudOperation(
        _repository.updateSleepRecord(_currentBabyId!, record),
      );
  Future<bool> deleteSleepRecord(String recordId) => _performCrudOperation(
    _repository.deleteSleepRecord(recordId, _currentBabyId!),
  );

  // --- Growth Measurements ---
  Future<bool> addGrowthMeasurement(GrowthTrackingModel record) =>
      _performCrudOperation(
        _repository.addGrowthRecord(_currentBabyId!, record).then((_) => true),
      );
  Future<bool> updateGrowthMeasurement(GrowthTrackingModel record) =>
      _performCrudOperation(
        _repository.updateGrowthRecord(_currentBabyId!, record),
      );
  Future<bool> deleteGrowthMeasurement(String recordId) =>
      _performCrudOperation(
        _repository.deleteGrowthRecord(recordId, _currentBabyId!),
      );

  // --- Feeding Records ---
  Future<bool> addFeedingRecord(FeedingTrackingModel record) =>
      _performCrudOperation(
        _repository.addFeedingRecord(_currentBabyId!, record).then((_) => true),
      );
  Future<bool> updateFeedingRecord(FeedingTrackingModel record) =>
      _performCrudOperation(
        _repository.updateFeedingRecord(_currentBabyId!, record),
      );
  Future<bool> deleteFeedingRecord(String recordId) => _performCrudOperation(
    _repository.deleteFeedingRecord(recordId, _currentBabyId!),
  );

  // --- Breastfeeding Records ---
  Future<bool> addBreastfeedingRecord(BreastfeedingTrackingModel record) =>
      _performCrudOperation(
        _repository
            .addBreastfeedingRecord(_currentBabyId!, record)
            .then((_) => true),
      );
  Future<bool> updateBreastfeedingRecord(BreastfeedingTrackingModel record) =>
      _performCrudOperation(
        _repository.updateBreastfeedingRecord(_currentBabyId!, record),
      );
  Future<bool> deleteBreastfeedingRecord(String recordId) =>
      _performCrudOperation(
        _repository.deleteBreastfeedingRecord(recordId, _currentBabyId!),
      );

  // --- Vaccinations ---
  Future<bool> generateVaccinationSchedule(DateTime birthDate) =>
      _performCrudOperation(
        _repository
            .generateVaccinationSchedule(_currentBabyId!, birthDate)
            .then((_) => true),
      );
  Future<bool> addVaccination(VaccinationModel vaccination) =>
      _performCrudOperation(
        _repository
            .addVaccination(_currentBabyId!, vaccination)
            .then((_) => true),
      );
  Future<bool> updateVaccination(VaccinationModel vaccination) =>
      _performCrudOperation(
        _repository.updateVaccination(_currentBabyId!, vaccination),
      );
  Future<bool> deleteVaccination(String recordId) => _performCrudOperation(
    _repository.deleteVaccination(recordId, _currentBabyId!),
  );

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
