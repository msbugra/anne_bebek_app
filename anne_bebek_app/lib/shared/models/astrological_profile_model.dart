import 'package:json_annotation/json_annotation.dart';

part 'astrological_profile_model.g.dart';

enum PersonType {
  @JsonValue('mother')
  mother, // Anne
  @JsonValue('baby')
  baby, // Bebek
}

enum ZodiacSign {
  @JsonValue('aries')
  aries, // Koç
  @JsonValue('taurus')
  taurus, // Boğa
  @JsonValue('gemini')
  gemini, // İkizler
  @JsonValue('cancer')
  cancer, // Yengeç
  @JsonValue('leo')
  leo, // Aslan
  @JsonValue('virgo')
  virgo, // Başak
  @JsonValue('libra')
  libra, // Terazi
  @JsonValue('scorpio')
  scorpio, // Akrep
  @JsonValue('sagittarius')
  sagittarius, // Yay
  @JsonValue('capricorn')
  capricorn, // Oğlak
  @JsonValue('aquarius')
  aquarius, // Kova
  @JsonValue('pisces')
  pisces, // Balık
}

enum ZodiacElement {
  @JsonValue('fire')
  fire, // Ateş
  @JsonValue('earth')
  earth, // Toprak
  @JsonValue('air')
  air, // Hava
  @JsonValue('water')
  water, // Su
}

@JsonSerializable()
class AstrologicalProfile {
  final int? id;
  final int personId; // mother_id veya baby_id
  final PersonType personType;
  final ZodiacSign zodiacSign;
  final DateTime birthDate;
  final String? birthTime; // HH:mm formatında
  final String? birthCity;
  final String? birthCountry;
  final List<String> personalityTraits; // Kişilik özellikleri
  final String? compatibilityNotes; // Uyumluluk notları
  final Map<String, dynamic>? birthChartData; // Doğum haritası verileri
  final DateTime createdAt;
  final DateTime updatedAt;

