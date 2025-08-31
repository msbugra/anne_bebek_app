import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'feeding_tracking_model.g.dart';

enum FeedingType {
  @JsonValue('breast_milk')
  breastMilk, // Anne sütü
  @JsonValue('formula')
  formula, // Mama
  @JsonValue('solid_food')
  solidFood, // Katı gıda
  @JsonValue('mixed')
  mixed, // Karma beslenme
}

enum FormulaType {
  @JsonValue('cow_based')
  cowBased, // İnek sütü bazlı
  @JsonValue('goat_based')
  goatBased, // Keçi sütü bazlı
  @JsonValue('soy_based')
  soyBased, // Soya bazlı
  @JsonValue('hydrolyzed')
  hydrolyzed, // Hidrolize
  @JsonValue('lactose_free')
  lactoseFree, // Laktozsuz
  @JsonValue('hypoallergenic')
  hypoallergenic, // Hipoalerjenik
}

enum BreastSide {
  @JsonValue('left')
  left, // Sol
  @JsonValue('right')
  right, // Sağ
  @JsonValue('both')
  both, // Her ikisi
}

@JsonSerializable()
class SolidFood {
  final String name;
  final double? amount; // gram cinsinden
  final String? unit; // "gram", "kaşık", "adet", vs.

  const SolidFood({required this.name, this.amount, this.unit});

  factory SolidFood.fromJson(Map<String, dynamic> json) =>
      _$SolidFoodFromJson(json);

  Map<String, dynamic> toJson() => _$SolidFoodToJson(this);

  @override
  String toString() =>
      '$name${amount != null ? ' ($amount ${unit ?? "gram"})' : ''}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SolidFood &&
        other.name == name &&
        other.amount == amount &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(name, amount, unit);
}

@JsonSerializable()
class FeedingTrackingModel {
  final int? id;
  final int babyId;
  final DateTime feedingDateTime;
  final FeedingType feedingType;
  final int? durationMinutes; // Emzirme süresi (dakika)
  final double? amountMl; // Mama miktarı (ml)
  final FormulaType? formulaType;
  final BreastSide? breastSide;
  final List<SolidFood>? solidFoods;
  final String? notes;
  final DateTime createdAt;

