import '../../shared/models/astrological_profile_model.dart';
import '../../shared/models/zodiac_compatibility_model.dart';
import '../../shared/models/zodiac_characteristics_model.dart';

/// Burç hesaplama ve astroloji işlemleri için yardımcı sınıf
class ZodiacCalculator {
  /// Doğum tarihi verilen kişinin burcunu hesaplar
  ///
  /// [birthDate] - Doğum tarihi
  ///
  /// Örnek kullanım:
  /// ```dart
  /// DateTime birthDate = DateTime(1990, 5, 15);
  /// ZodiacSign sign = ZodiacCalculator.calculateZodiacSign(birthDate);
  /// ```
  static ZodiacSign calculateZodiacSign(DateTime birthDate) {
    int month = birthDate.month;
    int day = birthDate.day;

    switch (month) {
      case 1: // Ocak
        return day <= 19 ? ZodiacSign.capricorn : ZodiacSign.aquarius;
      case 2: // Şubat
        return day <= 18 ? ZodiacSign.aquarius : ZodiacSign.pisces;
      case 3: // Mart
        return day <= 20 ? ZodiacSign.pisces : ZodiacSign.aries;
      case 4: // Nisan
        return day <= 19 ? ZodiacSign.aries : ZodiacSign.taurus;
      case 5: // Mayıs
        return day <= 20 ? ZodiacSign.taurus : ZodiacSign.gemini;
      case 6: // Haziran
        return day <= 20 ? ZodiacSign.gemini : ZodiacSign.cancer;
      case 7: // Temmuz
        return day <= 22 ? ZodiacSign.cancer : ZodiacSign.leo;
      case 8: // Ağustos
        return day <= 22 ? ZodiacSign.leo : ZodiacSign.virgo;
      case 9: // Eylül
        return day <= 22 ? ZodiacSign.virgo : ZodiacSign.libra;
      case 10: // Ekim
        return day <= 22 ? ZodiacSign.libra : ZodiacSign.scorpio;
      case 11: // Kasım
        return day <= 21 ? ZodiacSign.scorpio : ZodiacSign.sagittarius;
      case 12: // Aralık
        return day <= 21 ? ZodiacSign.sagittarius : ZodiacSign.capricorn;
      default:
        return ZodiacSign.aries; // Varsayılan
    }
  }

  /// Belirtilen burç için özelliklerini döndürür
  ///
  /// [zodiacSign] - Burç
  ///
  /// Örnek kullanım:
  /// ```dart
  /// ZodiacCharacteristics characteristics =
  ///     ZodiacCalculator.getZodiacCharacteristics(ZodiacSign.leo);
  /// ```
  static ZodiacCharacteristics? getZodiacCharacteristics(
    ZodiacSign zodiacSign,
  ) {
    return ZodiacCharacteristicsService.findCharacteristics(zodiacSign);
  }

  /// Anne ve bebek burcu arasındaki uyumluluğu hesaplar
  ///
  /// [motherSign] - Anne burcu
  /// [babySign] - Bebek burcu
  ///
  /// Örnek kullanım:
  /// ```dart
  /// ZodiacCompatibility compatibility =
  ///     ZodiacCalculator.calculateCompatibility(ZodiacSign.leo, ZodiacSign.aries);
  /// ```
  static ZodiacCompatibility calculateCompatibility(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Önce önceden tanımlı uyumluluk verilerini kontrol et
    ZodiacCompatibility? predefinedCompatibility =
        ZodiacCompatibilityService.findCompatibility(motherSign, babySign);

    if (predefinedCompatibility != null) {
      return predefinedCompatibility;
    }

    // Eğer önceden tanımlı değilse dinamik olarak oluştur
    return _generateDynamicCompatibility(motherSign, babySign);
  }

