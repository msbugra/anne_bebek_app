import 'package:json_annotation/json_annotation.dart';
import 'astrological_profile_model.dart';

part 'zodiac_compatibility_model.g.dart';

enum CompatibilityLevel {
  @JsonValue('excellent')
  excellent, // Mükemmel
  @JsonValue('very_good')
  veryGood, // Çok İyi
  @JsonValue('good')
  good, // İyi
  @JsonValue('moderate')
  moderate, // Orta
  @JsonValue('challenging')
  challenging, // Zorlu
}

@JsonSerializable()
class ZodiacCompatibility {
  final int? id;
  final ZodiacSign motherSign;
  final ZodiacSign babySign;
  final int compatibilityScore; // 1-10 arası puan
  final CompatibilityLevel compatibilityLevel;
  final String compatibilityDescription;
  final List<String> strengths; // Güçlü yanlar
  final List<String> challenges; // Zorlu yanlar
  final List<String> parentingTips; // Ebeveynlik önerileri
  final List<String> communicationTips; // İletişim ipuçları
  final String? dailyAdvice; // Günlük tavsiye
  final String? monthlyForecast; // Aylık tahmin
  final DateTime createdAt;

  const ZodiacCompatibility({
    this.id,
    required this.motherSign,
    required this.babySign,
    required this.compatibilityScore,
    required this.compatibilityLevel,
    required this.compatibilityDescription,
    this.strengths = const [],
    this.challenges = const [],
    this.parentingTips = const [],
    this.communicationTips = const [],
    this.dailyAdvice,
    this.monthlyForecast,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory ZodiacCompatibility.fromJson(Map<String, dynamic> json) =>
      _$ZodiacCompatibilityFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$ZodiacCompatibilityToJson(this);

  // Factory constructor from database map
  factory ZodiacCompatibility.fromMap(Map<String, dynamic> map) {
    return ZodiacCompatibility(
      id: map['id'] as int?,
      motherSign: ZodiacSign.values.firstWhere(
        (e) => e.toString().split('.').last == map['mother_sign'],
        orElse: () => ZodiacSign.aries,
      ),
      babySign: ZodiacSign.values.firstWhere(
        (e) => e.toString().split('.').last == map['baby_sign'],
        orElse: () => ZodiacSign.aries,
      ),
      compatibilityScore: map['compatibility_score'] as int,
      compatibilityLevel: CompatibilityLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['compatibility_level'],
        orElse: () => CompatibilityLevel.moderate,
      ),
      compatibilityDescription: map['compatibility_description'] as String,
      strengths: map['strengths'] != null
          ? List<String>.from(map['strengths'].split('|'))
          : [],
      challenges: map['challenges'] != null
          ? List<String>.from(map['challenges'].split('|'))
          : [],
      parentingTips: map['parenting_tips'] != null
          ? List<String>.from(map['parenting_tips'].split('|'))
          : [],
      communicationTips: map['communication_tips'] != null
          ? List<String>.from(map['communication_tips'].split('|'))
          : [],
      dailyAdvice: map['daily_advice'] as String?,
      monthlyForecast: map['monthly_forecast'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mother_sign': motherSign.toString().split('.').last,
      'baby_sign': babySign.toString().split('.').last,
      'compatibility_score': compatibilityScore,
      'compatibility_level': compatibilityLevel.toString().split('.').last,
      'compatibility_description': compatibilityDescription,
      'strengths': strengths.join('|'),
      'challenges': challenges.join('|'),
      'parenting_tips': parentingTips.join('|'),
      'communication_tips': communicationTips.join('|'),
      'daily_advice': dailyAdvice,
      'monthly_forecast': monthlyForecast,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Anne burcu Türkçe adı
  String get motherSignDisplayName {
    switch (motherSign) {
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

  // Bebek burcu Türkçe adı
  String get babySignDisplayName {
    switch (babySign) {
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

  // Uyumluluk seviyesi Türkçe açıklama
  String get compatibilityLevelDisplayName {
    switch (compatibilityLevel) {
      case CompatibilityLevel.excellent:
        return 'Mükemmel';
      case CompatibilityLevel.veryGood:
        return 'Çok İyi';
      case CompatibilityLevel.good:
        return 'İyi';
      case CompatibilityLevel.moderate:
        return 'Orta';
      case CompatibilityLevel.challenging:
        return 'Zorlu';
    }
  }

  // Uyumluluk başlığı
  String get compatibilityTitle {
    return '$motherSignDisplayName Anne & $babySignDisplayName Bebek';
  }

  // Uyumluluk puanı yüzdesi
  double get compatibilityPercentage {
    return (compatibilityScore / 10.0) * 100;
  }

  // Uyumluluk puanı emojisi
  String get compatibilityEmoji {
    if (compatibilityScore >= 9) return '💖';
    if (compatibilityScore >= 7) return '😊';
    if (compatibilityScore >= 5) return '😐';
    if (compatibilityScore >= 3) return '😕';
    return '😰';
  }

  // Güçlü yanları metin olarak
  String get strengthsText {
    if (strengths.isEmpty) return 'Belirtilmemiş';
    return strengths.map((s) => '• $s').join('\n');
  }

  // Zorlu yanları metin olarak
  String get challengesText {
    if (challenges.isEmpty) return 'Özel zorluk belirtilmemiş';
    return challenges.map((c) => '• $c').join('\n');
  }

  // Ebeveynlik önerilerini metin olarak
  String get parentingTipsText {
    if (parentingTips.isEmpty) {
      return 'Genel ebeveynlik yaklaşımı uygulanabilir';
    }
    return parentingTips.map((tip) => '• $tip').join('\n');
  }

  // İletişim ipuçlarını metin olarak
  String get communicationTipsText {
    if (communicationTips.isEmpty) return 'Doğal iletişim yeterlidir';
    return communicationTips.map((tip) => '• $tip').join('\n');
  }

  // Copy with method
  ZodiacCompatibility copyWith({
    int? id,
    ZodiacSign? motherSign,
    ZodiacSign? babySign,
    int? compatibilityScore,
    CompatibilityLevel? compatibilityLevel,
    String? compatibilityDescription,
    List<String>? strengths,
    List<String>? challenges,
    List<String>? parentingTips,
    List<String>? communicationTips,
    String? dailyAdvice,
    String? monthlyForecast,
    DateTime? createdAt,
  }) {
    return ZodiacCompatibility(
      id: id ?? this.id,
      motherSign: motherSign ?? this.motherSign,
      babySign: babySign ?? this.babySign,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      compatibilityLevel: compatibilityLevel ?? this.compatibilityLevel,
      compatibilityDescription:
          compatibilityDescription ?? this.compatibilityDescription,
      strengths: strengths ?? this.strengths,
      challenges: challenges ?? this.challenges,
      parentingTips: parentingTips ?? this.parentingTips,
      communicationTips: communicationTips ?? this.communicationTips,
      dailyAdvice: dailyAdvice ?? this.dailyAdvice,
      monthlyForecast: monthlyForecast ?? this.monthlyForecast,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZodiacCompatibility &&
        other.id == id &&
        other.motherSign == motherSign &&
        other.babySign == babySign &&
        other.compatibilityScore == compatibilityScore &&
        other.compatibilityLevel == compatibilityLevel &&
        other.compatibilityDescription == compatibilityDescription &&
        other.strengths.toString() == strengths.toString() &&
        other.challenges.toString() == challenges.toString() &&
        other.parentingTips.toString() == parentingTips.toString() &&
        other.communicationTips.toString() == communicationTips.toString() &&
        other.dailyAdvice == dailyAdvice &&
        other.monthlyForecast == monthlyForecast;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      motherSign,
      babySign,
      compatibilityScore,
      compatibilityLevel,
      compatibilityDescription,
      strengths,
      challenges,
      parentingTips,
      communicationTips,
      dailyAdvice,
      monthlyForecast,
    );
  }

  @override
  String toString() {
    return 'ZodiacCompatibility(title: $compatibilityTitle, '
        'score: $compatibilityScore/10, level: $compatibilityLevelDisplayName)';
  }
}

// Burç uyumluluğu servisi
class ZodiacCompatibilityService {
  // Tüm burç kombinasyonları için uyumluluk verileri
  static List<ZodiacCompatibility> getAllCompatibilities() {
    List<ZodiacCompatibility> compatibilities = [];
    DateTime now = DateTime.now();

    // Örnek uyumluluk verileri
    compatibilities.addAll([
      // Koç Anne kombinasyonları
      ZodiacCompatibility(
        motherSign: ZodiacSign.aries,
        babySign: ZodiacSign.aries,
        compatibilityScore: 8,
        compatibilityLevel: CompatibilityLevel.veryGood,
        compatibilityDescription:
            'Koç anne ve Koç bebek - Enerjik ve dinamik bir ikilisi! Birbirinizin hızına yetişmekte zorlanmayacaksınız.',
        strengths: [
          'Yüksek enerji seviyesi',
          'Hızlı anlayış',
          'Maceraya açıklık',
          'Güçlü bağımsızlık',
        ],
        challenges: [
          'İkisi de sabırsız olabilir',
          'Rekabet hissi',
          'Öfke kontrolü gerekir',
        ],
        parentingTips: [
          'Bebeğinize sabırlı olmayı öğretin',
          'Enerjiyi doğru kanalize edin',
          'Güvenli sınırlar koyun',
          'Fiziksel aktivitelere ağırlık verin',
        ],
        communicationTips: [
          'Net ve direkt konuşun',
          'Hızlı karar verme becerisini destekleyin',
          'Liderlik özelliklerini besleyin',
        ],
        dailyAdvice:
            'Bugün bebeğinizle aktif bir gün geçirin. Enerjinizi pozitif aktivitelere yönlendirin.',
        monthlyForecast:
            'Bu ay bebeğinizin bağımsızlık isteği artabilir. Güvenli keşfetme fırsatları sunun.',
        createdAt: now,
      ),

      ZodiacCompatibility(
        motherSign: ZodiacSign.cancer,
        babySign: ZodiacSign.pisces,
        compatibilityScore: 10,
        compatibilityLevel: CompatibilityLevel.excellent,
        compatibilityDescription:
            'Yengeç anne ve Balık bebek - Mükemmel sezgisel bağlantı! Ruhsal düzeyde derin anlayış.',
        strengths: [
          'Güçlü duygusal bağ',
          'Sezgisel anlayış',
          'Koruyucu sevgi',
          'Yaratıcı hayal gücü',
        ],
        challenges: [
          'Aşırı koruyucu olma riski',
          'Duygusal aşırılık',
          'Gerçeklik ile hayal ayrımı',
        ],
        parentingTips: [
          'Duygusal dengeyi koruyun',
          'Yaratıcı aktiviteleri destekleyin',
          'Güven veren rutinler oluşturun',
          'Sanatsal yetenekleri keşfedin',
        ],
        communicationTips: [
          'Duygularınızı açıkça ifade edin',
          'Hikaye anlatımı kullanın',
          'Müzik ve sanata yer verin',
        ],
        dailyAdvice:
            'Bugün bebeğinizle sakin, sevgi dolu zaman geçirin. Sezgilerinize güvenin.',
        monthlyForecast:
            'Bu ay bebeğinizin hayal gücü çok aktif olacak. Yaratıcı oyunlara odaklanın.',
        createdAt: now,
      ),

      ZodiacCompatibility(
        motherSign: ZodiacSign.leo,
        babySign: ZodiacSign.aquarius,
        compatibilityScore: 6,
        compatibilityLevel: CompatibilityLevel.moderate,
        compatibilityDescription:
            'Aslan anne ve Kova bebek - Zıt kutuplar! Farklılıklarınız zenginlik katacak.',
        strengths: [
          'Yaratıcı dengeleyici güç',
          'Farklı bakış açıları',
          'Sosyal çeşitlilik',
          'Öğretici ilişki',
        ],
        challenges: [
          'Dikkat ihtiyacı çelişkisi',
          'Bağımsızlık vs kontrol',
          'Farklı iletişim tarzları',
        ],
        parentingTips: [
          'Bebeğinizin bağımsızlığına saygı gösterin',
          'Çeşitli sosyal ortamlar sunun',
          'Yaratıcı özgürlük tanıyın',
          'Teknolojiye açık olun',
        ],
        communicationTips: [
          'Mantıklı açıklamalar yapın',
          'Özgün fikirlerini destekleyin',
          'Grup aktivitelerine katılın',
        ],
        dailyAdvice: 'Bugün bebeğinizin farklı yanlarını keşfetmeye odaklanın.',
        monthlyForecast:
            'Bu ay bebeğiniz sosyal aktivitelere daha çok ilgi gösterebilir.',
        createdAt: now,
      ),

      ZodiacCompatibility(
        motherSign: ZodiacSign.virgo,
        babySign: ZodiacSign.taurus,
        compatibilityScore: 9,
        compatibilityLevel: CompatibilityLevel.excellent,
        compatibilityDescription:
            'Başak anne ve Boğa bebek - Toprak elementi uyumu! Pratik ve istikrarlı yaklaşım.',
        strengths: [
          'İstikrarlı ortam',
          'Pratik çözümler',
          'Güvenli rutin',
          'Detaylı bakım',
        ],
        challenges: [
          'Aşırı mükemmeliyetçilik',
          'Değişime direnç',
          'Fazla koruyucu olma',
        ],
        parentingTips: [
          'Esnek rutinler oluşturun',
          'Doğal öğrenme destekleyin',
          'Sabırlı yaklaşım benimseyin',
          'Organik çevre sağlayın',
        ],
        communicationTips: [
          'Sakin ve tutarlı tonla konuşun',
          'Somut örnekler verin',
          'Dokunsal deneyimler sunun',
        ],
        dailyAdvice: 'Bugün bebeğinizle sakin, düzenli aktiviteler yapın.',
        monthlyForecast:
            'Bu ay bebeğinizin öğrenme kapasitesi artacak, yeni beceriler kazanabilir.',
        createdAt: now,
      ),

      ZodiacCompatibility(
        motherSign: ZodiacSign.gemini,
        babySign: ZodiacSign.sagittarius,
        compatibilityScore: 7,
        compatibilityLevel: CompatibilityLevel.good,
        compatibilityDescription:
            'İkizler anne ve Yay bebek - Karşıt ama tamamlayıcı! Öğrenme ve keşfetme tutkusu.',
        strengths: [
          'Yüksek öğrenme merakı',
          'Keşfetme tutkusu',
          'Çeşitli deneyimler',
          'Mental stimülasyon',
        ],
        challenges: [
          'Dikkat dağınıklığı',
          'Tutarsızlık riski',
          'Aşırı stimülasyon',
        ],
        parentingTips: [
          'Çeşitli aktiviteler sunun',
          'Açık hava deneyimlerini artırın',
          'Dil gelişimini destekleyin',
          'Macera dolu oyunlar organize edin',
        ],
        communicationTips: [
          'Hikayeler anlatın',
          'Sorular sorun ve yanıtlayın',
          'Farklı konular hakkında konuşun',
        ],
        dailyAdvice:
            'Bugün bebeğinizle yeni bir şeyler öğrenmek için zaman ayırın.',
        monthlyForecast:
            'Bu ay bebeğinizin dil becerilerinde hızlı gelişme gözlenebilir.',
        createdAt: now,
      ),
    ]);

    return compatibilities;
  }

  // Belirli burç kombinasyonu için uyumluluk bulma
  static ZodiacCompatibility? findCompatibility(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    List<ZodiacCompatibility> allCompatibilities = getAllCompatibilities();

    try {
      return allCompatibilities.firstWhere(
        (compatibility) =>
            compatibility.motherSign == motherSign &&
            compatibility.babySign == babySign,
      );
    } catch (e) {
      // Eğer önceden tanımlanmış uyumluluk yoksa, dinamik oluştur
      return _generateDynamicCompatibility(motherSign, babySign);
    }
  }

  // Dinamik uyumluluk oluşturma
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
      compatibilityDescription: _generateDescription(
        motherSign,
        babySign,
        score,
      ),
      strengths: _generateStrengths(motherSign, babySign),
      challenges: _generateChallenges(motherSign, babySign),
      parentingTips: _generateParentingTips(motherSign, babySign),
      communicationTips: _generateCommunicationTips(motherSign, babySign),
      createdAt: DateTime.now(),
    );
  }

  // Uyumluluk puanı hesaplama
  static int _calculateCompatibilityScore(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Element uyumluluğu
    ZodiacElement motherElement = _getElementForSign(motherSign);
    ZodiacElement babyElement = _getElementForSign(babySign);

    int baseScore = 5; // Temel puan

    // Aynı element = +3 puan
    if (motherElement == babyElement) {
      baseScore += 3;
    }
    // Uyumlu elementler = +2 puan
    else if (_areElementsCompatible(motherElement, babyElement)) {
      baseScore += 2;
    }
    // Zıt elementler = +1 puan (tamamlayıcı)
    else if (_areElementsOpposite(motherElement, babyElement)) {
      baseScore += 1;
    }

    // Burç özellikleri bonus
    if (motherSign == babySign) {
      baseScore += 2; // Aynı burç ekstra uyum
    }

    return baseScore.clamp(1, 10);
  }

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

  static bool _areElementsCompatible(
    ZodiacElement element1,
    ZodiacElement element2,
  ) {
    return (element1 == ZodiacElement.fire && element2 == ZodiacElement.air) ||
        (element1 == ZodiacElement.air && element2 == ZodiacElement.fire) ||
        (element1 == ZodiacElement.earth && element2 == ZodiacElement.water) ||
        (element1 == ZodiacElement.water && element2 == ZodiacElement.earth);
  }

  static bool _areElementsOpposite(
    ZodiacElement element1,
    ZodiacElement element2,
  ) {
    return (element1 == ZodiacElement.fire &&
            element2 == ZodiacElement.water) ||
        (element1 == ZodiacElement.water && element2 == ZodiacElement.fire) ||
        (element1 == ZodiacElement.earth && element2 == ZodiacElement.air) ||
        (element1 == ZodiacElement.air && element2 == ZodiacElement.earth);
  }

  static CompatibilityLevel _getCompatibilityLevel(int score) {
    if (score >= 9) return CompatibilityLevel.excellent;
    if (score >= 7) return CompatibilityLevel.veryGood;
    if (score >= 5) return CompatibilityLevel.good;
    if (score >= 3) return CompatibilityLevel.moderate;
    return CompatibilityLevel.challenging;
  }

  static String _generateDescription(
    ZodiacSign motherSign,
    ZodiacSign babySign,
    int score,
  ) {
    String motherName = _getZodiacDisplayName(motherSign);
    String babyName = _getZodiacDisplayName(babySign);

    if (score >= 8) {
      return '$motherName anne ve $babyName bebek - Harika bir uyum! Doğal bir anlayış yaşayacaksınız.';
    } else if (score >= 6) {
      return '$motherName anne ve $babyName bebek - İyi bir uyum. Biraz çaba ile mükemmel ilişki.';
    } else if (score >= 4) {
      return '$motherName anne ve $babyName bebek - Orta seviye uyum. Öğrenecek çok şey var.';
    } else {
      return '$motherName anne ve $babyName bebek - Zorlu ama öğretici bir kombinasyon.';
    }
  }

  static String _getZodiacDisplayName(ZodiacSign sign) {
    switch (sign) {
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

  static List<String> _generateStrengths(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Genel güçlü yanlar
    return [
      'Doğal anne-bebek bağı',
      'Karşılıklı öğrenme fırsatı',
      'Benzersiz kişilik gelişimi',
      'Güçlü duygusal bağlantı',
    ];
  }

  static List<String> _generateChallenges(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Genel zorluklar
    return [
      'Farklı ihtiyaçları anlama',
      'Sabır gerektiren durumlar',
      'Uyum sağlama süreci',
    ];
  }

  static List<String> _generateParentingTips(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Genel ebeveynlik önerileri
    return [
      'Bebeğinizin doğal özelliklerini gözlemleyin',
      'Sabırlı ve anlayışlı yaklaşım benimseyin',
      'Kendi burç özelliklerinizi dengeleyin',
      'Sevgiyi gösterme yollarınızı çeşitlendirin',
    ];
  }

  static List<String> _generateCommunicationTips(
    ZodiacSign motherSign,
    ZodiacSign babySign,
  ) {
    // Genel iletişim önerileri
    return [
      'Duygularınızı açık şekilde ifade edin',
      'Bebeğinizin tepkilerini gözlemleyin',
      'Tutarlı iletişim tarzı benimseyin',
      'Fiziksel teması ihmal etmeyin',
    ];
  }

  // Uyumluluk raporunu metin olarak döndürme
  static String generateCompatibilityReport(ZodiacCompatibility compatibility) {
    StringBuffer report = StringBuffer();

    report.writeln('🌟 ${compatibility.compatibilityTitle}');
    report.writeln(
      '📊 Uyumluluk Puanı: ${compatibility.compatibilityScore}/10 (${compatibility.compatibilityLevelDisplayName})',
    );
    report.writeln('💝 ${compatibility.compatibilityDescription}');
    report.writeln('');

    report.writeln('✨ Güçlü Yanlar:');
    report.writeln(compatibility.strengthsText);
    report.writeln('');

    if (compatibility.challenges.isNotEmpty) {
      report.writeln('⚠️ Zorlu Yanlar:');
      report.writeln(compatibility.challengesText);
      report.writeln('');
    }

    if (compatibility.parentingTips.isNotEmpty) {
      report.writeln('👶 Ebeveynlik Önerileri:');
      report.writeln(compatibility.parentingTipsText);
      report.writeln('');
    }

    if (compatibility.communicationTips.isNotEmpty) {
      report.writeln('💬 İletişim İpuçları:');
      report.writeln(compatibility.communicationTipsText);
      report.writeln('');
    }

    if (compatibility.dailyAdvice != null) {
      report.writeln('📅 Günlük Tavsiye:');
      report.writeln(compatibility.dailyAdvice!);
      report.writeln('');
    }

    if (compatibility.monthlyForecast != null) {
      report.writeln('🔮 Aylık Tahmin:');
      report.writeln(compatibility.monthlyForecast!);
    }

    return report.toString();
  }
}
