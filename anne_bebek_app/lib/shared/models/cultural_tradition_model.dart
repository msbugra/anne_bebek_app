import 'package:json_annotation/json_annotation.dart';

part 'cultural_tradition_model.g.dart';

enum CulturalOrigin {
  @JsonValue('turkish')
  turkish, // Türk
  @JsonValue('world')
  world, // Dünya
}

enum TraditionCategory {
  @JsonValue('birth_traditions')
  birthTraditions, // Doğum gelenekleri
  @JsonValue('naming_ceremonies')
  namingCeremonies, // İsim koyma törenleri
  @JsonValue('nutrition_traditions')
  nutritionTraditions, // Beslenme gelenekleri
  @JsonValue('education_teaching')
  educationTeaching, // Eğitim ve öğretim
  @JsonValue('games_entertainment')
  gamesEntertainment, // Oyun ve eğlence
  @JsonValue('religious_spiritual')
  religiousSpiritual, // Dini/manevi törenler
}

enum AgeRange {
  @JsonValue('pregnancy')
  pregnancy, // Hamilelik dönemi
  @JsonValue('newborn')
  newborn, // Yenidoğan (0-28 gün)
  @JsonValue('infant')
  infant, // Bebek (0-12 ay)
  @JsonValue('toddler')
  toddler, // Küçük çocuk (1-3 yaş)
  @JsonValue('preschool')
  preschool, // Okul öncesi (3-6 yaş)
  @JsonValue('all_ages')
  allAges, // Tüm yaşlar
}

@JsonSerializable()
class CulturalTraditionModel {
  final int? id;
  final String title;
  final String description;
  final String? history;
  final String? howToApply;
  final String importance;
  final CulturalOrigin origin;
  final TraditionCategory category;
  final AgeRange ageRange;
  final String? imageUrl;
  final String? source;
  final DateTime createdAt;