  /// Belirli bir yaş için burca özgü ebeveynlik önerilerini döndürür
  ///
  /// [zodiacSign] - Burç
  /// [ageInMonths] - Yaş (ay cinsinden)
  ///
  /// Örnek kullanım:
  /// ```dart
  /// List<String> tips = ZodiacCalculator.getParentingTips(ZodiacSign.cancer, 12);
  /// ```
  static List<String> getParentingTips(ZodiacSign zodiacSign, int ageInMonths) {
    return AstrologicalProfileService.getAstrologyTipsForBabyAge(
      zodiacSign,
      ageInMonths,
    );
  }

  /// Burç elementini döndürür
  ///
  /// [zodiacSign] - Burç
  ///
  /// Örnek kullanım:
  /// ```dart
  /// ZodiacElement element = ZodiacCalculator.getZodiacElement(ZodiacSign.aries);
  /// ```
  static ZodiacElement getZodiacElement(ZodiacSign zodiacSign) {
    switch (zodiacSign) {
      case ZodiacSign.aries:
      case ZodiacSign.leo:
      case ZodiacSign.sagittarius:
        return ZodiacElement.fire;
      case ZodiacSign.taurus:
      case ZodiacSign.virgo:
      case ZodiacSign.capricorn:
        return ZodiacElement.earth;
      case ZodiacSign.gemini:
      case ZodiacSign.libra:
      case ZodiacSign.aquarius:
        return ZodiacElement.air;
      case ZodiacSign.cancer:
      case ZodiacSign.scorpio:
      case ZodiacSign.pisces:
        return ZodiacElement.water;
    }
  }

  /// Burç adını Türkçe olarak döndürür
  ///
  /// [zodiacSign] - Burç
  ///
  /// Örnek kullanım:
  /// ```dart
  /// String name = ZodiacCalculator.getZodiacName(ZodiacSign.scorpio);
  /// ```
  static String getZodiacName(ZodiacSign zodiacSign) {
    switch (zodiacSign) {
      case ZodiacSign.aries:
        return 'Koç';
      case ZodiacSign.taurus:
        return 'Boğa';
      case ZodiacSign.gemini:
        return 'İkizler';
      case ZodiacSign.cancer:
        return 'Yengeç';
      case ZodiacSign.leo:
        return 'Aslan';
      case ZodiacSign.virgo:
        return 'Başak';
      case ZodiacSign.libra:
        return 'Terazi';
      case ZodiacSign.scorpio:
        return 'Akrep';
      case ZodiacSign.sagittarius:
        return 'Yay';
      case ZodiacSign.capricorn:
        return 'Oğlak';
      case ZodiacSign.aquarius:
        return 'Kova';
      case ZodiacSign.pisces:
        return 'Balık';
    }
  }

  /// Element adını Türkçe olarak döndürür
  ///
  /// [element] - Element
  ///
  /// Örnek kullanım:
  /// ```dart
  /// String elementName = ZodiacCalculator.getElementName(ZodiacElement.fire);
  /// ```
  static String getElementName(ZodiacElement element) {
    switch (element) {
      case ZodiacElement.fire:
        return 'Ateş';
      case ZodiacElement.earth:
        return 'Toprak';
      case ZodiacElement.air:
        return 'Hava';
      case ZodiacElement.water:
        return 'Su';
    }
  }

