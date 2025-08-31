import 'package:flutter/material.dart';
import '../models/astrological_profile_model.dart';
import '../models/zodiac_compatibility_model.dart';
import '../models/zodiac_characteristics_model.dart';
import '../../core/utils/zodiac_calculator.dart';

/// Anne-bebek astrolojik profil ve uyumluluk yönetimi için Provider
class AstrologyProvider with ChangeNotifier {
  // State variables
  AstrologicalProfile? _motherProfile;
  AstrologicalProfile? _babyProfile;
  ZodiacCompatibility? _currentCompatibility;
  ZodiacCharacteristics? _motherCharacteristics;
  ZodiacCharacteristics? _babyCharacteristics;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AstrologicalProfile? get motherProfile => _motherProfile;
  AstrologicalProfile? get babyProfile => _babyProfile;
  ZodiacCompatibility? get currentCompatibility => _currentCompatibility;
  ZodiacCharacteristics? get motherCharacteristics => _motherCharacteristics;
  ZodiacCharacteristics? get babyCharacteristics => _babyCharacteristics;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMotherProfile => _motherProfile != null;
  bool get hasBabyProfile => _babyProfile != null;
  bool get hasCompatibilityData => _currentCompatibility != null;

  /// Anne astrolojik profilini oluştur
  Future<void> createMotherProfile({
    required int motherId,
    required DateTime birthDate,
    String? birthTime,
    String? birthCity,
    String? birthCountry,
  }) async {
    _setLoading(true);
    try {
      _motherProfile = ZodiacCalculator.createAstrologicalProfile(
        personId: motherId,
        personType: PersonType.mother,
        birthDate: birthDate,
        birthTime: birthTime,
        birthCity: birthCity,
        birthCountry: birthCountry,
      );

      // Anne burç özelliklerini yükle
      _motherCharacteristics = ZodiacCalculator.getZodiacCharacteristics(
        _motherProfile!.zodiacSign,
      );

      // Eğer bebek profili de varsa uyumluluğu hesapla
      if (_babyProfile != null) {
        await _calculateCompatibility();
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Anne profili oluşturulamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Bebek astrolojik profilini oluştur
  Future<void> createBabyProfile({
    required int babyId,
    required DateTime birthDate,
    String? birthTime,
    String? birthCity,
    String? birthCountry,
  }) async {
    _setLoading(true);
    try {
      _babyProfile = ZodiacCalculator.createAstrologicalProfile(
        personId: babyId,
        personType: PersonType.baby,
        birthDate: birthDate,
        birthTime: birthTime,
        birthCity: birthCity,
        birthCountry: birthCountry,
      );

      // Bebek burç özelliklerini yükle
      _babyCharacteristics = ZodiacCalculator.getZodiacCharacteristics(
        _babyProfile!.zodiacSign,
      );

      // Eğer anne profili de varsa uyumluluğu hesapla
      if (_motherProfile != null) {
        await _calculateCompatibility();
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Bebek profili oluşturulamadı: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Anne-bebek uyumluluğunu hesapla
  Future<void> _calculateCompatibility() async {
    if (_motherProfile == null || _babyProfile == null) return;

    try {
      _currentCompatibility = ZodiacCalculator.calculateCompatibility(
        _motherProfile!.zodiacSign,
        _babyProfile!.zodiacSign,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Uyumluluk hesaplama hatası: $e');
    }
  }

  /// Uyumluluğu yeniden hesapla
  Future<void> refreshCompatibility() async {
    if (_motherProfile == null || _babyProfile == null) return;

    _setLoading(true);
    await _calculateCompatibility();
    _setLoading(false);
  }

  /// Bebek yaşına göre astrolojik öneriler al
  List<String> getBabyAstrologyTips(int ageInMonths) {
    if (_babyProfile == null) return [];

    return ZodiacCalculator.getParentingTips(
      _babyProfile!.zodiacSign,
      ageInMonths,
    );
  }

  /// Burç için özel renk al
  static Color getZodiacColor(ZodiacSign zodiacSign) {
    switch (zodiacSign) {
      case ZodiacSign.aries:
        return const Color(0xFFE53E3E); // Kırmızı
      case ZodiacSign.taurus:
        return const Color(0xFF38A169); // Yeşil
      case ZodiacSign.gemini:
        return const Color(0xFFECC94B); // Sarı
      case ZodiacSign.cancer:
        return const Color(0xFF3182CE); // Mavi
      case ZodiacSign.leo:
        return const Color(0xFFED8936); // Turuncu
      case ZodiacSign.virgo:
        return const Color(0xFF8B4513); // Kahverengi
      case ZodiacSign.libra:
        return const Color(0xFFED64A6); // Pembe
      case ZodiacSign.scorpio:
        return const Color(0xFF805AD5); // Mor
      case ZodiacSign.sagittarius:
        return const Color(0xFF4C51BF); // İndigo
      case ZodiacSign.capricorn:
        return const Color(0xFF718096); // Gri
      case ZodiacSign.aquarius:
        return const Color(0xFF319795); // Teal
      case ZodiacSign.pisces:
        return const Color(0xFF00B5D8); // Cyan
    }
  }

  /// Burç için emoji al
  static String getZodiacEmoji(ZodiacSign zodiacSign) {
    switch (zodiacSign) {
      case ZodiacSign.aries:
        return '♈';
      case ZodiacSign.taurus:
        return '♉';
      case ZodiacSign.gemini:
        return '♊';
      case ZodiacSign.cancer:
        return '♋';
      case ZodiacSign.leo:
        return '♌';
      case ZodiacSign.virgo:
        return '♍';
      case ZodiacSign.libra:
        return '♎';
      case ZodiacSign.scorpio:
        return '♏';
      case ZodiacSign.sagittarius:
        return '♐';
      case ZodiacSign.capricorn:
        return '♑';
      case ZodiacSign.aquarius:
        return '♒';
      case ZodiacSign.pisces:
        return '♓';
    }
  }

  /// Element için ikon al
  static IconData getElementIcon(ZodiacElement element) {
    switch (element) {
      case ZodiacElement.fire:
        return Icons.local_fire_department_rounded;
      case ZodiacElement.earth:
        return Icons.terrain_rounded;
      case ZodiacElement.air:
        return Icons.air_rounded;
      case ZodiacElement.water:
        return Icons.water_drop_rounded;
    }
  }

  /// Element gradyan renkleri al
  static List<Color> getElementGradient(ZodiacElement element) {
    switch (element) {
      case ZodiacElement.fire:
        return [
          const Color(0xFFFF6B6B),
          const Color(0xFFEE5A24),
          const Color(0xFFEA2027),
        ];
      case ZodiacElement.earth:
        return [
          const Color(0xFF6C5CE7),
          const Color(0xFF5F3DC4),
          const Color(0xFF4C3C92),
        ];
      case ZodiacElement.air:
        return [
          const Color(0xFF74B9FF),
          const Color(0xFF0984E3),
          const Color(0xFF2D3561),
        ];
      case ZodiacElement.water:
        return [
          const Color(0xFF00CEC9),
          const Color(0xFF00B894),
          const Color(0xFF00A085),
        ];
    }
  }

  /// Aylık burç tahmini al
  String getMonthlyForecast(ZodiacSign zodiacSign) {
    final now = DateTime.now();
    return ZodiacCalculator.getMonthlyForecast(zodiacSign, now.month, now.year);
  }

  /// Profilleri temizle
  void clearProfiles() {
    _motherProfile = null;
    _babyProfile = null;
    _currentCompatibility = null;
    _motherCharacteristics = null;
    _babyCharacteristics = null;
    _clearError();
    notifyListeners();
  }

  /// Anne profilini güncelle
  Future<void> updateMotherProfile(AstrologicalProfile profile) async {
    _setLoading(true);
    try {
      _motherProfile = profile;
      _motherCharacteristics = ZodiacCalculator.getZodiacCharacteristics(
        profile.zodiacSign,
      );

      if (_babyProfile != null) {
        await _calculateCompatibility();
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Anne profili güncelleme hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Bebek profilini güncelle
  Future<void> updateBabyProfile(AstrologicalProfile profile) async {
    _setLoading(true);
    try {
      _babyProfile = profile;
      _babyCharacteristics = ZodiacCalculator.getZodiacCharacteristics(
        profile.zodiacSign,
      );

      if (_motherProfile != null) {
        await _calculateCompatibility();
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Bebek profili güncelleme hatası: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
