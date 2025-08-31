import 'package:json_annotation/json_annotation.dart';
import 'daily_recommendation_model.dart';

part 'weekly_recommendation_model.g.dart';

enum PreschoolAgeGroup {
  @JsonValue('three_years')
  threeYears, // 3-4 yaş
  @JsonValue('four_years')
  fourYears, // 4-5 yaş
}

@JsonSerializable()
class WeeklyRecommendationModel {
  final int? id;
  final int weekNumber; // Hafta numarası (3 yaş sonrasından itibaren)
  final int ageYears; // 3, 4 veya 5
  final RecommendationCategory category;
  final String title;
  final String description;
  final String? details; // Detaylı açıklama
  final String? scientificSource; // Bilimsel kaynak
  final DateTime createdAt;

  const WeeklyRecommendationModel({
    this.id,
    required this.weekNumber,
    required this.ageYears,
    required this.category,
    required this.title,
    required this.description,
    this.details,
    this.scientificSource,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory WeeklyRecommendationModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyRecommendationModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$WeeklyRecommendationModelToJson(this);

  // Factory constructor from database map
  factory WeeklyRecommendationModel.fromMap(Map<String, dynamic> map) {
    return WeeklyRecommendationModel(
      id: map['id'] as int?,
      weekNumber: map['week_number'] as int,
      ageYears: map['age_years'] as int,
      category: RecommendationCategory.values.firstWhere(
        (e) => e.toString().split('.').last == map['category'],
        orElse: () => RecommendationCategory.development,
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      details: map['details'] as String?,
      scientificSource: map['scientific_source'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'week_number': weekNumber,
      'age_years': ageYears,
      'category': category.toString().split('.').last,
      'title': title,
      'description': description,
      'details': details,
      'scientific_source': scientificSource,
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
    if (ageYears == 3) return '3 Yaş';
    if (ageYears == 4) return '4 Yaş';
    if (ageYears == 5) return '5 Yaş';
    return '$ageYears Yaş';
  }

  // Aktiviteler listesi (şimdilik boş liste döndür)
  List<String> get activities => [];

  // Tahmini süre (şimdilik null döndür)
  int? get estimatedDuration => null;

  // Copy with method
  WeeklyRecommendationModel copyWith({
    int? id,
    int? weekNumber,
    int? ageYears,
    RecommendationCategory? category,
    String? title,
    String? description,
    String? details,
    String? scientificSource,
    DateTime? createdAt,
  }) {
    return WeeklyRecommendationModel(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      ageYears: ageYears ?? this.ageYears,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      details: details ?? this.details,
      scientificSource: scientificSource ?? this.scientificSource,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeeklyRecommendationModel &&
        other.id == id &&
        other.weekNumber == weekNumber &&
        other.ageYears == ageYears &&
        other.category == category &&
        other.title == title &&
        other.description == description &&
        other.details == details &&
        other.scientificSource == scientificSource;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      weekNumber,
      ageYears,
      category,
      title,
      description,
      details,
      scientificSource,
    );
  }

  @override
  String toString() {
    return 'WeeklyRecommendationModel(id: $id, weekNumber: $weekNumber, '
        'ageYears: $ageYears, category: $categoryDisplayName, title: $title)';
  }
}

// Haftalık öneriler için servis sınıfı
class WeeklyRecommendationService {
  static List<WeeklyRecommendationModel> generateSampleRecommendations() {
    List<WeeklyRecommendationModel> recommendations = [];
    DateTime now = DateTime.now();

    // 3 yaş için örnek öneriler (ilk 20 hafta)
    for (int week = 1; week <= 20; week++) {
      // Kitap önerisi
      if (week % 6 == 1) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 3,
            category: RecommendationCategory.book,
            title: '3 Yaş Hikaye Kitapları',
            description:
                '$week. haftada basit hikayeli, renkli resimli kitaplar okuyabilirsiniz.',
            details:
                '3 yaşındaki çocuklar basit hikaye yapısını anlamaya başlar. Karakter-olay ilişkisini kurabilen kitaplar tercih edilmelidir.',
            scientificSource:
                'Early Childhood Education Research - Reading Development',
            createdAt: now,
          ),
        );
      }
      // Müzik önerisi
      else if (week % 6 == 2) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 3,
            category: RecommendationCategory.music,
            title: 'Ritim ve Enstrüman Tanıtımı',
            description:
                '$week. haftada basit ritim çalışmaları ve enstrüman seslerini tanıtabilirsiniz.',
            details:
                '3 yaş müzik gelişimi için kritik dönemdir. Farklı ses tonları ve ritimler beyin gelişimini destekler.',
            scientificSource:
                'Journal of Music Education - Preschool Music Development',
            createdAt: now,
          ),
        );
      }
      // Oyun önerisi
      else if (week % 6 == 3) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 3,
            category: RecommendationCategory.game,
            title: 'Rol Yapma Oyunları',
            description:
                '$week. haftada doktor-hasta, öğretmen-öğrenci gibi rol yapma oyunları oynayabilirsiniz.',
            details:
                'Rol yapma oyunları sosyal gelişimi, empati kurma becerisini ve yaratıcılığı destekler.',
            scientificSource:
                'Child Development Journal - Pretend Play Research',
            createdAt: now,
          ),
        );
      }
      // Oyuncak önerisi
      else if (week % 6 == 4) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 3,
            category: RecommendationCategory.toy,
            title: 'İnşa ve Yapı Oyuncakları',
            description:
                '$week. haftada lego, duplo gibi yapı oyuncakları tercih edilebilir.',
            details:
                'Yapı oyuncakları uzamsal zeka, problem çözme becerisi ve el-göz koordinasyonunu geliştirir.',
            scientificSource:
                'Developmental Psychology - Construction Play Benefits',
            createdAt: now,
          ),
        );
      }
      // Aktivite önerisi
      else if (week % 6 == 5) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 3,
            category: RecommendationCategory.activity,
            title: 'Sanat ve El Becerileri',
            description:
                '$week. haftada boyama, kesme-yapıştırma aktiviteleri yapabilirsiniz.',
            details:
                'Sanat aktiviteleri yaratıcılığı geliştirirken ince motor becerilerini de destekler.',
            scientificSource: 'Art Education Research - Fine Motor Development',
            createdAt: now,
          ),
        );
      }
      // Gelişim önerisi
      else {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 3,
            category: RecommendationCategory.development,
            title: 'Dil ve İletişim Gelişimi',
            description:
                '$week. haftada soru-cevap oyunları ve kelime dağarcığını geliştirici etkinlikler yapabilirsiniz.',
            details:
                '3 yaş dil patlaması dönemedir. Aktif dinleme ve konuşma pratiği çok önemlidir.',
            scientificSource:
                'Language Development Research - Preschool Communication',
            createdAt: now,
          ),
        );
      }
    }

    // 4 yaş için örnek öneriler (ilk 15 hafta)
    for (int week = 1; week <= 15; week++) {
      if (week % 5 == 1) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 4,
            category: RecommendationCategory.book,
            title: '4 Yaş Eğitici Kitaplar',
            description:
                '$week. haftada alphabet, sayılar ve temel kavramları içeren kitaplar okuyabilirsiniz.',
            details:
                '4 yaş okul öncesi hazırlık dönemidir. Temel akademik kavramların tanıtımı önemlidir.',
            scientificSource:
                'Preschool Education Research - Pre-Academic Skills',
            createdAt: now,
          ),
        );
      } else if (week % 5 == 2) {
        recommendations.add(
          WeeklyRecommendationModel(
            weekNumber: week,
            ageYears: 4,
            category: RecommendationCategory.game,
            title: 'Grup Oyunları ve İşbirliği',
            description:
                '$week. haftada diğer çocuklarla birlikte oynanan grup oyunları organize edebilirsiniz.',
            details:
                '4 yaş sosyal beceriler açısından kritik dönemdir. Paylaşma ve işbirliği öğrenilir.',
            scientificSource: 'Social Development Research - Cooperative Play',
            createdAt: now,
          ),
        );
      }
    }

    return recommendations;
  }

  // Belirli bir hafta için önerileri getir
  static List<WeeklyRecommendationModel> getRecommendationsForWeek(
    List<WeeklyRecommendationModel> allRecommendations,
    int weekNumber,
    int ageYears,
  ) {
    return allRecommendations
        .where(
          (rec) => rec.weekNumber == weekNumber && rec.ageYears == ageYears,
        )
        .toList();
  }

  // Belirli bir yaş için önerileri getir
  static List<WeeklyRecommendationModel> getRecommendationsByAge(
    List<WeeklyRecommendationModel> allRecommendations,
    int ageYears,
  ) {
    return allRecommendations.where((rec) => rec.ageYears == ageYears).toList();
  }

  // Belirli bir kategori için önerileri getir
  static List<WeeklyRecommendationModel> getRecommendationsByCategory(
    List<WeeklyRecommendationModel> allRecommendations,
    RecommendationCategory category,
  ) {
    return allRecommendations.where((rec) => rec.category == category).toList();
  }
}