  /// Doğum tarih ve saat bilgisiyle detaylı astrolojik profil oluşturur
  ///
  /// [personId] - Kişi ID'si
  /// [personType] - Kişi türü (anne/bebek)
  /// [birthDate] - Doğum tarihi
  /// [birthTime] - Doğum saati (opsiyonel)
  /// [birthCity] - Doğum yeri (opsiyonel)
  ///
  /// Örnek kullanım:
  /// ```dart
  /// AstrologicalProfile profile = ZodiacCalculator.createAstrologicalProfile(
  ///   1, PersonType.baby, DateTime(2023, 6, 15), "14:30", "İstanbul");
  /// ```
  static AstrologicalProfile createAstrologicalProfile({
    required int personId,
    required PersonType personType,
    required DateTime birthDate,
    String? birthTime,
    String? birthCity,
    String? birthCountry,
  }) {
    ZodiacSign zodiacSign = calculateZodiacSign(birthDate);
    List<String> personalityTraits =
        AstrologicalProfileService.getDefaultPersonalityTraits(zodiacSign);

    DateTime now = DateTime.now();

    return AstrologicalProfile(
      personId: personId,
      personType: personType,
      zodiacSign: zodiacSign,
      birthDate: birthDate,
      birthTime: birthTime,
      birthCity: birthCity,
      birthCountry: birthCountry,
      personalityTraits: personalityTraits,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Burç tarihi aralığını döndürür
  ///
  /// [zodiacSign] - Burç
  ///
  /// Örnek kullanım:
  /// ```dart
  /// String dateRange = ZodiacCalculator.getZodiacDateRange(ZodiacSign.leo);
  /// ```
  static String getZodiacDateRange(ZodiacSign zodiacSign) {
    switch (zodiacSign) {
      case ZodiacSign.aries:
        return '21 Mart - 19 Nisan';
      case ZodiacSign.taurus:
        return '20 Nisan - 20 Mayıs';
      case ZodiacSign.gemini:
        return '21 Mayıs - 20 Haziran';
      case ZodiacSign.cancer:
        return '21 Haziran - 22 Temmuz';
      case ZodiacSign.leo:
        return '23 Temmuz - 22 Ağustos';
      case ZodiacSign.virgo:
        return '23 Ağustos - 22 Eylül';
      case ZodiacSign.libra:
        return '23 Eylül - 22 Ekim';
      case ZodiacSign.scorpio:
        return '23 Ekim - 21 Kasım';
      case ZodiacSign.sagittarius:
        return '22 Kasım - 21 Aralık';
      case ZodiacSign.capricorn:
        return '22 Aralık - 19 Ocak';
      case ZodiacSign.aquarius:
        return '20 Ocak - 18 Şubat';
      case ZodiacSign.pisces:
        return '19 Şubat - 20 Mart';
    }
  }

  /// İki burç arasındaki element uyumluluğunu kontrol eder
  ///
  /// [sign1] - İlk burç
  /// [sign2] - İkinci burç
  ///
  /// Örnek kullanım:
  /// ```dart
  /// bool compatible = ZodiacCalculator.areElementsCompatible(
  ///   ZodiacSign.aries, ZodiacSign.gemini);
  /// ```
  static bool areElementsCompatible(ZodiacSign sign1, ZodiacSign sign2) {
    ZodiacElement element1 = getZodiacElement(sign1);
    ZodiacElement element2 = getZodiacElement(sign2);

    // Aynı element = uyumlu
    if (element1 == element2) return true;

    // Uyumlu element çiftleri
    if ((element1 == ZodiacElement.fire && element2 == ZodiacElement.air) ||
        (element1 == ZodiacElement.air && element2 == ZodiacElement.fire) ||
        (element1 == ZodiacElement.earth && element2 == ZodiacElement.water) ||
        (element1 == ZodiacElement.water && element2 == ZodiacElement.earth)) {
      return true;
    }

    return false;
  }

  /// Burçlar arasındaki mesafeyi hesaplar (0-6 arası)
  ///
  /// [sign1] - İlk burç
  /// [sign2] - İkinci burç
  ///
  /// Örnek kullanım:
  /// ```dart
  /// int distance = ZodiacCalculator.calculateZodiacDistance(
  ///   ZodiacSign.aries, ZodiacSign.cancer);
  /// ```
  static int calculateZodiacDistance(ZodiacSign sign1, ZodiacSign sign2) {
    List<ZodiacSign> zodiacOrder = [
      ZodiacSign.aries,
      ZodiacSign.taurus,
      ZodiacSign.gemini,
      ZodiacSign.cancer,
      ZodiacSign.leo,
      ZodiacSign.virgo,
      ZodiacSign.libra,
      ZodiacSign.scorpio,
      ZodiacSign.sagittarius,
      ZodiacSign.capricorn,
      ZodiacSign.aquarius,
      ZodiacSign.pisces,
    ];

    int index1 = zodiacOrder.indexOf(sign1);
    int index2 = zodiacOrder.indexOf(sign2);

    int distance = (index2 - index1).abs();
    return distance > 6 ? 12 - distance : distance;
  }

  /// Aylık burç tahmini oluşturur
  ///
  /// [zodiacSign] - Burç
  /// [month] - Ay (1-12)
  /// [year] - Yıl
  ///
  /// Örnek kullanım:
  /// ```dart
  /// String forecast = ZodiacCalculator.getMonthlyForecast(ZodiacSign.leo, 6, 2024);
  /// ```
  static String getMonthlyForecast(ZodiacSign zodiacSign, int month, int year) {
    String zodiacName = getZodiacName(zodiacSign);
    String monthName = _getMonthName(month);

    // Basit tahmin algoritması
    List<String> forecasts = [
      'Bu ay $zodiacName burcu için yaratıcılık öne çıkacak.',
      '$monthName ayı $zodiacName burcu için yeni fırsatlar getiriyör.',
      'Bu dönemde $zodiacName burcu enerjisi yüksek olacak.',
      '$monthName ayında $zodiacName burcu için dengeli bir dönem.',
      'Bu ay $zodiacName burcu için sabır gerektiren bir periode.',
    ];

    // Hash-based selection for consistency
    int hashValue = (zodiacSign.index + month + year) % forecasts.length;
    return forecasts[hashValue];
  }

  /// Burç yükselen hesaplama (yaklaşık - doğum saati gerekli)
  ///
  /// [birthDate] - Doğum tarihi
  /// [birthTime] - Doğum saati ("HH:mm" formatında)
  ///
  /// Örnek kullanım:
  /// ```dart
  /// ZodiacSign? ascendant = ZodiacCalculator.calculateAscendant(
  ///   DateTime(1990, 5, 15), "14:30");
  /// ```
  static ZodiacSign? calculateAscendant(DateTime birthDate, String? birthTime) {
    if (birthTime == null) return null;

    // Basitleştirilmiş yükselen hesaplama
    // Gerçek uygulamada coğrafi konum ve daha karmaşık hesaplamalar gerekir
    try {
      List<String> timeParts = birthTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      // Doğum saatini temel alan basit formül
      int totalMinutes = hour * 60 + minute;
      int ascendantIndex = ((totalMinutes / 120) % 12).floor();

      List<ZodiacSign> zodiacOrder = [
        ZodiacSign.aries,
        ZodiacSign.taurus,
        ZodiacSign.gemini,
        ZodiacSign.cancer,
        ZodiacSign.leo,
        ZodiacSign.virgo,
        ZodiacSign.libra,
        ZodiacSign.scorpio,
        ZodiacSign.sagittarius,
        ZodiacSign.capricorn,
        ZodiacSign.aquarius,
        ZodiacSign.pisces,
      ];

      return zodiacOrder[ascendantIndex];
    } catch (e) {
      return null;
    }
  }

  // Private helper methods

  /// Dinamik uyumluluk hesaplama
  static ZodiacCompatibility _generateDynamicCompatibility(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    int score = _calculateCompatibilityScore(motherSign, babySign);
    CompatibilityLevel level = _getCompatibilityLevel(score);

    return ZodiacCompatibility(
      motherSign: motherSign,
      babySign: babySign,
      compatibilityScore: score,
      compatibilityLevel: level,
      compatibilityDescription: _generateCompatibilityDescription(
        motherSign,
        babySign,
        score,
      ),
      strengths: _generateCompatibilityStrengths(motherSign, babySign),
      challenges: _generateCompatibilityChallenges(motherSign, babySign),
      parentingTips: _generateCompatibilityParentingTips(motherSign, babySign),
      communicationTips: _generateCompatibilityCommunicationTips(
        motherSign,
        babySign,
      ),
      createdAt: DateTime.now(),
    );
  }

  /// Uyumluluk puanı hesaplama
  static int _calculateCompatibilityScore(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    int baseScore = 5;

    // Element uyumluluğu
    if (areElementsCompatible(motherSign, babySign)) {
      baseScore += 2;
    }

    // Burç mesafesi
    int distance = calculateZodiacDistance(motherSign, babySign);
    if (distance == 0) {
      baseScore += 3; // Aynı burç
    } else if (distance == 4) {
      baseScore += 2; // Trin (120 derece)
    } else if (distance == 2) {
      baseScore += 1; // Sextile (60 derece)
    } else if (distance == 6) {
      baseScore -= 1; // Opposition (180 derece)
    }

    return baseScore.clamp(1, 10);
  }

  /// Uyumluluk seviyesi belirleme
  static CompatibilityLevel _getCompatibilityLevel(int score) {
    if (score >= 9) return CompatibilityLevel.excellent;
    if (score >= 7) return CompatibilityLevel.veryGood;
    if (score >= 5) return CompatibilityLevel.good;
    if (score >= 3) return CompatibilityLevel.moderate;
    return CompatibilityLevel.challenging;
  }

  /// Uyumluluk açıklaması oluşturma
  static String _generateCompatibilityDescription(
    ZodiacSign motherSign,
    ZodiacSign babySign,
    int score,
  ) {
    String motherName = getZodiacName(motherSign);
    String babyName = getZodiacName(babySign);

    if (score >= 8) {
      return '$motherName anne ve $babyName bebek - Mükemmel bir uyum! Doğal anlayış yaşayacaksınız.';
    } else if (score >= 6) {
      return '$motherName anne ve $babyName bebek - İyi uyum. Birbirinizi kolayca anlayacaksınız.';
    } else if (score >= 4) {
      return '$motherName anne ve $babyName bebek - Dengeli bir ilişki. Karşılıklı öğrenme fırsatı.';
    } else {
      return '$motherName anne ve $babyName bebek - Farklılıklar zenginlik katacak. Sabır ve anlayış önemli.';
    }
  }

  /// Uyumluluk güçlü yanlarını oluşturma
  static List<String> _generateCompatibilityStrengths(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    List<String> strengths = ['Doğal anne-bebek bağı', 'Karşılıklı öğrenme'];

    if (areElementsCompatible(motherSign, babySign)) {
      strengths.add('Element uyumu');
    }

    if (motherSign == babySign) {
      strengths.add('Aynı burç anlayışı');
    }

    return strengths;
  }

  /// Uyumluluk zorluklarını oluşturma
  static List<String> _generateCompatibilityChallenges(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    List<String> challenges = [];

    if (!areElementsCompatible(motherSign, babySign)) {
      challenges.add('Element farklılıkları');
    }

    int distance = calculateZodiacDistance(motherSign, babySign);
    if (distance == 6) {
      challenges.add('Karşıt özellikler');
    }

    if (challenges.isEmpty) {
      challenges.add('Küçük uyum sorunları');
    }

    return challenges;
  }

  /// Ebeveynlik önerilerini oluşturma
  static List<String> _generateCompatibilityParentingTips(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    return [
      'Bebeğinizin doğal özelliklerini gözlemleyin',
      'Kendi burç özelliklerinizi dengeleyin',
      'Sabırlı yaklaşım benimseyin',
      'Sevgiyi farklı yollarla gösterin',
    ];
  }

  /// İletişim ipuçlarını oluşturma
  static List<String> _generateCompatibilityCommunicationTips(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    return [
      'Duygularınızı açık ifade edin',
      'Bebeğinizin tepkilerini gözlemleyin',
      'Tutarlı iletişim benimseyin',
      'Fiziksel teması ihmal etmeyin',
    ];
  }

  /// Ay adlarını Türkçe döndürme
  static String _getMonthName(int month) {
    const monthNames = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return monthNames[month - 1];
  }
}
