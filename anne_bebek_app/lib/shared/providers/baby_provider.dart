import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/baby_model.dart';
import '../models/mother_model.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/age_calculator.dart';
import '../../core/constants/app_constants.dart';

class BabyProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  BabyProvider({required DatabaseService databaseService})
    : _databaseService = databaseService;

  // Current state
  BabyModel? _currentBaby;
  MotherModel? _currentMother;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  BabyModel? get currentBaby => _currentBaby;
  MotherModel? get currentMother => _currentMother;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasBabyProfile => _currentBaby != null && _currentMother != null;

  // Yaş bilgileri (computed properties)
  int? get babyAgeInDays => _currentBaby?.ageInDays;
  int? get babyAgeInWeeks => _currentBaby?.ageInWeeks;
  int? get babyAgeInMonths => _currentBaby?.ageInMonths;
  int? get babyAgeInYears => _currentBaby?.ageInYears;
  String? get babyAgeGroup => _currentBaby?.ageGroup;
  String? get formattedAge => _currentBaby != null
      ? AgeCalculator.getFormattedAge(_currentBaby!.birthDate)
      : null;

  // Başlatma
  Future<void> initialize() async {
    await _loadSavedProfile();
  }

  // Kayıtlı profili yükle
  Future<void> _loadSavedProfile() async {
    try {
      setLoading(true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFirstLaunch = prefs.getBool(AppConstants.keyIsFirstLaunch) ?? true;

      if (!isFirstLaunch) {
        // Database'den anne ve bebek bilgilerini yükle
        await _loadMotherFromDatabase();
        await _loadBabyFromDatabase();
      }
    } catch (e) {
      _setError('Profil yüklenirken hata oluştu: $e');
    } finally {
      setLoading(false);
    }
  }

  // Database'den anne bilgilerini yükle
  Future<void> _loadMotherFromDatabase() async {
    try {
      List<Map<String, dynamic>> mothers = await _databaseService.query(
        'mothers',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (mothers.isNotEmpty) {
        _currentMother = MotherModel.fromMap(mothers.first);
      }
    } catch (e) {
      debugPrint('Anne bilgileri yüklenirken hata: $e');
    }
  }

  // Database'den bebek bilgilerini yükle
  Future<void> _loadBabyFromDatabase() async {
    try {
      if (_currentMother?.id == null) return;

      List<Map<String, dynamic>> babies = await _databaseService.query(
        'babies',
        where: 'mother_id = ?',
        whereArgs: [_currentMother!.id!],
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (babies.isNotEmpty) {
        _currentBaby = BabyModel.fromMap(babies.first);
      }
    } catch (e) {
      debugPrint('Bebek bilgileri yüklenirken hata: $e');
    }
  }

  // Anne profili oluştur/güncelle
  Future<bool> saveMotherProfile({
    required String name,
    DateTime? birthDate,
    String? birthCity,
    bool astrologyEnabled = false,
    String? zodiacSign,
  }) async {
    try {
      setLoading(true);
      DateTime now = DateTime.now();

      // print('🔍 [DEBUG] Saving mother profile with name: $name');
      // print('🔍 [DEBUG] Birth date: $birthDate');
      // print('🔍 [DEBUG] Birth city: $birthCity');
      // print('🔍 [DEBUG] Astrology enabled: $astrologyEnabled');
      // print('🔍 [DEBUG] Zodiac sign: $zodiacSign');

      MotherModel mother = MotherModel(
        id: _currentMother?.id,
        name: name,
        birthDate: birthDate,
        birthCity: birthCity,
        astrologyEnabled: astrologyEnabled,
        zodiacSign: zodiacSign,
        createdAt: _currentMother?.createdAt ?? now,
        updatedAt: now,
      );

      // print('🔍 [DEBUG] Mother model created: ${mother.toMap()}');

      int motherId;
      if (_currentMother?.id == null) {
        // Yeni anne kaydı
        // print('🔍 [DEBUG] Inserting new mother record');
        motherId = await _databaseService.insert('mothers', mother.toMap());
        // print('🔍 [DEBUG] Inserted mother with ID: $motherId');
        mother = mother.copyWith(id: motherId);
      } else {
        // Anne bilgisi güncelleme
        // print(
        //   '🔍 [DEBUG] Updating existing mother record with ID: ${_currentMother!.id}',
        // );
        await _databaseService.update(
          'mothers',
          mother.toMap(),
          where: 'id = ?',
          whereArgs: [_currentMother!.id!],
        );
        motherId = _currentMother!.id!;
      }

      _currentMother = mother;

      // SharedPreferences'a kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyMotherName, name);
      await prefs.setBool(AppConstants.keyAstrologyEnabled, astrologyEnabled);

      // print('🔍 [DEBUG] Mother profile saved successfully');
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      // print('❌ [ERROR] Failed to save mother profile: $e');
      // print('❌ [ERROR] Stack trace: ${StackTrace.current}');
      _setError('Anne profili kaydedilirken hata oluştu: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Bebek profili oluştur/güncelle
  Future<bool> saveBabyProfile({
    required String name,
    required DateTime birthDate,
    String? birthTime,
    double? birthWeight,
    double? birthHeight,
    double? birthHeadCircumference,
    String? birthCity,
    BabyGender? gender,
    String? zodiacSign,
  }) async {
    try {
      setLoading(true);

      if (_currentMother?.id == null) {
        _setError('Önce anne profili oluşturulmalıdır');
        return false;
      }

      DateTime now = DateTime.now();

      BabyModel baby = BabyModel(
        id: _currentBaby?.id,
        motherId: _currentMother!.id!,
        name: name,
        birthDate: birthDate,
        birthTime: birthTime,
        birthWeight: birthWeight,
        birthHeight: birthHeight,
        birthHeadCircumference: birthHeadCircumference,
        birthCity: birthCity,
        gender: gender,
        zodiacSign: zodiacSign,
        createdAt: _currentBaby?.createdAt ?? now,
        updatedAt: now,
      );

      if (_currentBaby?.id == null) {
        // Yeni bebek kaydı
        int babyId = await _databaseService.insert('babies', baby.toMap());
        baby = baby.copyWith(id: babyId);
      } else {
        // Bebek bilgisi güncelleme
        await _databaseService.update(
          'babies',
          baby.toMap(),
          where: 'id = ?',
          whereArgs: [_currentBaby!.id!],
        );
      }

      _currentBaby = baby;

      // SharedPreferences'a kaydet
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyBabyName, name);
      await prefs.setString(
        AppConstants.keyBabyBirthDate,
        birthDate.toIso8601String(),
      );
      await prefs.setBool(AppConstants.keyIsFirstLaunch, false);

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Bebek profili kaydedilirken hata oluştu: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Profili sıfırla (çıkış yap)
  Future<void> resetProfile() async {
    try {
      setLoading(true);

      // Database'i temizle (isteğe bağlı)
      // await _databaseService.deleteDatabase();

      // SharedPreferences'ı temizle
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _currentBaby = null;
      _currentMother = null;
      _clearError();

      notifyListeners();
    } catch (e) {
      _setError('Profil sıfırlanırken hata oluştu: $e');
    } finally {
      setLoading(false);
    }
  }

  /// Hesabı ve tüm verileri kalıcı olarak sil.
  ///
  /// - Veritabanındaki tüm tabloları düşürür ve yeniden oluşturur
  /// - SharedPreferences temizlenir
  /// - Bellekteki anne/bebek durumu sıfırlanır
  Future<void> deleteAccount() async {
    try {
      setLoading(true);

      // Veritabanındaki tüm verileri sil
      await _databaseService.deleteAllData();

      // SharedPreferences'ı temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Bellek durumunu temizle
      _currentBaby = null;
      _currentMother = null;
      _clearError();

      notifyListeners();
    } catch (e) {
      _setError('Hesap silinirken hata oluştu: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Bebek yaş grubuna göre öneri gün numarasını al
  int? getDayNumberForRecommendations() {
    if (_currentBaby == null) return null;
    return AgeCalculator.getDayGroupForRecommendations(_currentBaby!.birthDate);
  }

  // Haftalık öneriler için hafta numarasını al
  int? getWeekNumberForRecommendations() {
    if (_currentBaby == null) return null;
    return AgeCalculator.getWeekNumberForRecommendations(
      _currentBaby!.birthDate,
    );
  }

  // Sonraki doğum gününe kalan süre
  Duration? getTimeUntilNextBirthday() {
    if (_currentBaby == null) return null;
    return AgeCalculator.timeUntilNextBirthday(_currentBaby!.birthDate);
  }

  // Gelişimsel dönem
  String? getDevelopmentalStage() {
    if (_currentBaby == null) return null;
    return AgeCalculator.getDevelopmentalStage(_currentBaby!.birthDate);
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