  const AstrologicalProfile({
    this.id,
    required this.personId,
    required this.personType,
    required this.zodiacSign,
    required this.birthDate,
    this.birthTime,
    this.birthCity,
    this.birthCountry,
    this.personalityTraits = const [],
    this.compatibilityNotes,
    this.birthChartData,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory AstrologicalProfile.fromJson(Map<String, dynamic> json) =>
      _$AstrologicalProfileFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$AstrologicalProfileToJson(this);

  // Factory constructor from database map
  factory AstrologicalProfile.fromMap(Map<String, dynamic> map) {
    return AstrologicalProfile(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      personType: PersonType.values.firstWhere(
        (e) => e.toString().split('.').last == map['person_type'],
        orElse: () => PersonType.baby,
      ),
      zodiacSign: ZodiacSign.values.firstWhere(
        (e) => e.toString().split('.').last == map['zodiac_sign'],
        orElse: () => ZodiacSign.aries,
      ),
      birthDate: DateTime.parse(map['birth_date'] as String),
      birthTime: map['birth_time'] as String?,
      birthCity: map['birth_city'] as String?,
      birthCountry: map['birth_country'] as String?,
      personalityTraits: map['personality_traits'] != null
          ? List<String>.from(map['personality_traits'].split(','))
          : [],
      compatibilityNotes: map['compatibility_notes'] as String?,
      birthChartData: map['birth_chart_data'] != null
          ? Map<String, dynamic>.from(map['birth_chart_data'])
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'person_type': personType.toString().split('.').last,
      'zodiac_sign': zodiacSign.toString().split('.').last,
      'birth_date': birthDate.toIso8601String(),
      'birth_time': birthTime,
      'birth_city': birthCity,
      'birth_country': birthCountry,
      'personality_traits': personalityTraits.join(','),
      'compatibility_notes': compatibilityNotes,
      'birth_chart_data': birthChartData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Burç adını Türkçe olarak döndür
  String get zodiacSignDisplayName {
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

  // Kişi türü Türkçe açıklaması
  String get personTypeDisplayName {
    switch (personType) {
      case PersonType.mother:
        return 'Anne';
      case PersonType.baby:
        return 'Bebek';
    }
  }

  // Burçun elementini döndür
  ZodiacElement get zodiacElement {
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

  // Element adını Türkçe olarak döndür
  String get zodiacElementDisplayName {
    switch (zodiacElement) {
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

  // Doğum tarihi ve saati birleşik string
  String get fullBirthDateTime {
    if (birthTime != null) {
      return '${birthDate.day}.${birthDate.month}.${birthDate.year} $birthTime';
    }
    return '${birthDate.day}.${birthDate.month}.${birthDate.year}';
  }

  // Doğum yeri bilgisi
  String? get birthLocation {
    if (birthCity != null && birthCountry != null) {
      return '$birthCity, $birthCountry';
    } else if (birthCity != null) {
      return birthCity;
    } else if (birthCountry != null) {
      return birthCountry;
    }
    return null;
  }

  // Kişilik özelliklerini string olarak döndür
  String get personalityTraitsText {
    if (personalityTraits.isEmpty) return 'Belirtilmemiş';
    return personalityTraits.join(', ');
  }

  // Copy with method
  AstrologicalProfile copyWith({
    int? id,
    int? personId,
    PersonType? personType,
    ZodiacSign? zodiacSign,
    DateTime? birthDate,
    String? birthTime,
    String? birthCity,
    String? birthCountry,
    List<String>? personalityTraits,
    String? compatibilityNotes,
    Map<String, dynamic>? birthChartData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AstrologicalProfile(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      personType: personType ?? this.personType,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      birthCity: birthCity ?? this.birthCity,
      birthCountry: birthCountry ?? this.birthCountry,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      compatibilityNotes: compatibilityNotes ?? this.compatibilityNotes,
      birthChartData: birthChartData ?? this.birthChartData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AstrologicalProfile &&
        other.id == id &&
        other.personId == personId &&
        other.personType == personType &&
        other.zodiacSign == zodiacSign &&
        other.birthDate == birthDate &&
        other.birthTime == birthTime &&
        other.birthCity == birthCity &&
        other.birthCountry == birthCountry &&
        other.personalityTraits.toString() == personalityTraits.toString() &&
        other.compatibilityNotes == compatibilityNotes &&
        other.birthChartData.toString() == birthChartData.toString();
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      personId,
      personType,
      zodiacSign,
      birthDate,
      birthTime,
      birthCity,
      birthCountry,
      personalityTraits,
      compatibilityNotes,
      birthChartData,
    );
  }

  @override
  String toString() {
    return 'AstrologicalProfile(id: $id, personType: $personTypeDisplayName, '
        'zodiacSign: $zodiacSignDisplayName, birthDate: $fullBirthDateTime, '
        'element: $zodiacElementDisplayName)';
  }
}

// Astroloji profili için yardımcı servis
class AstrologicalProfileService {
  // Varsayılan kişilik özellikleri (burca göre)
  static List<String> getDefaultPersonalityTraits(ZodiacSign zodiacSign) {
    switch (zodiacSign) {
      case ZodiacSign.aries:
        return ['Enerjik', 'Lider ruhu', 'Cesur', 'Hırslı', 'Sabırsız'];
      case ZodiacSign.taurus:
        return ['Kararlı', 'Güvenilir', 'Sakin', 'Sevgi dolu', 'İnatçı'];
      case ZodiacSign.gemini:
        return ['Meraklı', 'Sosyal', 'Zeki', 'Konuşkan', 'Değişken'];
      case ZodiacSign.cancer:
        return ['Duygusal', 'Koruyucu', 'Sezgisel', 'Evine bağlı', 'Hassas'];
      case ZodiacSign.leo:
        return ['Kendine güvenli', 'Yaratıcı', 'Cömert', 'Gururlu', 'Dramatik'];
      case ZodiacSign.virgo:
        return ['Detaycı', 'Düzenli', 'Analitik', 'Yardımsever', 'Eleştirel'];
      case ZodiacSign.libra:
        return ['Dengeli', 'Adil', 'Sosyal', 'Diplomasi', 'Kararsız'];
      case ZodiacSign.scorpio:
        return ['Tutkulu', 'Gizemli', 'Güçlü irade', 'Bağlı', 'Kıskanç'];
      case ZodiacSign.sagittarius:
        return ['Özgür', 'İyimser', 'Macera seven', 'Dürüst', 'Dikkatsiz'];
      case ZodiacSign.capricorn:
        return ['Disiplinli', 'Sorumlu', 'Hırslı', 'Pratik', 'Katı'];
      case ZodiacSign.aquarius:
        return ['Özgün', 'Bağımsız', 'İnsancıl', 'Yenilikçi', 'Asi'];
      case ZodiacSign.pisces:
        return ['Hayal kuran', 'Empatik', 'Yaratıcı', 'Sezgisel', 'Karamsar'];
    }
  }

  // Anne-bebek uyumluluğu için genel notlar
  static String getMotherBabyCompatibilityNotes(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Element uyumluluğu
    ZodiacElement motherElement = _getElementForSign(motherSign);
    ZodiacElement babyElement = _getElementForSign(babySign);

    String baseCompatibility = _getElementCompatibility(
      motherElement,
      babyElement,
    );

    // Özel kombinasyonlar
    if (motherSign == babySign) {
      return 'Aynı burçtan anne ve bebek: $baseCompatibility Birbirinizi çok iyi anlayacaksınız.';
    }

    return '$baseCompatibility ${_getSpecificSignCompatibility(motherSign, babySign)}';
  }

  // Yardımcı metodlar
  static ZodiacElement _getElementForSign(ZodiacSign sign) {
    switch (sign) {
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

  static String _getElementCompatibility(
    ZodiacElement element1,
    ZodiacElement element2,
  ) {
    if (element1 == element2) {
      return 'Aynı element: Doğal uyum ve anlayış.';
    }

    // Uyumlu elementler
    if ((element1 == ZodiacElement.fire && element2 == ZodiacElement.air) ||
        (element1 == ZodiacElement.air && element2 == ZodiacElement.fire)) {
      return 'Ateş-Hava uyumu: Enerjik ve destekleyici ilişki.';
    }
    if ((element1 == ZodiacElement.earth && element2 == ZodiacElement.water) ||
        (element1 == ZodiacElement.water && element2 == ZodiacElement.earth)) {
      return 'Toprak-Su uyumu: Besleyici ve istikrarlı bağ.';
    }

    // Zor uyumlar
    if ((element1 == ZodiacElement.fire && element2 == ZodiacElement.water) ||
        (element1 == ZodiacElement.water && element2 == ZodiacElement.fire)) {
      return 'Ateş-Su karşıtlığı: Denge kurarak güçlü bağ.';
    }
    if ((element1 == ZodiacElement.earth && element2 == ZodiacElement.air) ||
        (element1 == ZodiacElement.air && element2 == ZodiacElement.earth)) {
      return 'Toprak-Hava karşıtlığı: Farklılıklar zenginlik katar.';
    }

    return 'Özel element uyumu: Her ilişki benzersizdir.';
  }

  static String _getSpecificSignCompatibility(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Bazı özel kombinasyon örnekleri
    if (motherSign == ZodiacSign.cancer && babySign == ZodiacSign.pisces) {
      return 'Yengeç anne ve Balık bebek: Derin duygusal bağ ve sezgisel anlayış.';
    }
    if (motherSign == ZodiacSign.virgo && babySign == ZodiacSign.taurus) {
      return 'Başak anne ve Boğa bebek: Pratik yaklaşım ve güvenli ortam.';
    }
    if (motherSign == ZodiacSign.leo && babySign == ZodiacSign.aries) {
      return 'Aslan anne ve Koç bebek: Enerjik ve yaratıcı etkileşim.';
    }

    return 'Her anne-bebek çifti kendine özgü güzel bir uyum yaratır.';
  }

  // Bebek yaşına göre astrolojik tavsiyeleri
  static List<String> getAstrologyTipsForBabyAge(
    ZodiacSign babySign,
    int ageInMonths,
  ) {
    List<String> tips = [];

    if (ageInMonths <= 3) {
      // 0-3 ay
      tips.addAll(_getNewbornTips(babySign));
    } else if (ageInMonths <= 12) {
      // 3-12 ay
      tips.addAll(_getInfantTips(babySign));
    } else if (ageInMonths <= 36) {
      // 1-3 yaş
      tips.addAll(_getToddlerTips(babySign));
    }

    return tips;
  }

  static List<String> _getNewbornTips(ZodiacSign babySign) {
    switch (babySign) {
      case ZodiacSign.aries:
        return [
          'Koç bebekleri aktif ve enerjiktir, bol stimülasyon sağlayın.',
          'Hızlı hareket eden objelerle ilgilenebilirler.',
        ];
      case ZodiacSign.cancer:
        return [
          'Yengeç bebekleri hassastır, sakin ve güvenli ortam sağlayın.',
          'Anne kokusu ve sıcaklık çok önemlidir.',
        ];
      case ZodiacSign.leo:
        return [
          'Aslan bebekleri ilgi arayışındadır, bol sevgi gösterin.',
          'Parlak renkli oyuncaklar ilgisini çeker.',
        ];
      default:
        return [
          '${babySign.toString().split('.').last} burcu bebek özel bir ilgiye sahiptir.',
          'Doğal özelliklerini gözlemleyerek destekleyin.',
        ];
    }
  }

  static List<String> _getInfantTips(ZodiacSign babySign) {
    switch (babySign) {
      case ZodiacSign.gemini:
        return [
          'İkizler bebekleri çok meraklıdır, farklı sesler ve aktiviteler sunun.',
          'Konuşarak çok zaman geçirin, kelime hazinesini destekleyin.',
        ];
      case ZodiacSign.taurus:
        return [
          'Boğa bebekleri rutinleri sever, düzenli program oluşturun.',
          'Dokunsal oyuncaklar ve yumuşak materyaller tercih ederler.',
        ];
      default:
        return [
          'Bu dönemde burç özelliklerini gözlemleyebilirsiniz.',
          'Kişiliğine uygun aktiviteler planlayın.',
        ];
    }
  }

  static List<String> _getToddlerTips(ZodiacSign babySign) {
    switch (babySign) {
      case ZodiacSign.sagittarius:
        return [
          'Yay burcu çocukları özgürlük sever, keşfetmesine izin verin.',
          'Açık hava aktiviteleri çok önemlidir.',
        ];
      case ZodiacSign.virgo:
        return [
          'Başak burcu çocukları detaycıdır, küçük parçalı oyuncaklar verin.',
          'Düzen ve temizliği sevdirir.',
        ];
      default:
        return [
          'Kişiliği şekillenmeye başladı, destekleyici olun.',
          'Burç özelliklerine uygun hobiler keşfedin.',
        ];
    }
  }
}
