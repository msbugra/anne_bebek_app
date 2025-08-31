import 'package:json_annotation/json_annotation.dart';
import 'astrological_profile_model.dart';

part 'zodiac_characteristics_model.g.dart';

@JsonSerializable()
class ZodiacCharacteristics {
  final int? id;
  final ZodiacSign zodiacSign;
  final ZodiacElement element;
  final String rulingPlanet; // Yönetici gezegen
  final List<String> positiveTraits; // Olumlu özellikler
  final List<String> challengingTraits; // Dikkat edilecek noktalar
  final List<String> childDevelopmentTips; // Çocuk gelişimi önerileri
  final List<String>
  parentChildCommunicationTips; // Anne-çocuk iletişim ipuçları
  final List<String> earlyChildhoodTips; // Erken çocukluk tavsiyeleri (0-3 yaş)
  final List<String> preschoolTips; // Okul öncesi tavsiyeleri (3-6 yaş)
  final String generalDescription; // Genel açıklama
  final String strengthsDescription; // Güçlü yanlar açıklaması
  final String parentingApproach; // Ebeveynlik yaklaşımı
  final DateTime createdAt;
  final DateTime updatedAt;

  const ZodiacCharacteristics({
    this.id,
    required this.zodiacSign,
    required this.element,
    required this.rulingPlanet,
    this.positiveTraits = const [],
    this.challengingTraits = const [],
    this.childDevelopmentTips = const [],
    this.parentChildCommunicationTips = const [],
    this.earlyChildhoodTips = const [],
    this.preschoolTips = const [],
    required this.generalDescription,
    required this.strengthsDescription,
    required this.parentingApproach,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory ZodiacCharacteristics.fromJson(Map<String, dynamic> json) =>
      _$ZodiacCharacteristicsFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$ZodiacCharacteristicsToJson(this);

  // Factory constructor from database map
  factory ZodiacCharacteristics.fromMap(Map<String, dynamic> map) {
    return ZodiacCharacteristics(
      id: map['id'] as int?,
      zodiacSign: ZodiacSign.values.firstWhere(
        (e) => e.toString().split('.').last == map['zodiac_sign'],
        orElse: () => ZodiacSign.aries,
      ),
      element: ZodiacElement.values.firstWhere(
        (e) => e.toString().split('.').last == map['element'],
        orElse: () => ZodiacElement.fire,
      ),
      rulingPlanet: map['ruling_planet'] as String,
      positiveTraits: map['positive_traits'] != null
          ? List<String>.from(map['positive_traits'].split('|'))
          : [],
      challengingTraits: map['challenging_traits'] != null
          ? List<String>.from(map['challenging_traits'].split('|'))
          : [],
      childDevelopmentTips: map['child_development_tips'] != null
          ? List<String>.from(map['child_development_tips'].split('|'))
          : [],
      parentChildCommunicationTips:
          map['parent_child_communication_tips'] != null
          ? List<String>.from(map['parent_child_communication_tips'].split('|'))
          : [],
      earlyChildhoodTips: map['early_childhood_tips'] != null
          ? List<String>.from(map['early_childhood_tips'].split('|'))
          : [],
      preschoolTips: map['preschool_tips'] != null
          ? List<String>.from(map['preschool_tips'].split('|'))
          : [],
      generalDescription: map['general_description'] as String,
      strengthsDescription: map['strengths_description'] as String,
      parentingApproach: map['parenting_approach'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zodiac_sign': zodiacSign.toString().split('.').last,
      'element': element.toString().split('.').last,
      'ruling_planet': rulingPlanet,
      'positive_traits': positiveTraits.join('|'),
      'challenging_traits': challengingTraits.join('|'),
      'child_development_tips': childDevelopmentTips.join('|'),
      'parent_child_communication_tips': parentChildCommunicationTips.join('|'),
      'early_childhood_tips': earlyChildhoodTips.join('|'),
      'preschool_tips': preschoolTips.join('|'),
      'general_description': generalDescription,
      'strengths_description': strengthsDescription,
      'parenting_approach': parentingApproach,
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

  // Element adını Türkçe olarak döndür
  String get elementDisplayName {
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

  // Olumlu özellikler metin olarak
  String get positiveTraitsText {
    if (positiveTraits.isEmpty) return 'Güçlü kişilik özellikleri';
    return positiveTraits.map((trait) => '• $trait').join('\n');
  }

  // Zorlu özellikler metin olarak
  String get challengingTraitsText {
    if (challengingTraits.isEmpty) return 'Dikkat edilecek özel nokta yok';
    return challengingTraits.map((trait) => '• $trait').join('\n');
  }

  // Çocuk gelişimi önerileri metin olarak
  String get childDevelopmentTipsText {
    if (childDevelopmentTips.isEmpty) return 'Genel gelişim desteği';
    return childDevelopmentTips.map((tip) => '• $tip').join('\n');
  }

  // İletişim ipuçları metin olarak
  String get communicationTipsText {
    if (parentChildCommunicationTips.isEmpty) return 'Doğal iletişim';
    return parentChildCommunicationTips.map((tip) => '• $tip').join('\n');
  }

  // Erken çocukluk önerileri metin olarak
  String get earlyChildhoodTipsText {
    if (earlyChildhoodTips.isEmpty) return 'Genel bakım yeterli';
    return earlyChildhoodTips.map((tip) => '• $tip').join('\n');
  }

  // Okul öncesi önerileri metin olarak
  String get preschoolTipsText {
    if (preschoolTips.isEmpty) return 'Standart okul öncesi hazırlık';
    return preschoolTips.map((tip) => '• $tip').join('\n');
  }

  // Yaşa göre öneri alma
  String getTipsForAge(int ageInMonths) {
    if (ageInMonths <= 36) {
      // 0-3 yaş
      return earlyChildhoodTipsText;
    } else if (ageInMonths <= 72) {
      // 3-6 yaş
      return preschoolTipsText;
    } else {
      // 6+ yaş
      return childDevelopmentTipsText;
    }
  }

  // Copy with method
  ZodiacCharacteristics copyWith({
    int? id,
    ZodiacSign? zodiacSign,
    ZodiacElement? element,
    String? rulingPlanet,
    List<String>? positiveTraits,
    List<String>? challengingTraits,
    List<String>? childDevelopmentTips,
    List<String>? parentChildCommunicationTips,
    List<String>? earlyChildhoodTips,
    List<String>? preschoolTips,
    String? generalDescription,
    String? strengthsDescription,
    String? parentingApproach,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZodiacCharacteristics(
      id: id ?? this.id,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      element: element ?? this.element,
      rulingPlanet: rulingPlanet ?? this.rulingPlanet,
      positiveTraits: positiveTraits ?? this.positiveTraits,
      challengingTraits: challengingTraits ?? this.challengingTraits,
      childDevelopmentTips: childDevelopmentTips ?? this.childDevelopmentTips,
      parentChildCommunicationTips:
          parentChildCommunicationTips ?? this.parentChildCommunicationTips,
      earlyChildhoodTips: earlyChildhoodTips ?? this.earlyChildhoodTips,
      preschoolTips: preschoolTips ?? this.preschoolTips,
      generalDescription: generalDescription ?? this.generalDescription,
      strengthsDescription: strengthsDescription ?? this.strengthsDescription,
      parentingApproach: parentingApproach ?? this.parentingApproach,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZodiacCharacteristics &&
        other.id == id &&
        other.zodiacSign == zodiacSign &&
        other.element == element &&
        other.rulingPlanet == rulingPlanet &&
        other.positiveTraits.toString() == positiveTraits.toString() &&
        other.challengingTraits.toString() == challengingTraits.toString() &&
        other.childDevelopmentTips.toString() ==
            childDevelopmentTips.toString() &&
        other.parentChildCommunicationTips.toString() ==
            parentChildCommunicationTips.toString() &&
        other.earlyChildhoodTips.toString() == earlyChildhoodTips.toString() &&
        other.preschoolTips.toString() == preschoolTips.toString() &&
        other.generalDescription == generalDescription &&
        other.strengthsDescription == strengthsDescription &&
        other.parentingApproach == parentingApproach;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      zodiacSign,
      element,
      rulingPlanet,
      positiveTraits,
      challengingTraits,
      childDevelopmentTips,
      parentChildCommunicationTips,
      earlyChildhoodTips,
      preschoolTips,
      generalDescription,
      strengthsDescription,
      parentingApproach,
    );
  }

  @override
  String toString() {
    return 'ZodiacCharacteristics(zodiacSign: $zodiacSignDisplayName, '
        'element: $elementDisplayName, rulingPlanet: $rulingPlanet)';
  }
}

// Burç özellikleri servisi
class ZodiacCharacteristicsService {
  // Tüm burçların özelliklerini getir
  static List<ZodiacCharacteristics> getAllZodiacCharacteristics() {
    DateTime now = DateTime.now();

    return [
      // KOÇ BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.aries,
        element: ZodiacElement.fire,
        rulingPlanet: 'Mars',
        positiveTraits: [
          'Enerjik ve dinamik',
          'Cesur ve girişimci',
          'Lider ruhu taşır',
          'Hızlı öğrenir',
          'Bağımsız ve özgün',
          'Kararlı ve azimli',
        ],
        challengingTraits: [
          'Sabırsızlık eğilimi',
          'Öfke kontrolü gerekir',
          'Dürtüsel davranış',
          'Dikkat dağınıklığı',
          'Sınır tanımama',
        ],
        childDevelopmentTips: [
          'Fiziksel aktivitelere ağırlık verin',
          'Güvenli sınırlar koyun',
          'Enerjiyi pozitif kanalize edin',
          'Sabır öğretmeye odaklanın',
          'Rekabetçi oyunlar kullanın',
        ],
        parentChildCommunicationTips: [
          'Net ve direkt konuşun',
          'Hızlı karar verme becerisini destekleyin',
          'Liderlik özelliklerini besleyin',
          'Fiziksel sevgi gösterilerini artırın',
        ],
        earlyChildhoodTips: [
          'Bol hareket alanı sağlayın',
          'Güvenlik önlemlerini artırın',
          'Kısa süreli aktiviteler planlayın',
          'Övgü ile motive edin',
        ],
        preschoolTips: [
          'Takım sporlarına yönlendirin',
          'Liderlik rollerini destekleyin',
          'Sabır gerektiren oyunlar oynayın',
          'Sorumluluk vermeye başlayın',
        ],
        generalDescription:
            'Koç burcu çocukları doğuştan lider, enerjik ve cesur kişilerdir. Yeni deneyimlere açık olan bu çocuklar, hızla öğrenir ve büyük hayaller kurarlar.',
        strengthsDescription:
            'Güçlü yanları arasında yüksek enerji, cesaret, hızlı öğrenme ve liderlik becerileri yer alır. Bağımsızlık konusunda erken yaşta beceri gösterirler.',
        parentingApproach:
            'Koç burcu çocukları için tutarlı sınırlar, fiziksel aktivite ve sabır eğitimi çok önemlidir. Enerjilerini doğru yönlendirmek kilit noktadır.',
        createdAt: now,
        updatedAt: now,
      ),

      // BOĞA BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.taurus,
        element: ZodiacElement.earth,
        rulingPlanet: 'Venüs',
        positiveTraits: [
          'Kararlı ve güvenilir',
          'Sakin ve huzurlu',
          'Güçlü hafıza',
          'Sevgi dolu ve şefkatli',
          'Pratik zeka',
          'Sabırlı yaklaşım',
        ],
        challengingTraits: [
          'İnat etme eğilimi',
          'Değişime direnç',
          'Aşırı koruyucu olabilir',
          'Yavaş adaptasyon',
          'Materyalist yaklaşım',
        ],
        childDevelopmentTips: [
          'Rutin ve düzen sağlayın',
          'Dokunsal öğrenmeyi destekleyin',
          'Sabırlı yaklaşım benimseyin',
          'Doğal çevre sunun',
          'Güvenli bağlanma odağı',
        ],
        parentChildCommunicationTips: [
          'Sakin ve tutarlı ton kullanın',
          'Somut örneklerle açıklayın',
          'Fiziksel sevgi gösterileri',
          'Yavaş ve anlaşılır konuşun',
        ],
        earlyChildhoodTips: [
          'Düzenli beslenme saatleri',
          'Yumuşak dokulu oyuncaklar',
          'Sakin uyku ortamı',
          'Rutin aktiviteler',
        ],
        preschoolTips: [
          'El sanatları aktiviteleri',
          'Bahçıvanlık deneyimleri',
          'Müzik ve dans',
          'Yaratıcı oyunlar',
        ],
        generalDescription:
            'Boğa burcu çocukları istikrarlı, güvenilir ve sevgi dolu kişilerdir. Rutinleri seven bu çocuklar, güvenli ortamlarda en iyi gelişimi gösterirler.',
        strengthsDescription:
            'Kararlılık, güvenilirlik, sabır ve güçlü hafıza yetenekleri en belirgin özellikleridir. Pratik zeka ve sevgi dolu yaklaşımları vardır.',
        parentingApproach:
            'Boğa burcu çocukları için istikrarlı rutinler, sabırlı yaklaşım ve dokunsal deneyimler çok önemlidir. Değişiklikleri yavaş ve dikkatli yapın.',
        createdAt: now,
        updatedAt: now,
      ),

      // İKİZLER BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.gemini,
        element: ZodiacElement.air,
        rulingPlanet: 'Merkür',
        positiveTraits: [
          'Çok meraklı ve öğrenmeyi seven',
          'Sosyal ve konuşkan',
          'Hızlı öğrenme yetisi',
          'Yaratıcı ve hayal gücü kuvvetli',
          'Uyum sağlama becerisi',
          'Çok yönlü ilgiler',
        ],
        challengingTraits: [
          'Dikkat dağınıklığı',
          'Kararsızlık eğilimi',
          'Aşırı hareketlilik',
          'Süreklilik zorluğu',
          'Sabırsızlık',
        ],
        childDevelopmentTips: [
          'Çeşitli aktiviteler sunun',
          'Dil gelişimini destekleyin',
          'Sosyal etkileşimi artırın',
          'Mental stimülasyon sağlayın',
          'Kitap okuma alışkanlığı',
        ],
        parentChildCommunicationTips: [
          'Bol konuşun ve dinleyin',
          'Sorularını yanıtlayın',
          'Hikayeler anlatın',
          'Çeşitli konularda sohbet edin',
        ],
        earlyChildhoodTips: [
          'Farklı sesler ve müzikler',
          'Rengarenk oyuncaklar',
          'Konuşmaya teşvik',
          'Sosyal oyunlar',
        ],
        preschoolTips: [
          'Drama ve rol yapma oyunları',
          'Grup aktiviteleri',
          'Dil öğrenme fırsatları',
          'Puzzle ve zeka oyunları',
        ],
        generalDescription:
            'İkizler burcu çocukları çok meraklı, sosyal ve öğrenmeyi seven bireylerdir. Hızla öğrenir ve çevresiyle sürekli etkileşim halinde olmayı severler.',
        strengthsDescription:
            'Güçlü iletişim becerileri, hızlı öğrenme, sosyallik ve adaptasyon yeteneği en önemli özelliklerindendir.',
        parentingApproach:
            'İkizler burcu çocukları için çeşitlilik, mental stimülasyon ve sosyal etkileşim çok önemlidir. Meraklarını desteklemek gerekir.',
        createdAt: now,
        updatedAt: now,
      ),

      // YENGEÇ BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.cancer,
        element: ZodiacElement.water,
        rulingPlanet: 'Ay',
        positiveTraits: [
          'Çok sevgi dolu ve şefkatli',
          'Güçlü sezgilere sahip',
          'Koruyucu ve bakım veren',
          'Duygusal zeka yüksek',
          'Aileye bağlı',
          'Güçlü hafıza',
        ],
        challengingTraits: [
          'Aşırı hassaslık',
          'Mood değişimleri',
          'Aşırı koruyucu olma',
          'İçine kapanma eğilimi',
          'Aşırı duygusallık',
        ],
        childDevelopmentTips: [
          'Güvenli bağlanma odağı',
          'Duygusal desteği artırın',
          'Güven veren rutinler',
          'Yaratıcı ifade fırsatları',
          'Aile bağlarını güçlendirin',
        ],
        parentChildCommunicationTips: [
          'Duygularını dinleyin',
          'Sevgi gösterilerini artırın',
          'Sakin ve anlayışlı olun',
          'Hikaye anlatımı kullanın',
        ],
        earlyChildhoodTips: [
          'Bol sevgi ve şefkat',
          'Güvenli uyku ortamı',
          'Anne kokusu ve sıcaklık',
          'Yumuşak ses tonları',
        ],
        preschoolTips: [
          'Sanatsal aktiviteler',
          'Empati geliştiren oyunlar',
          'Aile fotoğrafları ve anılar',
          'Bakım oyunları (bebek bakımı)',
        ],
        generalDescription:
            'Yengeç burcu çocukları çok sevgi dolu, duygusal ve koruyucu kişilerdir. Güçlü sezgilere sahip olan bu çocuklar, güvenli ortamlarda en iyi gelişimi gösterirler.',
        strengthsDescription:
            'Yüksek duygusal zeka, güçlü sezgiler, sevgi dolu yaklaşım ve koruyucu güdüler en belirgin özellikleridir.',
        parentingApproach:
            'Yengeç burcu çocukları için sevgi, güvenlik ve duygusal destek çok önemlidir. Hassasiyetlerini anlayıp desteklemek gerekir.',
        createdAt: now,
        updatedAt: now,
      ),

      // ASLAN BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.leo,
        element: ZodiacElement.fire,
        rulingPlanet: 'Güneş',
        positiveTraits: [
          'Kendine güveni yüksek',
          'Yaratıcı ve sanatsal yetenek',
          'Cömert ve sevgi dolu',
          'Liderlik özellikleri',
          'Eğlenceli ve neşeli',
          'Güçlü karakter',
        ],
        challengingTraits: [
          'Aşırı gurur',
          'Dikkat arayışı',
          'Egoist davranışlar',
          'Eleştiriye kapalı olma',
          'Dramatik tepkiler',
        ],
        childDevelopmentTips: [
          'Yaratıcılığı destekleyin',
          'Sahne almasına fırsat verin',
          'Övgü ile motive edin',
          'Sanatsal aktiviteler sunun',
          'Liderlik rollerini destekleyin',
        ],
        parentChildCommunicationTips: [
          'Gösterişli övgüler yapın',
          'Sanatsal yeteneklerini destekleyin',
          'Performanslarını izleyin',
          'Pozitif pekiştirme kullanın',
        ],
        earlyChildhoodTips: [
          'Renkli ve parlak oyuncaklar',
          'Müzik ve dans',
          'Alkış ve övgü',
          'Kostüm oyunları',
        ],
        preschoolTips: [
          'Drama ve tiyatro',
          'Müzik dersleri',
          'Sanat etkinlikleri',
          'Gösteriler ve performanslar',
        ],
        generalDescription:
            'Aslan burcu çocukları kendine güveni yüksek, yaratıcı ve performans yeteneği olan bireylerdir. Dikkat çekmeyi ve beğenilmeyi severler.',
        strengthsDescription:
            'Güçlü liderlik, yaratıcılık, kendine güven ve cömert kalp en belirgin özelliklerindendir.',
        parentingApproach:
            'Aslan burcu çocukları için yaratıcı ifade, övgü ve performans fırsatları çok önemlidir. Ego dengelerini korumak gerekir.',
        createdAt: now,
        updatedAt: now,
      ),

      // Diğer burçlar da aynı detayda eklenecek...
      // Kısalık için sadece birkaç örnek veriyorum, gerçek uygulamada tüm 12 burç olmalı

      // BAŞAK BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.virgo,
        element: ZodiacElement.earth,
        rulingPlanet: 'Merkür',
        positiveTraits: [
          'Detaylara dikkat eden',
          'Düzenli ve sistematik',
          'Analitik düşünce',
          'Yardımsever',
          'Mükemmeliyetçi',
          'Sorumlu',
        ],
        challengingTraits: [
          'Aşırı eleştirel',
          'Kaygılı yapı',
          'Mükemmeliyetçilik baskısı',
          'Aşırı detaycılık',
          'Kendine sert olma',
        ],
        childDevelopmentTips: [
          'Organize edilmiş ortam sağlayın',
          'Detay odaklı aktiviteler',
          'Başarıları kutlayın',
          'Sağlıklı yaşam alışkanlıkları',
          'Problem çözme becerileri',
        ],
        parentChildCommunicationTips: [
          'Net talimatlar verin',
          'Mantıklı açıklamalar yapın',
          'Sabırlı ve anlayışlı olun',
          'Başarılarını fark edin',
        ],
        earlyChildhoodTips: [
          'Düzenli günlük program',
          'Temiz ve organize oyun alanı',
          'Küçük parçalı oyuncaklar',
          'Sıralama ve gruplama oyunları',
        ],
        preschoolTips: [
          'El sanatları ve detay işleri',
          'Bahçıvanlık aktiviteleri',
          'Okuma yazmaya hazırlık',
          'Sorumluluk verme',
        ],
        generalDescription:
            'Başak burcu çocukları detaycı, düzenli ve analitik düşünen bireylerdir. Mükemmeliyetçi yapıları ile dikkat çekerler.',
        strengthsDescription:
            'Güçlü analitik düşünce, düzen sevgisi, sorumluluk alma ve yardımseverlik en önemli özelliklerindendir.',
        parentingApproach:
            'Başak burcu çocukları için düzen, sistem ve başarı takdiri çok önemlidir. Mükemmeliyetçilik baskısını dengelemek gerekir.',
        createdAt: now,
        updatedAt: now,
      ),

      // TERAZİ BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.libra,
        element: ZodiacElement.air,
        rulingPlanet: 'Venüs',
        positiveTraits: [
          'Dengeli ve adaletli',
          'Sosyal ve arkadaş canlısı',
          'Estetik duyguları gelişmiş',
          'Diplomasi yeteneği',
          'Barış seven',
          'İş birlikçi',
        ],
        challengingTraits: [
          'Kararsızlık eğilimi',
          'Çatışmadan kaçınma',
          'Aşırı bağımlı olma',
          'Yüzeysel ilişkiler',
          'Tembellik eğilimi',
        ],
        childDevelopmentTips: [
          'Karar verme becerilerini destekleyin',
          'Sosyal aktiviteleri artırın',
          'Estetik deneyimler sunun',
          'İş birliği oyunları',
          'Sanatsal aktiviteler',
        ],
        parentChildCommunicationTips: [
          'Nazik ve sakin yaklaşım',
          'Seçenek sunarak karar verdirin',
          'Güzelliklerini vurgulayın',
          'Sosyal becerileri destekleyin',
        ],
        earlyChildhoodTips: [
          'Estetik oyuncaklar',
          'Müzik ve sanat',
          'Sosyal oyunlar',
          'Rengarenk çevre',
        ],
        preschoolTips: [
          'Grup aktiviteleri',
          'Dans ve müzik',
          'Sanat ve estetik',
          'Arkadaşlık kurma',
        ],
        generalDescription:
            'Terazi burcu çocukları dengeli, sosyal ve estetik duyguları gelişmiş bireylerdir. Adalet duygulari güçlü ve barışçıl yaklaşımlıdırlar.',
        strengthsDescription:
            'Güçlü sosyal beceriler, adalet duygusu, estetik algı ve diplomasi yetenekleri en önemli özelliklerindendir.',
        parentingApproach:
            'Terazi burcu çocukları için sosyal etkileşim, estetik deneyimler ve karar verme desteği çok önemlidir.',
        createdAt: now,
        updatedAt: now,
      ),

      // AKREP BURCU
      ZodiacCharacteristics(
        zodiacSign: ZodiacSign.scorpio,
        element: ZodiacElement.water,
        rulingPlanet: 'Mars/Pluto',
        positiveTraits: [
          'Güçlü irade ve kararlılık',
          'Derin sezgiler',
          'Tutkulu ve bağlı',
          'Araştırma merakı',
          'Cesur ve kararlı',
          'Gizli kalan güçler',
        ],
        challengingTraits: [
          'Kıskançlık eğilimi',
          'İntikam duyguları',
          'Aşırı kuşkuculuk',
          'Gizli saklı davranış',
          'Kontrol etme isteği',
        ],
        childDevelopmentTips: [
          'Güven ortamı oluşturun',
          'Araştırma fırsatları sunun',
          'Duygusal derinliği destekleyin',
          'Sır saklama becerisini geliştirin',
          'Güçlü yanlarını keşfettirin',
        ],
        parentChildCommunicationTips: [
          'Dürüst ve açık olun',
          'Sırlarına saygı gösterin',
          'Derinlemesine konuşmalar yapın',
          'Güven veren yaklaşım benimseyin',
        ],
        earlyChildhoodTips: [
          'Güvenli bağlanma',
          'Sırları olan oyuncaklar',
          'Su oyunları',
          'Sakin ve huzurlu ortam',
        ],
        preschoolTips: [
          'Dedektif oyunları',
          'Gizem ve araştırma',
          'Su ve doğa aktiviteleri',
          'Derin arkadaşlıklar',
        ],
        generalDescription:
            'Akrep burcu çocukları güçlü irade sahibi, sezgileri kuvvetli ve derin duygusal yaşantılara sahip bireylerdir.',
        strengthsDescription:
            'Güçlü irade, derin sezgiler, araştırma merakı ve bağlılık en belirgin özelliklerindendir.',
        parentingApproach:
            'Akrep burcu çocukları için güven, dürüstlük ve duygusal derinlik çok önemlidir. Güçlü yanlarını desteklemek gerekir.',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Belirli burç için özellik bulma
  static ZodiacCharacteristics? findCharacteristics(ZodiacSign zodiacSign) {
    try {
      return getAllZodiacCharacteristics().firstWhere(
        (characteristics) => characteristics.zodiacSign == zodiacSign,
      );
    } catch (e) {
      return null;
    }
  }

  // Yaş grubuna göre tavsiye alma
  static String getAgeSpecificTips(ZodiacSign zodiacSign, int ageInMonths) {
    ZodiacCharacteristics? characteristics = findCharacteristics(zodiacSign);
    if (characteristics == null) {
      return 'Genel çocuk bakımı önerileri uygulayın.';
    }

    return characteristics.getTipsForAge(ageInMonths);
  }

  // Element grubundaki tüm burçları getir
  static List<ZodiacCharacteristics> getCharacteristicsByElement(
    ZodiacElement element,
  ) {
    return getAllZodiacCharacteristics()
        .where((characteristics) => characteristics.element == element)
        .toList();
  }

  // Burç özelliklerini rapor olarak döndür
  static String generateCharacteristicsReport(
    ZodiacCharacteristics characteristics,
  ) {
    StringBuffer report = StringBuffer();

    report.writeln(
      '🌟 ${characteristics.zodiacSignDisplayName} Burcu Özellikleri',
    );
    report.writeln('🌍 Element: ${characteristics.elementDisplayName}');
    report.writeln('🪐 Yönetici Gezegen: ${characteristics.rulingPlanet}');
    report.writeln('');

    report.writeln('📝 Genel Açıklama:');
    report.writeln(characteristics.generalDescription);
    report.writeln('');

    report.writeln('✨ Olumlu Özellikler:');
    report.writeln(characteristics.positiveTraitsText);
    report.writeln('');

    if (characteristics.challengingTraits.isNotEmpty) {
      report.writeln('⚠️ Dikkat Edilecek Noktalar:');
      report.writeln(characteristics.challengingTraitsText);
      report.writeln('');
    }

    report.writeln('💪 Güçlü Yanlar:');
    report.writeln(characteristics.strengthsDescription);
    report.writeln('');

    report.writeln('👶 Çocuk Gelişimi Önerileri:');
    report.writeln(characteristics.childDevelopmentTipsText);
    report.writeln('');

    report.writeln('💬 Anne-Çocuk İletişim İpuçları:');
    report.writeln(characteristics.communicationTipsText);
    report.writeln('');

    report.writeln('🏠 Ebeveynlik Yaklaşımı:');
    report.writeln(characteristics.parentingApproach);

    return report.toString();
  }
}