  const CulturalTraditionModel({
    this.id,
    required this.title,
    required this.description,
    this.history,
    this.howToApply,
    required this.importance,
    required this.origin,
    required this.category,
    required this.ageRange,
    this.imageUrl,
    this.source,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory CulturalTraditionModel.fromJson(Map<String, dynamic> json) =>
      _$CulturalTraditionModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$CulturalTraditionModelToJson(this);

  // Factory constructor from database map
  factory CulturalTraditionModel.fromMap(Map<String, dynamic> map) {
    return CulturalTraditionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      history: map['history'] as String?,
      howToApply: map['how_to_apply'] as String?,
      importance: map['importance'] as String,
      origin: CulturalOrigin.values.firstWhere(
        (e) => e.toString().split('.').last == map['origin'],
        orElse: () => CulturalOrigin.turkish,
      ),
      category: TraditionCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => TraditionCategory.birthTraditions,
      ),
      ageRange: AgeRange.values.firstWhere(
        (e) => e.toString().split('.').last == map['age_range'],
        orElse: () => AgeRange.allAges,
      ),
      imageUrl: map['image_url'] as String?,
      source: map['source'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'history': history,
      'how_to_apply': howToApply,
      'importance': importance,
      'origin': origin.toString().split('.').last,
      'category': category.toString().split('.').last,
      'age_range': ageRange.toString().split('.').last,
      'image_url': imageUrl,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Kültürel köken Türkçe açıklaması
  String get originDisplayName {
    switch (origin) {
      case CulturalOrigin.turkish:
        return 'Türk Kültürü';
      case CulturalOrigin.world:
        return 'Dünya Kültürleri';
    }
  }

  // Kategori Türkçe açıklaması
  String get categoryDisplayName {
    switch (category) {
      case TraditionCategory.birthTraditions:
        return 'Doğum Gelenekleri';
      case TraditionCategory.namingCeremonies:
        return 'İsim Koyma Törenleri';
      case TraditionCategory.nutritionTraditions:
        return 'Beslenme Gelenekleri';
      case TraditionCategory.educationTeaching:
        return 'Eğitim ve Öğretim';
      case TraditionCategory.gamesEntertainment:
        return 'Oyun ve Eğlence';
      case TraditionCategory.religiousSpiritual:
        return 'Dini/Manevi Törenler';
    }
  }

  // Yaş aralığı Türkçe açıklaması
  String get ageRangeDisplayName {
    switch (ageRange) {
      case AgeRange.pregnancy:
        return 'Hamilelik Dönemi';
      case AgeRange.newborn:
        return 'Yenidoğan (0-28 gün)';
      case AgeRange.infant:
        return 'Bebek (0-12 ay)';
      case AgeRange.toddler:
        return 'Küçük Çocuk (1-3 yaş)';
      case AgeRange.preschool:
        return 'Okul Öncesi (3-6 yaş)';
      case AgeRange.allAges:
        return 'Tüm Yaşlar';
    }
  }

  // Copy with method
  CulturalTraditionModel copyWith({
    int? id,
    String? title,
    String? description,
    String? history,
    String? howToApply,
    String? importance,
    CulturalOrigin? origin,
    TraditionCategory? category,
    AgeRange? ageRange,
    String? imageUrl,
    String? source,
    DateTime? createdAt,
  }) {
    return CulturalTraditionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      history: history ?? this.history,
      howToApply: howToApply ?? this.howToApply,
      importance: importance ?? this.importance,
      origin: origin ?? this.origin,
      category: category ?? this.category,
      ageRange: ageRange ?? this.ageRange,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CulturalTraditionModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.history == history &&
        other.howToApply == howToApply &&
        other.importance == importance &&
        other.origin == origin &&
        other.category == category &&
        other.ageRange == ageRange &&
        other.imageUrl == imageUrl &&
        other.source == source;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      history,
      howToApply,
      importance,
      origin,
      category,
      ageRange,
      imageUrl,
      source,
    );
  }

  @override
  String toString() {
    return 'CulturalTraditionModel(id: $id, title: $title, '
        'origin: $originDisplayName, category: $categoryDisplayName, '
        'ageRange: $ageRangeDisplayName)';
  }
}

// Kültürel gelenekler servisi ve örnek veriler
class CulturalTraditionService {
  // Türk gelenekleri örnekleri (20+ örnek)
  static List<CulturalTraditionModel> getTurkishTraditionSamples() {
    DateTime now = DateTime.now();

    return [
      // Doğum Gelenekleri
      CulturalTraditionModel(
        title: 'Lohusalık Dönemi',
        description:
            'Doğumdan sonra annenin 40 gün boyunca özel bakım görmesi geleneği',
        history:
            'Osmanlı döneminden günümüze kadar süregelen bu gelenek, annenin fiziksel ve ruhsal olarak iyileşmesi için uygulanır.',
        howToApply:
            'Anne 40 gün boyunca ağır işler yapmaz, beslenme programı düzenlenir, ziyaretçiler sınırlandırılır.',
        importance:
            'Annenin sağlığını korumak ve bebekle bağ kurmasına yardımcı olmak için kritik öneme sahiptir.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.newborn,
        source: 'Türk Halk Kültürü Araştırmaları',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Göbek Bağı Töreni',
        description:
            'Bebeğin göbek bağının anlamlı bir yerde gömülmesi geleneği',
        history:
            'Türk kültüründe bebeğin gelecekte o yere bağlı kalması için göbek bağı özel yerlere gömülür.',
        howToApply:
            'Göbek bağı genellikle okul bahçelerine, camii avlularına veya kutsal sayılan yerlere gömülür.',
        importance:
            'Çocuğun eğitime ve maneviyata olan bağlılığını sembolize eder.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.newborn,
        source: 'Anadolu Halk İnanışları',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Mevlit Okutma',
        description:
            'Bebeğin doğumunu kutlamak için mevlit okutulması geleneği',
        history:
            'İslam kültüründe Hz. Muhammed\'in doğumunu anlatan mevlidin okutulması ile bebeğin hayırlı bir yaşam sürmesi dua edilir.',
        howToApply:
            'Doğumdan sonraki ilk haftalarda yakın akraba ve komşular davet edilerek mevlit okutulur.',
        importance:
            'Bebeğin manevi açıdan korunması ve hayırlı bir yaşam sürmesi için dua edilir.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.newborn,
        source: 'İslami Gelenekler',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Diş Buğdayı',
        description: 'Bebeğin ilk dişi çıktığında yapılan kutlama töreni',
        history:
            'Anadolu\'da yüzyıllardır süregelen bu gelenek, bebeğin sağlıklı büyümesini kutlamak için yapılır.',
        howToApply:
            'Buğday haşlanır, üzerine şeker, badem, fındık konur. Komşulara ve akrabalara dağıtılır.',
        importance:
            'Bebeğin gelişimindeki önemli bir aşamayı kutlar ve bereket diler.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.infant,
        source: 'Anadolu Gelenekleri',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'İlk Adım Töreni',
        description: 'Bebeğin ilk adımını attığında yapılan sembolik tören',
        history:
            'Çocuğun ayaklarına ip bağlanır ve ip kesilerek çocuğun önündeki engellerin kalkması dua edilir.',
        howToApply:
            'Çocuğun ayaklarına renkli ip bağlanır, aile büyükleri tarafından ip kesilerek dua edilir.',
        importance:
            'Çocuğun hayatta karşılaşacağı zorluklarla başa çıkabilmesi için sembolik bir destek sağlar.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.toddler,
        source: 'Türk Halk İnanışları',
        createdAt: now,
      ),

      // İsim Koyma Törenleri
      CulturalTraditionModel(
        title: 'Kulak Verme',
        description: 'Yenidoğan bebeğin kulağına ezan okuma geleneği',
        history:
            'İslam geleneğine göre bebeğin sağ kulağına ezan, sol kulağına kamet okunur.',
        howToApply:
            'Bebek dünyaya gelir gelmez veya ilk günlerde kulağına ezan ve kamet okunur.',
        importance:
            'Bebeğin dünyada duyduğu ilk sözlerin kutsallığını vurgular.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.namingCeremonies,
        ageRange: AgeRange.newborn,
        source: 'İslami Gelenekler',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'İsim Koyma Töreni',
        description: 'Bebeğin adının resmi olarak konulduğu tören',
        history:
            'İslam geleneğinde bebeğe isim koymak için özel dualar okunur ve aile büyükleri katılır.',
        howToApply:
            '7. gün yapılan törende imam veya aile büyüğü tarafından bebeğe isim konur, dua edilir.',
        importance:
            'Bebeğin kimlik kazanması ve aileye resmen katılması anlamına gelir.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.namingCeremonies,
        ageRange: AgeRange.newborn,
        source: 'İslami Adab',
        createdAt: now,
      ),

      // Beslenme Gelenekleri
      CulturalTraditionModel(
        title: 'İlk Kaşık Töreni',
        description: 'Bebeğin ek gıdaya geçişinde yapılan sembolik tören',
        history:
            'Türk kültüründe bebeğin ilk kaşık yemeği önemli bir geçiş ritüeli olarak kutlanır.',
        howToApply:
            'Altın veya gümüş kaşıkla bebeğe ilk yemek verilir, aile büyükleri dua eder.',
        importance:
            'Bebeğin büyüme sürecindeki önemli bir dönüm noktasını işaret eder.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.nutritionTraditions,
        ageRange: AgeRange.infant,
        source: 'Türk Mutfak Kültürü',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Bal Yalama',
        description: 'Yenidoğan bebeğin damağına bal sürülmesi geleneği',
        history:
            'Bebeğin tatlı dilli olması ve hayatının tatlı geçmesi için damağına bal sürülür.',
        howToApply:
            'Temiz parmak veya pamuk çubuğu ile bebeğin damağına az miktarda bal sürülür.',
        importance:
            'Bebeğin konuşma yeteneğinin gelişmesi ve tatlı sözlü olması için yapılır.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.nutritionTraditions,
        ageRange: AgeRange.newborn,
        source: 'Anadolu Halk İnanışları',
        createdAt: now,
      ),

      // Eğitim ve Öğretim
      CulturalTraditionModel(
        title: 'Besmele Çekme Töreni',
        description: 'Çocuğun eğitime başlamasını kutlama töreni',
        history: 'Çocuğun okuma yazmaya başladığı ilk gün yapılan özel tören.',
        howToApply:
            'Çocuk güzel kıyafetler giydirilir, elindeki taş üzerine besmele yazılır.',
        importance:
            'Çocuğun eğitim hayatının bereketli başlaması için yapılır.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.educationTeaching,
        ageRange: AgeRange.preschool,
        source: 'Osmanlı Eğitim Gelenekleri',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Eline Altın Verme',
        description: 'İlk kelimeyi söyleyen bebeğe altın verme geleneği',
        history:
            'Çocuğun ilk anlamlı kelimesini söylediğinde eline altın para verilir.',
        howToApply:
            'Çocuk "anne", "baba" gibi ilk kelimesini söylediğinde avucuna altın konur.',
        importance:
            'Çocuğun konuşma gelişimini teşvik eder ve bereketli olması dua edilir.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.educationTeaching,
        ageRange: AgeRange.infant,
        source: 'Türk Aile Gelenekleri',
        createdAt: now,
      ),

      // Oyun ve Eğlence
      CulturalTraditionModel(
        title: 'Kırk Basması',
        description: 'Bebeğin 40 günlük olduğunda yapılan hamam töreni',
        history:
            'Bebeğin 40. gününde hamamda yıkanması ve nazardan korunması için yapılan tören.',
        howToApply:
            'Bebek 40. gününde hamamda özel ritüellerle yıkanır, nazarlık takılır.',
        importance:
            'Bebeğin nazardan korunması ve sosyalleşmeye başlaması için yapılır.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.newborn,
        source: 'Hamam Kültürü',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Beşik Düzenme',
        description: 'Yenidoğan için beşik hazırlama ve kutlama töreni',
        history:
            'Bebeğin beşiği özel olarak süslenir ve aile dostları davet edilir.',
        howToApply:
            'Beşik güzel kumaşlar, nazarlıklar ile süslenir, hediyeler verilir.',
        importance:
            'Bebeğin rahat uyuması ve korunması için yapılan sembolik hazırlık.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.newborn,
        source: 'Türk El Sanatları',
        createdAt: now,
      ),

      // Dini/Manevi Törenler
      CulturalTraditionModel(
        title: 'Sünnet Töreni',
        description: 'Erkek çocukların sünnet edilmesi ve kutlanması',
        history:
            'İslam geleneğine göre erkek çocukların sünnet edilmesi ve büyük törenle kutlanması.',
        howToApply:
            'Çocuk özel kıyafetler giydirilir, sünnet edildikten sonra tören düzenlenir.',
        importance:
            'Çocuğun dini kimlik kazanması ve topluma kabul edilmesi açısından önemli.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.preschool,
        source: 'İslami Gelenekler',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Kurban Kesme',
        description: 'Çocuğun sağlığı için kurban kesme geleneği',
        history:
            'Çocuğun doğumu, hastalıktan kurtulması veya önemli gelişim aşamalarında kurban kesilir.',
        howToApply:
            'Özel günlerde veya şükür için kurban kesilerek yoksullara dağıtılır.',
        importance:
            'Şükran ifade etmek ve çocuğun korunması için yapılan manevi uygulama.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.allAges,
        source: 'İslami Gelenekler',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Nazarlık Takma',
        description: 'Bebeği nazardan korumak için nazarlık takma',
        history:
            'Türk kültüründe mavi boncuk ve nazarlıklar kötü gözden korunmak için kullanılır.',
        howToApply:
            'Bebeğin kıyafetlerine, beşiğine veya odasına nazarlık asılır.',
        importance: 'Bebeği kötü niyetlerden ve nazardan korumak için yapılır.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.allAges,
        source: 'Türk Halk İnanışları',
        createdAt: now,
      ),

      // Ek Türk Gelenekleri
      CulturalTraditionModel(
        title: 'Saç Kesme Töreni',
        description: 'Bebeğin ilk saç kesim töreni ve saçların saklanması',
        history:
            'Çocuğun ilk saçları kesilirken özel dua edilir ve saçlar hatıra olarak saklanır.',
        howToApply:
            'Genellikle 1 yaşında yapılır, kesilen saçlar bez parçasına sarılarak saklanır.',
        importance:
            'Çocuğun güzel ve sağlıklı saçlara sahip olması için yapılır.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.infant,
        source: 'Anadolu Gelenekleri',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Dede-Nine Ziyareti',
        description: 'Yenidoğan bebeğin büyükanne ve büyükbabalara tanıtılması',
        history:
            'Aile büyüklerinin bebeği tanıması ve dualarını alması için yapılan özel ziyaret.',
        howToApply:
            'Bebek doğduktan sonra ilk haftalarda aile büyüklerine götürülür.',
        importance:
            'Aile bağlarının güçlendirilmesi ve büyüklerin duasının alınması.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.newborn,
        source: 'Türk Aile Değerleri',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Hoşgeldin Bebek Ziyafeti',
        description: 'Bebeğin doğumunu kutlamak için verilen ziyafet',
        history:
            'Yakın akraba ve arkadaşlar davet edilerek bebeğin gelmesi kutlanır.',
        howToApply:
            'Doğumdan sonraki ilk haftalar içinde ev sahipliği yapılır, yemek ikram edilir.',
        importance:
            'Toplumsal dayanışmayı güçlendirir ve bebeği sosyal çevreye tanıtır.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.newborn,
        source: 'Türk Misafirperverlik Kültürü',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'Emzik Kesme Töreni',
        description: 'Çocuğun emzik bırakması için yapılan sembolik tören',
        history:
            'Çocuğun büyüdüğünü göstermek için emzik bırakma töreni yapılır.',
        howToApply:
            'Emzik kesilerek çocuğa büyüdüğü anlatılır, hediye verilir.',
        importance:
            'Çocuğun gelişim aşamalarını kutlamak ve büyüme sürecini desteklemek.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.educationTeaching,
        ageRange: AgeRange.toddler,
        source: 'Çocuk Gelişimi Gelenekleri',
        createdAt: now,
      ),

      CulturalTraditionModel(
        title: 'İlk Yürüyüş Kutlaması',
        description: 'Bebeğin bağımsız yürümeye başlamasının kutlanması',
        history:
            'Çocuğun ilk kez bağımsız adım atması aile içinde özel olarak kutlanır.',
        howToApply: 'Çocuğun ilk adımları fotoğraflanır, aile ile paylaşılır.',
        importance: 'Çocuğun motor gelişimindeki önemli aşamayı vurgular.',
        origin: CulturalOrigin.turkish,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.toddler,
        source: 'Modern Türk Aile Gelenekleri',
        createdAt: now,
      ),
    ];
  }

  // Dünya gelenekleri örnekleri (20+ örnek)
  static List<CulturalTraditionModel> getWorldTraditionSamples() {
    DateTime now = DateTime.now();

    return [
      // ABD - Baby Shower
      CulturalTraditionModel(
        title: 'Baby Shower',
        description:
            'Hamilelik döneminde anne adayı için düzenlenen kutlama partisi',
        history:
            'Amerika\'da yaygın olan bu gelenek, bebeğin doğumundan önce anne adayının desteklenmesi amacıyla yapılır.',
        howToApply:
            'Hamileliğin son aylarında arkadaşlar tarafından organize edilir, hediyeler verilir.',
        importance:
            'Anne adayının moral desteği alması ve bebek için gerekli eşyaların hazırlanması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.pregnancy,
        source: 'Amerikan Aile Gelenekleri',
        createdAt: now,
      ),

      // Japonya - Okuizome
      CulturalTraditionModel(
        title: 'Okuizome (İlk Yemek Töreni)',
        description: 'Bebeğin 100. gününde yapılan ilk yemek töreni',
        history:
            'Japon kültüründe bebeğin yaşamı boyunca yiyecek sıkıntısı çekmemesi için yapılan geleneksel tören.',
        howToApply:
            'Bebek 100 günlükken özel yemekler hazırlanır, bebeğin dudaklarına yemek değdirilir.',
        importance:
            'Bebeğin gelecekte bolluk içinde yaşaması için yapılan sembolik tören.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.nutritionTraditions,
        ageRange: AgeRange.infant,
        source: 'Japon Kültürel Gelenekleri',
        createdAt: now,
      ),

      // Çin - Red Eggs
      CulturalTraditionModel(
        title: 'Red Eggs (Kırmızı Yumurta)',
        description:
            'Bebeğin doğumunu kutlamak için kırmızı yumurta dağıtma geleneği',
        history:
            'Çin kültüründe kırmızı renk şans getirici, yumurta ise yeniden doğuşun sembolüdür.',
        howToApply:
            'Bebek doğduktan sonra kırmızıya boyanmış yumurtalar arkadaş ve akrabalara dağıtılır.',
        importance:
            'Bebeğin şanslı ve bereket dolu bir yaşam sürmesi için yapılır.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.newborn,
        source: 'Çin Geleneksel Kültürü',
        createdAt: now,
      ),

      // Hristiyanlık - Baptism
      CulturalTraditionModel(
        title: 'Baptism (Vaftiz Töreni)',
        description: 'Hıristiyan geleneğinde bebeğin vaftiz edilmesi töreni',
        history:
            'İsa\'nın vaftiz edilmesini model alan bu tören, bebeğin Hıristiyan topluma katılması anlamına gelir.',
        howToApply:
            'Kilisede papaz tarafından bebeğin başına su dökülür, dua edilir.',
        importance:
            'Bebeğin ruhsal temizlenmesi ve Hıristiyan kimlik kazanması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.newborn,
        source: 'Hıristiyan Gelenekleri',
        createdAt: now,
      ),

      // Hindistan - Naming Ceremony
      CulturalTraditionModel(
        title: 'Namakaran (İsim Verme Töreni)',
        description: 'Hindu geleneğinde bebeğe isim verme töreni',
        history:
            'Hindu kültüründe bebeğin 11. gününde yapılan kutsal isim verme töreni.',
        howToApply:
            'Aile büyükleri ve din görevlileri katılımıyla bebeğe kutsal isim verilir.',
        importance:
            'Bebeğin ruhsal kimlik kazanması ve topluma kabul edilmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.namingCeremonies,
        ageRange: AgeRange.newborn,
        source: 'Hindu Gelenekleri',
        createdAt: now,
      ),

      // Meksika - Las Mañanitas
      CulturalTraditionModel(
        title: 'Las Mañanitas (Doğum Günü Şarkısı)',
        description: 'Çocuğun doğum gününde söylenen geleneksel şarkı',
        history:
            'Meksika kültüründe doğum günlerinde söylenen özel şarkı geleneği.',
        howToApply:
            'Çocuğun doğum gününde aile ve arkadaşlar tarafından Las Mañanitas şarkısı söylenir.',
        importance:
            'Çocuğun yaşının kutlanması ve aile bağlarının güçlendirilmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.allAges,
        source: 'Meksikan Kültürü',
        createdAt: now,
      ),

      // Fransa - Epiphany
      CulturalTraditionModel(
        title: 'Galette des Rois',
        description: 'Ocak ayında çocuklar için yapılan kral pastası geleneği',
        history:
            'Epifani bayramında çocukları eğlendirmek için özel pasta yapılır.',
        howToApply:
            'Pasta içine küçük figür konur, bulan çocuk o gün kral/kraliçe olur.',
        importance:
            'Çocukların eğlendirilmesi ve aile birlikteliğinin sağlanması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.toddler,
        source: 'Fransız Kültürel Gelenekleri',
        createdAt: now,
      ),

      // Almanya - Schultüte
      CulturalTraditionModel(
        title: 'Schultüte (Okul Konisi)',
        description: 'Çocuğun okula başladığı gün verilen özel hediye konisi',
        history:
            'Almanya\'da çocukların okula başlamasını kutlamak için yapılan gelenek.',
        howToApply:
            'Okula başlayan çocuklara koni şeklinde kutularda hediyeler verilir.',
        importance: 'Çocuğun eğitim hayatının mutlu başlaması için yapılır.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.educationTeaching,
        ageRange: AgeRange.preschool,
        source: 'Alman Eğitim Gelenekleri',
        createdAt: now,
      ),

      // İskoçya - Blessing Way
      CulturalTraditionModel(
        title: 'Blessing Way',
        description: 'Hamile kadın için yapılan destek ve kutlama töreni',
        history:
            'İskoç kültüründe hamile kadınların desteklenmesi için yapılan manevi tören.',
        howToApply:
            'Kadın arkadaşları toplanır, hamile kadın için dua edilir, destek verilir.',
        importance: 'Anne adayının manevi ve duygusal desteğini sağlamak.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.pregnancy,
        source: 'İskoç Gelenekleri',
        createdAt: now,
      ),

      // Brezilya - Chá de Bebê
      CulturalTraditionModel(
        title: 'Chá de Bebê (Bebek Çayı)',
        description: 'Anne adayı için düzenlenen bebek partisi',
        history:
            'Brezilya\'da hamilelik döneminde anne adayı için yapılan kutlama.',
        howToApply:
            'Anne adayının arkadaşları tarafından organize edilir, bebek eşyaları hediye edilir.',
        importance: 'Anne adayının hazırlık sürecinde desteklenmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.birthTraditions,
        ageRange: AgeRange.pregnancy,
        source: 'Brezilya Kültürü',
        createdAt: now,
      ),

      // İspanya - El Bautizo
      CulturalTraditionModel(
        title: 'El Bautizo (İspanyol Vaftizi)',
        description: 'İspanyol Katolik geleneğinde bebek vaftizi',
        history:
            'İspanya\'da geleneksel Katolik vaftiz töreni ve sonrası kutlama.',
        howToApply: 'Kilisede vaftiz sonrası büyük aile ziyafeti düzenlenir.',
        importance:
            'Bebeğin dini kimlik kazanması ve aile birliğinin güçlendirilmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.newborn,
        source: 'İspanyol Katolik Gelenekleri',
        createdAt: now,
      ),

      // Danimarka - Navngivning
      CulturalTraditionModel(
        title: 'Navngivning (İsim Verme)',
        description: 'Danimarka\'da bebeğe resmi isim verme töreni',
        history:
            'Danimarkalı aileler bebeğin ismini resmi olarak kaydetmek için özel tören yapar.',
        howToApply:
            'Belediye binasında veya kilisede yapılan resmi törenle isim tescillenir.',
        importance: 'Bebeğin yasal kimlik kazanması ve topluma kayıt edilmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.namingCeremonies,
        ageRange: AgeRange.newborn,
        source: 'Danimarka Resmi Gelenekleri',
        createdAt: now,
      ),

      // Rusya - Крещение
      CulturalTraditionModel(
        title: 'Kreschenie (Ortodoks Vaftizi)',
        description: 'Rus Ortodoks geleneğinde bebek vaftiz töreni',
        history:
            'Rus Ortodoks Kilisesi geleneğine göre bebeğin vaftiz edilmesi.',
        howToApply:
            'Ortodoks kilisesinde papaz tarafından bebek tamamen suya batırılır.',
        importance: 'Bebeğin Ortodoks Hıristiyan kimliği kazanması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.newborn,
        source: 'Rus Ortodoks Geleneği',
        createdAt: now,
      ),

      // Güney Kore - Doljanchi
      CulturalTraditionModel(
        title: 'Doljanchi (İlk Yaş Kutlaması)',
        description: 'Bebeğin ilk yaş gününde yapılan özel kutlama',
        history:
            'Kore kültüründe bebeğin 1 yaşını kutlama ve gelecek kehaneti yapma töreni.',
        howToApply:
            'Bebek önüne çeşitli objeler konur, hangisini seçtiğine göre geleceği hakkında yorum yapılır.',
        importance:
            'Bebeğin sağlıklı büyüdüğünü kutlamak ve geleceği için iyi dileklerde bulunmak.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.infant,
        source: 'Kore Geleneksel Kültürü',
        createdAt: now,
      ),

      // İrlanda - Irish Blessing
      CulturalTraditionModel(
        title: 'Irish Blessing (İrlanda Duası)',
        description: 'Yenidoğan bebek için özel İrlanda duası',
        history:
            'İrlanda geleneğinde bebeklerin korunması için söylenen özel dualar.',
        howToApply:
            'Aile büyükleri tarafından bebeğe özel İrlanda duaları okunur.',
        importance: 'Bebeğin İrlanda kültürel kimliği kazanması ve korunması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.newborn,
        source: 'İrlanda Kültürel Mirası',
        createdAt: now,
      ),

      // Norveç - Navnedag
      CulturalTraditionModel(
        title: 'Navnedag (İsim Günü)',
        description: 'Çocuğun isminin kutlandığı özel gün',
        history:
            'Norveç kültüründe her ismin takvimde özel bir günü vardır ve o gün kutlanır.',
        howToApply:
            'Çocuğun isminin olduğu takvim gününde küçük kutlama yapılır.',
        importance: 'İsmin ve kişiliğin öneminin vurgulanması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.namingCeremonies,
        ageRange: AgeRange.allAges,
        source: 'Norveç Kültürü',
        createdAt: now,
      ),

      // İtalya - La Befana
      CulturalTraditionModel(
        title: 'La Befana',
        description:
            'Ocak ayında çocuklar için hediye getiren yaşlı kadın geleneği',
        history:
            'İtalyan kültüründe çocuklara hediye getiren iyi cadı hikayesi.',
        howToApply:
            '6 Ocak gecesi çocuklar çoraplarını asır, sabah hediyelerini bulur.',
        importance:
            'Çocukların hayal gücünün geliştirilmesi ve mutlu edilmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.gamesEntertainment,
        ageRange: AgeRange.toddler,
        source: 'İtalyan Folkloru',
        createdAt: now,
      ),

      // Yunanistan - Κολλυβα
      CulturalTraditionModel(
        title: 'Kolyva (Kutlama Buğdayı)',
        description: 'Önemli günlerde hazırlanan özel buğday yemeği',
        history:
            'Yunan Ortodoks geleneğinde özel günlerde hazırlanan sembolik yemek.',
        howToApply:
            'Haşlanmış buğday, şeker, badem ile süslenerek kilisede dağıtılır.',
        importance: 'Bereket ve bolluk sembolü olarak önemli.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.nutritionTraditions,
        ageRange: AgeRange.allAges,
        source: 'Yunan Ortodoks Geleneği',
        createdAt: now,
      ),

      // Avustralya - Welcome to Country
      CulturalTraditionModel(
        title: 'Welcome to Country',
        description:
            'Aborjin geleneğinde yenidoğan bebeği ülkeye hoş geldin deme töreni',
        history:
            'Avustralya aborjin kültüründe yenidoğanların toprağa bağlanma töreni.',
        howToApply:
            'Geleneksel törenle bebek toprağa tanıtılır, atalardan dua istenir.',
        importance: 'Bebeğin toprağa ve kültürüne bağlılığının sağlanması.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.religiousSpiritual,
        ageRange: AgeRange.newborn,
        source: 'Avustralya Aborjin Kültürü',
        createdAt: now,
      ),

      // Kanada - First Nations Naming
      CulturalTraditionModel(
        title: 'First Nations Naming Ceremony',
        description: 'Kanada yerli halkları isim verme töreni',
        history:
            'Kanada\'nın yerli halklarının geleneksel isim verme törenleri.',
        howToApply:
            'Kabile büyükleri tarafından ruhani törenle bebek adını alır.',
        importance:
            'Bebeğin kabile kimliği kazanması ve kültürel bağların güçlenmesi.',
        origin: CulturalOrigin.world,
        category: TraditionCategory.namingCeremonies,
        ageRange: AgeRange.newborn,
        source: 'Kanada First Nations',
        createdAt: now,
      ),
    ];
  }

  // Kategoriye göre gelenekleri filtreleme
  static List<CulturalTraditionModel> getTraditionsByCategory(
    List<CulturalTraditionModel> traditions,
    TraditionCategory category,
  ) {
    return traditions
        .where((tradition) => tradition.category == category)
        .toList();
  }

  // Kültürel köken göre filtreleme
  static List<CulturalTraditionModel> getTraditionsByOrigin(
    List<CulturalTraditionModel> traditions,
    CulturalOrigin origin,
  ) {
    return traditions.where((tradition) => tradition.origin == origin).toList();
  }

  // Yaş aralığına göre filtreleme
  static List<CulturalTraditionModel> getTraditionsByAgeRange(
    List<CulturalTraditionModel> traditions,
    AgeRange ageRange,
  ) {
    return traditions
        .where(
          (tradition) =>
              tradition.ageRange == ageRange ||
              tradition.ageRange == AgeRange.allAges,
        )
        .toList();
  }

  // Bebek yaşına uygun gelenekleri getirme
  static List<CulturalTraditionModel> getTraditionsForBabyAge(
    List<CulturalTraditionModel> traditions,
    int babyAgeInDays,
  ) {
    AgeRange currentAgeRange;

    if (babyAgeInDays <= 28) {
      currentAgeRange = AgeRange.newborn;
    } else if (babyAgeInDays <= 365) {
      currentAgeRange = AgeRange.infant;
    } else if (babyAgeInDays <= 1095) {
      currentAgeRange = AgeRange.toddler;
    } else {
      currentAgeRange = AgeRange.preschool;
    }

    return traditions
        .where(
          (tradition) =>
              tradition.ageRange == currentAgeRange ||
              tradition.ageRange == AgeRange.allAges,
        )
        .toList();
  }

  // Tüm gelenekleri getirme (Türk + Dünya)
  static List<CulturalTraditionModel> getAllTraditions() {
    List<CulturalTraditionModel> allTraditions = [];
    allTraditions.addAll(getTurkishTraditionSamples());
    allTraditions.addAll(getWorldTraditionSamples());
    return allTraditions;
  }

  // Arama fonksiyonu
  static List<CulturalTraditionModel> searchTraditions(
    List<CulturalTraditionModel> traditions,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return traditions;

    String lowercaseQuery = searchQuery.toLowerCase();
    return traditions.where((tradition) {
      return tradition.title.toLowerCase().contains(lowercaseQuery) ||
          tradition.description.toLowerCase().contains(lowercaseQuery) ||
          tradition.categoryDisplayName.toLowerCase().contains(
            lowercaseQuery,
          ) ||
          tradition.originDisplayName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
