import '../constants/app_constants.dart';

class AgeCalculator {
  static DateTime? _lastCalculationDate;
  static int? _lastCalculationResult;
  static DateTime? _lastBirthDate;

  /// Bebeğin doğum tarihi ile şu anki tarih arasındaki farkı gün olarak hesaplar
  static int calculateAgeInDays(DateTime birthDate) {
    DateTime now = DateTime.now();

    // Cache kontrolü - performans optimizasyonu
    if (_lastBirthDate == birthDate &&
        _lastCalculationDate != null &&
        now.difference(_lastCalculationDate!).inMinutes < 5) {
      return _lastCalculationResult!;
    }

    int ageInDays = now.difference(birthDate).inDays;

    // Cache'i güncelle
    _lastBirthDate = birthDate;
    _lastCalculationDate = now;
    _lastCalculationResult = ageInDays;

    return ageInDays;
  }

  /// Bebeğin yaşını hafta olarak hesaplar
  static int calculateAgeInWeeks(DateTime birthDate) {
    int days = calculateAgeInDays(birthDate);
    return (days / 7).floor();
  }

  /// Bebeğin yaşını ay olarak hesaplar (daha hassas)
  static int calculateAgeInMonths(DateTime birthDate) {
    DateTime now = DateTime.now();
    int months = now.month - birthDate.month;
    int years = now.year - birthDate.year;

    // Gün kontrolü yaparak daha hassas hesaplama
    if (now.day < birthDate.day) {
      months--;
    }

    return months + (years * 12);
  }

  /// Bebeğin yaşını yıl olarak hesaplar
  static int calculateAgeInYears(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;

    // Doğum günü henüz gelmemişse yaşı bir azalt
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Bebeğin yaş grubunu belirler
  static String getAgeGroup(DateTime birthDate) {
    int days = calculateAgeInDays(birthDate);

    if (days <= AppConstants.newbornPeriod) {
      return 'Yenidoğan';
    } else if (days <= AppConstants.infantPeriod) {
      return 'Bebek';
    } else if (days <= AppConstants.toddlerStart) {
      return '1-3 Yaş';
    } else if (days <= AppConstants.preschoolStart) {
      return '3-5 Yaş';
    } else {
      return '5+ Yaş';
    }
  }

  /// Yaşa göre hangi gün grubuna ait olduğunu belirler (öneri sistemi için)
  static int getDayGroupForRecommendations(DateTime birthDate) {
    int ageInDays = calculateAgeInDays(birthDate);

    // Yenidoğan dönemi: her gün farklı (0-28 gün)
    if (ageInDays <= AppConstants.newbornPeriod) {
      return ageInDays;
    }

    // 1-3 yaş: günlük öneriler (29-1095 gün)
    if (ageInDays <= AppConstants.preschoolStart) {
      return ageInDays;
    }

    // 3-5 yaş: haftalık öneriler, gün grubuna dönüştür
    return -1; // Haftalık öneriler için ayrı method kullanılacak
  }

  /// 3-5 yaş aralığındaki çocuklar için hafta numarasını hesaplar
  static int getWeekNumberForRecommendations(DateTime birthDate) {
    int ageInDays = calculateAgeInDays(birthDate);

    if (ageInDays <= AppConstants.preschoolStart) {
      return -1; // Bu yaş grubu için haftalık öneri yok
    }

    // 3 yaş sonrasındaki günleri haftaya çevir
    int daysAfterThree = ageInDays - AppConstants.preschoolStart;
    return (daysAfterThree / 7).floor() + 1;
  }

  /// Bebeğin yaşını kullanıcı dostu formatta döndürür
  static String getFormattedAge(DateTime birthDate) {
    int ageInDays = calculateAgeInDays(birthDate);

    if (ageInDays < 0) {
      return 'Henüz doğmamış';
    } else if (ageInDays == 0) {
      return 'Yeni doğmuş';
    } else if (ageInDays <= 28) {
      return '$ageInDays günlük';
    } else if (ageInDays < 365) {
      int weeks = calculateAgeInWeeks(birthDate);
      int remainingDays = ageInDays - (weeks * 7);
      if (remainingDays == 0) {
        return '$weeks haftalık';
      } else {
        return '$weeks hafta $remainingDays günlük';
      }
    } else {
      int years = calculateAgeInYears(birthDate);
      int months = calculateAgeInMonths(birthDate) - (years * 12);

      if (years == 0) {
        return '$months aylık';
      } else if (months == 0) {
        return '$years yaşında';
      } else {
        return '$years yaş $months aylık';
      }
    }
  }

  /// İki tarih arasındaki farkı hesaplar (gebelik takibi için kullanılabilir)
  static Map<String, int> calculateTimeDifference(
    DateTime startDate,
    DateTime endDate,
  ) {
    Duration difference = endDate.difference(startDate);

    int days = difference.inDays;
    int weeks = (days / 7).floor();
    int remainingDays = days - (weeks * 7);

    return {'totalDays': days, 'weeks': weeks, 'remainingDays': remainingDays};
  }

  /// Doğum öncesi gebelik haftasını hesaplar (due date'e göre)
  static int? calculateGestationWeeks(DateTime? dueDate, DateTime? birthDate) {
    if (dueDate == null || birthDate == null) return null;

    // Normal gebelik 40 hafta (280 gün)
    DateTime conceptionDate = dueDate.subtract(const Duration(days: 280));
    int gestationDays = birthDate.difference(conceptionDate).inDays;

    if (gestationDays < 0) return null;

    return (gestationDays / 7).floor();
  }

  /// Prematüre olup olmadığını kontrol eder
  static bool isPremature(DateTime birthDate, {DateTime? dueDate}) {
    if (dueDate != null) {
      // Due date varsa ona göre hesapla
      return birthDate.isBefore(
        dueDate.subtract(const Duration(days: 21)),
      ); // 3 hafta öncesi
    }

    // Due date yoksa, yaş hesaplaması ile tahmini
    // Bu method için daha fazla bilgi gerekebilir
    return false;
  }

  /// Sonraki doğum gününe kalan süreyi hesaplar
  static Duration timeUntilNextBirthday(DateTime birthDate) {
    DateTime now = DateTime.now();
    DateTime thisYearBirthday = DateTime(
      now.year,
      birthDate.month,
      birthDate.day,
    );

    if (thisYearBirthday.isBefore(now)) {
      thisYearBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
    }

    return thisYearBirthday.difference(now);
  }

  /// Bebek gelişim dönemlerini belirler
  static String getDevelopmentalStage(DateTime birthDate) {
    int months = calculateAgeInMonths(birthDate);

    if (months < 1) return 'Yenidoğan';
    if (months < 3) return 'Erken Bebeklik';
    if (months < 6) return 'Orta Bebeklik';
    if (months < 12) return 'Geç Bebeklik';
    if (months < 18) return 'Erken Yürümeye Başlama';
    if (months < 24) return 'Geç Yürümeye Başlama';
    if (months < 36) return 'Erken Çocukluk';
    if (months < 48) return 'Orta Çocukluk';
    if (months < 60) return 'Geç Çocukluk';
    return 'Okul Öncesi';
  }

  /// Cache'i temizle
  static void clearCache() {
    _lastCalculationDate = null;
    _lastCalculationResult = null;
    _lastBirthDate = null;
  }
}