  const FeedingTrackingModel({
    this.id,
    required this.babyId,
    required this.feedingDateTime,
    required this.feedingType,
    this.durationMinutes,
    this.amountMl,
    this.formulaType,
    this.breastSide,
    this.solidFoods,
    this.notes,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory FeedingTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$FeedingTrackingModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$FeedingTrackingModelToJson(this);

  // For sorting purposes
  DateTime get time => feedingDateTime;

  // Factory constructor from database map
  factory FeedingTrackingModel.fromMap(Map<String, dynamic> map) {
    return FeedingTrackingModel(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      feedingDateTime: DateTime.parse(map['feeding_date_time'] as String),
      feedingType: FeedingType.values.firstWhere(
        (e) => e.toString().split('.').last == map['feeding_type'],
        orElse: () => FeedingType.breastMilk,
      ),
      durationMinutes: map['duration_minutes'] as int?,
      amountMl: map['amount_ml'] as double?,
      formulaType: map['formula_type'] != null
          ? FormulaType.values.firstWhere(
              (e) => e.toString().split('.').last == map['formula_type'],
              orElse: () => FormulaType.cowBased,
            )
          : null,
      breastSide: map['breast_side'] != null
          ? BreastSide.values.firstWhere(
              (e) => e.toString().split('.').last == map['breast_side'],
              orElse: () => BreastSide.both,
            )
          : null,
      solidFoods: map['solid_foods'] != null
          ? (jsonDecode(map['solid_foods'] as String) as List)
                .map((item) => SolidFood.fromJson(item as Map<String, dynamic>))
                .toList()
          : null,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'feeding_date_time': feedingDateTime.toIso8601String(),
      'feeding_type': feedingType.toString().split('.').last,
      'duration_minutes': durationMinutes,
      'amount_ml': amountMl,
      'formula_type': formulaType?.toString().split('.').last,
      'breast_side': breastSide?.toString().split('.').last,
      'solid_foods': solidFoods != null
          ? jsonEncode(solidFoods!.map((food) => food.toJson()).toList())
          : null,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Beslenme türü Türkçe açıklama
  String get feedingTypeDisplayName {
    switch (feedingType) {
      case FeedingType.breastMilk:
        return 'Anne Sütü';
      case FeedingType.formula:
        return 'Mama';
      case FeedingType.solidFood:
        return 'Katı Gıda';
      case FeedingType.mixed:
        return 'Karma Beslenme';
    }
  }

  // Mama türü Türkçe açıklama
  String get formulaTypeDisplayName {
    switch (formulaType) {
      case FormulaType.cowBased:
        return 'İnek Sütü Bazlı';
      case FormulaType.goatBased:
        return 'Keçi Sütü Bazlı';
      case FormulaType.soyBased:
        return 'Soya Bazlı';
      case FormulaType.hydrolyzed:
        return 'Hidrolize';
      case FormulaType.lactoseFree:
        return 'Laktozsuz';
      case FormulaType.hypoallergenic:
        return 'Hipoalerjenik';
      case null:
        return '';
    }
  }

  // Meme tarafı Türkçe açıklama
  String get breastSideDisplayName {
    switch (breastSide) {
      case BreastSide.left:
        return 'Sol';
      case BreastSide.right:
        return 'Sağ';
      case BreastSide.both:
        return 'Her İkisi';
      case null:
        return '';
    }
  }

  // Katı gıda listesi metin olarak
  String get solidFoodsText {
    if (solidFoods == null || solidFoods!.isEmpty) return '';
    return solidFoods!.map((food) => food.toString()).join(', ');
  }

  // Beslenme özeti
  String get feedingSummary {
    String summary = feedingTypeDisplayName;

    if (feedingType == FeedingType.breastMilk && durationMinutes != null) {
      summary += ' - $durationMinutes dakika';
      if (breastSide != null) {
        summary += ' ($breastSideDisplayName)';
      }
    } else if (feedingType == FeedingType.formula && amountMl != null) {
      summary += ' - $amountMl ml';
      if (formulaType != null) {
        summary += ' ($formulaTypeDisplayName)';
      }
    } else if (feedingType == FeedingType.solidFood && solidFoods != null) {
      summary += ' - $solidFoodsText';
    }

    return summary;
  }

  // Günlük beslenme sayısı için date kısmı
  DateTime get feedingDate {
    return DateTime(
      feedingDateTime.year,
      feedingDateTime.month,
      feedingDateTime.day,
    );
  }

  // Validation metodları
  bool get isValidFeeding {
    switch (feedingType) {
      case FeedingType.breastMilk:
        return durationMinutes != null && durationMinutes! > 0;
      case FeedingType.formula:
        return amountMl != null && amountMl! > 0;
      case FeedingType.solidFood:
        return solidFoods != null && solidFoods!.isNotEmpty;
      case FeedingType.mixed:
        return (durationMinutes != null && durationMinutes! > 0) ||
            (amountMl != null && amountMl! > 0) ||
            (solidFoods != null && solidFoods!.isNotEmpty);
    }
  }

  // Copy with method
  FeedingTrackingModel copyWith({
    int? id,
    int? babyId,
    DateTime? feedingDateTime,
    FeedingType? feedingType,
    int? durationMinutes,
    double? amountMl,
    FormulaType? formulaType,
    BreastSide? breastSide,
    List<SolidFood>? solidFoods,
    String? notes,
    DateTime? createdAt,
  }) {
    return FeedingTrackingModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      feedingDateTime: feedingDateTime ?? this.feedingDateTime,
      feedingType: feedingType ?? this.feedingType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      amountMl: amountMl ?? this.amountMl,
      formulaType: formulaType ?? this.formulaType,
      breastSide: breastSide ?? this.breastSide,
      solidFoods: solidFoods ?? this.solidFoods,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedingTrackingModel &&
        other.id == id &&
        other.babyId == babyId &&
        other.feedingDateTime == feedingDateTime &&
        other.feedingType == feedingType &&
        other.durationMinutes == durationMinutes &&
        other.amountMl == amountMl &&
        other.formulaType == formulaType &&
        other.breastSide == breastSide &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      babyId,
      feedingDateTime,
      feedingType,
      durationMinutes,
      amountMl,
      formulaType,
      breastSide,
      notes,
    );
  }

  @override
  String toString() {
    return 'FeedingTrackingModel(id: $id, babyId: $babyId, '
        'feedingDateTime: $feedingDateTime, '
        'feedingSummary: $feedingSummary)';
  }
}

// Beslenme Analizi ve İstatistikler
class FeedingAnalyzer {
  // Günlük beslenme sayısı hesaplama
  static int getDailyFeedingCount(
    List<FeedingTrackingModel> feedings,
    DateTime date,
  ) {
    DateTime targetDate = DateTime(date.year, date.month, date.day);
    return feedings
        .where((feeding) => feeding.feedingDate == targetDate)
        .length;
  }

  // Günlük mama miktarı hesaplama (ml)
  static double getDailyFormulaAmount(
    List<FeedingTrackingModel> feedings,
    DateTime date,
  ) {
    DateTime targetDate = DateTime(date.year, date.month, date.day);
    return feedings
        .where(
          (feeding) =>
              feeding.feedingDate == targetDate &&
              feeding.feedingType == FeedingType.formula &&
              feeding.amountMl != null,
        )
        .fold(0.0, (sum, feeding) => sum + feeding.amountMl!);
  }

  // Günlük emzirme süresi hesaplama (dakika)
  static int getDailyBreastfeedingDuration(
    List<FeedingTrackingModel> feedings,
    DateTime date,
  ) {
    DateTime targetDate = DateTime(date.year, date.month, date.day);
    return feedings
        .where(
          (feeding) =>
              feeding.feedingDate == targetDate &&
              feeding.feedingType == FeedingType.breastMilk &&
              feeding.durationMinutes != null,
        )
        .fold(0, (sum, feeding) => sum + feeding.durationMinutes!);
  }

  // Haftalık beslenme özeti
  static Map<String, dynamic> getWeeklyFeedingSummary(
    List<FeedingTrackingModel> feedings,
    DateTime weekStart,
  ) {
    DateTime weekEnd = weekStart.add(Duration(days: 7));
    List<FeedingTrackingModel> weeklyFeedings = feedings
        .where(
          (feeding) =>
              feeding.feedingDateTime.isAfter(weekStart) &&
              feeding.feedingDateTime.isBefore(weekEnd),
        )
        .toList();

    Map<FeedingType, int> feedingTypeCounts = {};
    double totalFormulaAmount = 0;
    int totalBreastfeedingDuration = 0;

    for (var feeding in weeklyFeedings) {
      feedingTypeCounts[feeding.feedingType] =
          (feedingTypeCounts[feeding.feedingType] ?? 0) + 1;

      if (feeding.feedingType == FeedingType.formula &&
          feeding.amountMl != null) {
        totalFormulaAmount += feeding.amountMl!;
      }

      if (feeding.feedingType == FeedingType.breastMilk &&
          feeding.durationMinutes != null) {
        totalBreastfeedingDuration += feeding.durationMinutes!;
      }
    }

    return {
      'totalFeedings': weeklyFeedings.length,
      'avgDailyFeedings': weeklyFeedings.length / 7,
      'feedingTypeCounts': feedingTypeCounts,
      'totalFormulaAmount': totalFormulaAmount,
      'avgDailyFormulaAmount': totalFormulaAmount / 7,
      'totalBreastfeedingDuration': totalBreastfeedingDuration,
      'avgDailyBreastfeedingDuration': totalBreastfeedingDuration / 7,
    };
  }

  // Beslenme önerileri
  static List<String> getFeedingRecommendations(
    List<FeedingTrackingModel> recentFeedings,
    int babyAgeInDays,
  ) {
    List<String> recommendations = [];

    if (recentFeedings.isEmpty) {
      recommendations.add('Beslenme kayıtlarını düzenli tutmaya başlayın.');
      return recommendations;
    }

    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    int dailyFeedingCount = getDailyFeedingCount(recentFeedings, yesterday);

    // Yaş grubuna göre öneriler
    if (babyAgeInDays <= 30) {
      // Yenidoğan
      if (dailyFeedingCount < 8) {
        recommendations.add('Yenidoğanlar günde 8-12 kez beslenmeli.');
      }
      recommendations.add('İlk 6 ay sadece anne sütü veya mama ile beslenin.');
    } else if (babyAgeInDays <= 180) {
      // 0-6 ay
      if (dailyFeedingCount < 6) {
        recommendations.add('6 aya kadar bebekler günde 6-8 kez beslenmeli.');
      }
      recommendations.add('6. aydan itibaren ek gıdalara başlayabilirsiniz.');
    } else if (babyAgeInDays <= 365) {
      // 6-12 ay
      bool hasSolidFood = recentFeedings.any(
        (f) => f.feedingType == FeedingType.solidFood,
      );
      if (!hasSolidFood) {
        recommendations.add('6 ay sonrasında katı gıdalar eklenmelidir.');
      }
      if (dailyFeedingCount < 4) {
        recommendations.add('6-12 ay arası bebekler günde 4-6 kez beslenmeli.');
      }
    } else {
      // 12+ ay
      recommendations.add('Çeşitli ve dengeli beslenmeye odaklanın.');
      recommendations.add('Aile yemeklerine uyum sağlamaya başlayın.');
    }

    // Beslenme düzeni önerileri
    DateTime now = DateTime.now();
    List<FeedingTrackingModel> todayFeedings = recentFeedings
        .where((f) => f.feedingDate == DateTime(now.year, now.month, now.day))
        .toList();

    if (todayFeedings.isNotEmpty) {
      todayFeedings.sort(
        (a, b) => a.feedingDateTime.compareTo(b.feedingDateTime),
      );
      DateTime lastFeeding = todayFeedings.last.feedingDateTime;
      int hoursSinceLastFeeding = now.difference(lastFeeding).inHours;

      if (hoursSinceLastFeeding > 4 && babyAgeInDays > 30) {
        recommendations.add(
          'Son beslenmeden $hoursSinceLastFeeding saat geçti, beslenme zamanı yaklaşıyor olabilir.',
        );
      }
    }

    return recommendations;
  }

  // En sık kullanılan katı gıdaları bulma
  static Map<String, int> getMostCommonSolidFoods(
    List<FeedingTrackingModel> feedings,
  ) {
    Map<String, int> foodCounts = {};

    for (var feeding in feedings) {
      if (feeding.solidFoods != null) {
        for (var food in feeding.solidFoods!) {
          foodCounts[food.name] = (foodCounts[food.name] ?? 0) + 1;
        }
      }
    }

    // Sıralayarak döndür
    var sortedEntries = foodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }
}
