import 'package:json_annotation/json_annotation.dart';

part 'daily_recommendation_model.g.dart';

enum RecommendationCategory {
  @JsonValue('book')
  book,
  @JsonValue('music')
  music,
  @JsonValue('game')
  game,
  @JsonValue('toy')
  toy,
  @JsonValue('activity')
  activity,
  @JsonValue('development')
  development,
}

enum AgeGroup {
  @JsonValue('newborn')
  newborn, // 0-28 gün
  @JsonValue('infant')
  infant, // 29-365 gün
  @JsonValue('toddler')
  toddler, // 366-1095 gün
}

@JsonSerializable()
class DailyRecommendationModel {
  final int? id;
  final int dayNumber; // 1-1095 arası gün numarası
  final RecommendationCategory category;
  final String title;
  final String description;
  final String? details; // Detaylı açıklama
  final String? scientificSource; // Bilimsel kaynak
  final AgeGroup ageGroup;
  final DateTime createdAt;

  const DailyRecommendationModel({
    this.id,
    required this.dayNumber,
    required this.category,
    required this.title,
    required this.description,
    this.details,
    this.scientificSource,
    required this.ageGroup,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory DailyRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRecommendationModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$DailyRecommendationModelToJson(this);

  // Factory constructor from database map
  factory DailyRecommendationModel.fromMap(Map<String, dynamic> map) {
    return DailyRecommendationModel(
      id: map['id'] as int?,
      dayNumber: map['day_number'] as int,
      category: RecommendationCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => RecommendationCategory.development,
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      details: map['details'] as String?,
      scientificSource: map['scientific_source'] as String?,
      ageGroup: AgeGroup.values.firstWhere(
        (e) => e.toString().split('.').last == map['age_group'],
        orElse: () => AgeGroup.infant,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_number': dayNumber,
      'category': category.toString().split('.').last,
      'title': title,
      'description': description,
      'details': details,
      'scientific_source': scientificSource,
      'age_group': ageGroup.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Kategori adını Türkçe olarak döndür
  String get categoryDisplayName {
    switch (category) {
      case RecommendationCategory.book:
        return 'Kitap';
      case RecommendationCategory.music:
        return 'Müzik';
      case RecommendationCategory.game:
        return 'Oyun';
      case RecommendationCategory.toy:
        return 'Oyuncak';
      case RecommendationCategory.activity:
        return 'Aktivite';
      case RecommendationCategory.development:
        return 'Gelişim';
    }
  }

  // Yaş grubu adını Türkçe olarak döndür
  String get ageGroupDisplayName {
    switch (ageGroup) {
      case AgeGroup.newborn:
        return 'Yenidoğan (0-28 gün)';
      case AgeGroup.infant:
        return 'Bebek (1-12 ay)';
      case AgeGroup.toddler:
        return 'Çocuk (1-3 yaş)';
    }
  }

  // Faydalar listesi (şimdilik boş liste döndür)
  List<String> get benefits => [];

  // Kaynak bilgisi
  String? get source => scientificSource;

  // Gün numarasından yaş grubunu otomatik belirle
  static AgeGroup getAgeGroupFromDay(int dayNumber) {
    if (dayNumber <= 28) return AgeGroup.newborn;
    if (dayNumber <= 365) return AgeGroup.infant;
    return AgeGroup.toddler;
  }

  // Copy with method
  DailyRecommendationModel copyWith({
    int? id,
    int? dayNumber,
    RecommendationCategory? category,
    String? title,
    String? description,
    String? details,
    String? scientificSource,
    AgeGroup? ageGroup,
    DateTime? createdAt,
  }) {
    return DailyRecommendationModel(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      details: details ?? this.details,
      scientificSource: scientificSource ?? this.scientificSource,
      ageGroup: ageGroup ?? this.ageGroup,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyRecommendationModel &&
        other.id == id &&
        other.dayNumber == dayNumber &&
        other.category == category &&
        other.title == title &&
        other.description == description &&
        other.details == details &&
        other.scientificSource == scientificSource &&
        other.ageGroup == ageGroup;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      dayNumber,
      category,
      title,
      description,
      details,
      scientificSource,
      ageGroup,
    );
  }

  @override
  String toString() {
    return 'DailyRecommendationModel(id: $id, dayNumber: $dayNumber, '
        'category: $categoryDisplayName, title: $title, '
        'ageGroup: $ageGroupDisplayName)';
  }
}

// Günlük öneriler için servis sınıfı
class DailyRecommendationService {
  static List<DailyRecommendationModel> generateSampleRecommendations() {
    List<DailyRecommendationModel> recommendations = [];
    DateTime now = DateTime.now();

    // Yenidoğan dönemi örnekleri (1-28 gün)
    for (int day = 1; day <= 28; day++) {
      // Kitap önerisi
      if (day % 4 == 1) {
        recommendations.add(
          DailyRecommendationModel(
            dayNumber: day,
            category: RecommendationCategory.book,
            title: 'Yenidoğan için Kontrast Kitaplar',
            description:
                '$day. gününde bebeğinize siyah-beyaz kontrast resimli kitaplar gösterebilirsiniz.',
            details:
                'Yenidoğan bebekler siyah-beyaz kontrastları daha iyi görebilirler. Bu görsel stimülasyon beyin gelişimini destekler.',
            scientificSource:
                'American Academy of Pediatrics - Visual Development Research',
            ageGroup: AgeGroup.newborn,
            createdAt: now,
          ),
        );
      }
      // Müzik önerisi
      else if (day % 4 == 2) {
        recommendations.add(
          DailyRecommendationModel(
            dayNumber: day,
            category: RecommendationCategory.music,
            title: 'Klasik Müzik ve Ninni',
            description:
                '$day. gününde sakin klasik müzik veya ninniler çalabilirsiniz.',
            details:
                'Mozart, Vivaldi gibi sakin klasik eserler bebeğin sinir sistemini rahatlatır ve uyku kalitesini artırır.',
            scientificSource:
                'Journal of Music Therapy - Neonatal Music Studies',
            ageGroup: AgeGroup.newborn,
            createdAt: now,
          ),
        );
      }
      // Aktivite önerisi
      else if (day % 4 == 3) {
        recommendations.add(
          DailyRecommendationModel(
            dayNumber: day,
            category: RecommendationCategory.activity,
            title: 'Tummy Time Başlangıcı',
            description:
                '$day. gününde günde 2-3 dakika karın üstü pozisyonu deneyebilirsiniz.',
            details:
                'Karın üstü pozisyonu boyun kaslarını güçlendirir ve düz kafa sendromunun önlenmesine yardımcı olur.',
            scientificSource: 'Pediatrics Journal - Tummy Time Guidelines',
            ageGroup: AgeGroup.newborn,
            createdAt: now,
          ),
        );
      }
      // Gelişim önerisi
      else {
        recommendations.add(
          DailyRecommendationModel(
            dayNumber: day,
            category: RecommendationCategory.development,
            title: 'Göz Teması ve Konuşma',
            description:
                '$day. gününde bebeğinizle göz teması kurarak sakin bir sesle konuşun.',
            details:
                'Göz teması sosyal bağlanmayı güçlendirir, konuşma ise dil gelişiminin temellerini atar.',
            scientificSource:
                'Child Development Research - Early Communication',
            ageGroup: AgeGroup.newborn,
            createdAt: now,
          ),
        );
      }
    }

    return recommendations;
  }

  // Belirli bir gün için önerileri getir
  static List<DailyRecommendationModel> getRecommendationsForDay(
    List<DailyRecommendationModel> allRecommendations,
    int dayNumber,
  ) {
    return allRecommendations
        .where((rec) => rec.dayNumber == dayNumber)
        .toList();
  }

  // Belirli bir kategori için önerileri getir
  static List<DailyRecommendationModel> getRecommendationsByCategory(
    List<DailyRecommendationModel> allRecommendations,
    RecommendationCategory category,
  ) {
    return allRecommendations.where((rec) => rec.category == category).toList();
  }

  // Yaş grubuna göre önerileri getir
  static List<DailyRecommendationModel> getRecommendationsByAgeGroup(
    List<DailyRecommendationModel> allRecommendations,
    AgeGroup ageGroup,
  ) {
    return allRecommendations.where((rec) => rec.ageGroup == ageGroup).toList();
  }
}
