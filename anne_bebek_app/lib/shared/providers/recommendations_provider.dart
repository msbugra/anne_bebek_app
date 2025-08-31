import 'package:flutter/foundation.dart';
import '../../core/repositories/recommendation_repository.dart';
import '../models/daily_recommendation_model.dart';
import '../models/weekly_recommendation_model.dart';
import 'baby_provider.dart';

class RecommendationsProvider with ChangeNotifier {
  final RecommendationRepository _repository;

  RecommendationsProvider({required RecommendationRepository repository})
    : _repository = repository;

  // Current state
  List<DailyRecommendationModel> _dailyRecommendations = [];
  List<WeeklyRecommendationModel> _weeklyRecommendations = [];
  List<DailyRecommendationModel> _todayRecommendations = [];
  List<WeeklyRecommendationModel> _thisWeekRecommendations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Cache için
  int? _lastDayNumber;
  int? _lastWeekNumber;
  int? _lastAgeYears;

  // Getters
  List<DailyRecommendationModel> get dailyRecommendations =>
      _dailyRecommendations;
  List<WeeklyRecommendationModel> get weeklyRecommendations =>
      _weeklyRecommendations;
  List<DailyRecommendationModel> get todayRecommendations =>
      _todayRecommendations;
  List<WeeklyRecommendationModel> get thisWeekRecommendations =>
      _thisWeekRecommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Başlatma ve örnek veriler yükleme
  Future<void> initialize(String babyId) async {
    try {
      setLoading(true);
      await _loadAllRecommendations(babyId);
    } catch (e) {
      _setError('Öneriler yüklenirken hata oluştu: $e');
    } finally {
      setLoading(false);
    }
  }

  // Tüm önerileri yükle
  Future<void> _loadAllRecommendations(String babyId) async {
    try {
      // Repository'den verileri çek
      _dailyRecommendations = await _repository.getDailyRecommendations(babyId);
      _weeklyRecommendations = await _repository.getWeeklyRecommendations(
        babyId,
      );
    } catch (e) {
      debugPrint('Öneriler yüklenirken hata: $e');
      _setError('Öneriler alınamadı.');
    }
  }

  // Bebeğin yaşına göre günün önerilerini getir
  Future<void> updateTodayRecommendations(BabyProvider babyProvider) async {
    try {
      if (babyProvider.currentBaby == null) {
        _todayRecommendations = [];
        notifyListeners();
        return;
      }

      int? dayNumber = babyProvider.getDayNumberForRecommendations();

      if (dayNumber == null || dayNumber < 0) {
        // 3 yaş üstü için haftalık öneriler kullan
        await updateThisWeekRecommendations(babyProvider);
        _todayRecommendations = [];
        notifyListeners();
        return;
      }

      // Cache kontrolü
      if (_lastDayNumber == dayNumber && _todayRecommendations.isNotEmpty) {
        return;
      }

      _todayRecommendations =
          DailyRecommendationService.getRecommendationsForDay(
            _dailyRecommendations,
            dayNumber,
          );

      _lastDayNumber = dayNumber;
      notifyListeners();
    } catch (e) {
      _setError('Günlük öneriler yüklenirken hata oluştu: $e');
    }
  }

  // Bebeğin yaşına göre bu haftanın önerilerini getir
  Future<void> updateThisWeekRecommendations(BabyProvider babyProvider) async {
    try {
      if (babyProvider.currentBaby == null) {
        _thisWeekRecommendations = [];
        notifyListeners();
        return;
      }

      int? weekNumber = babyProvider.getWeekNumberForRecommendations();
      int? ageYears = babyProvider.babyAgeInYears;

      if (weekNumber == null ||
          weekNumber < 0 ||
          ageYears == null ||
          ageYears < 3) {
        _thisWeekRecommendations = [];
        notifyListeners();
        return;
      }

      // Cache kontrolü
      if (_lastWeekNumber == weekNumber &&
          _lastAgeYears == ageYears &&
          _thisWeekRecommendations.isNotEmpty) {
        return;
      }

      _thisWeekRecommendations =
          WeeklyRecommendationService.getRecommendationsForWeek(
            _weeklyRecommendations,
            weekNumber,
            ageYears,
          );

      _lastWeekNumber = weekNumber;
      _lastAgeYears = ageYears;
      notifyListeners();
    } catch (e) {
      _setError('Haftalık öneriler yüklenirken hata oluştu: $e');
    }
  }

  // Kategoriye göre günlük önerileri getir
  List<DailyRecommendationModel> getDailyRecommendationsByCategory(
    RecommendationCategory category,
  ) {
    return DailyRecommendationService.getRecommendationsByCategory(
      _dailyRecommendations,
      category,
    );
  }

  // Yaş grubuna göre günlük önerileri getir
  List<DailyRecommendationModel> getDailyRecommendationsByAgeGroup(
    AgeGroup ageGroup,
  ) {
    return DailyRecommendationService.getRecommendationsByAgeGroup(
      _dailyRecommendations,
      ageGroup,
    );
  }

  // Kategoriye göre haftalık önerileri getir
  List<WeeklyRecommendationModel> getWeeklyRecommendationsByCategory(
    RecommendationCategory category,
  ) {
    return WeeklyRecommendationService.getRecommendationsByCategory(
      _weeklyRecommendations,
      category,
    );
  }

  // Yaşa göre haftalık önerileri getir
  List<WeeklyRecommendationModel> getWeeklyRecommendationsByAge(int ageYears) {
    return WeeklyRecommendationService.getRecommendationsByAge(
      _weeklyRecommendations,
      ageYears,
    );
  }

  // Belirli bir gün aralığındaki önerileri getir
  List<DailyRecommendationModel> getDailyRecommendationsForRange(
    int startDay,
    int endDay,
  ) {
    return _dailyRecommendations
        .where((rec) => rec.dayNumber >= startDay && rec.dayNumber <= endDay)
        .toList();
  }

  // Belirli bir hafta aralığındaki önerileri getir
  List<WeeklyRecommendationModel> getWeeklyRecommendationsForRange(
    int ageYears,
    int startWeek,
    int endWeek,
  ) {
    return _weeklyRecommendations
        .where(
          (rec) =>
              rec.ageYears == ageYears &&
              rec.weekNumber >= startWeek &&
              rec.weekNumber <= endWeek,
        )
        .toList();
  }

  // Yeni günlük öneri ekle
  // Future<bool> addDailyRecommendation(
  //   DailyRecommendationModel recommendation,
  // ) async {
  //   // Bu mantık repository'ye taşınacak
  // }

  // Yeni haftalık öneri ekle
  // Future<bool> addWeeklyRecommendation(
  //   WeeklyRecommendationModel recommendation,
  // ) async {
  //   // Bu mantık repository'ye taşınacak
  // }

  // Önerileri yeniden yükle
  Future<void> refreshRecommendations(String babyId) async {
    try {
      setLoading(true);
      await _loadAllRecommendations(babyId);
      _clearCache();
      _clearError();
    } catch (e) {
      _setError('Öneriler yenilenirken hata oluştu: $e');
    } finally {
      setLoading(false);
    }
  }

  // Cache'i temizle
  void _clearCache() {
    _lastDayNumber = null;
    _lastWeekNumber = null;
    _lastAgeYears = null;
    _todayRecommendations = [];
    _thisWeekRecommendations = [];
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
