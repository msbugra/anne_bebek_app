import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'breastfeeding_tracking_model.g.dart';

enum BreastSide {
  @JsonValue('left')
  left, // Sol
  @JsonValue('right')
  right, // Sağ
  @JsonValue('both')
  both, // Her ikisi
}

enum BreastfeedingQuality {
  @JsonValue('excellent')
  excellent, // Mükemmel
  @JsonValue('good')
  good, // İyi
  @JsonValue('fair')
  fair, // Orta
  @JsonValue('poor')
  poor, // Kötü
  @JsonValue('difficult')
  difficult, // Zor
}

@JsonSerializable()
class BreastfeedingTrackingModel {
  final int? id;
  final int babyId;
  final DateTime feedingDateTime;
  final int durationMinutes;
  final BreastSide breastSide;
  final BreastfeedingQuality? feedingQuality;
  final bool? babyWasSatisfied; // Bebek doydu mu?
  final bool? hadDifficulty; // Zorluk yaşandı mı?
  final String? difficultyNote; // Zorluk açıklaması
  final String? notes;
  final DateTime createdAt;

  const BreastfeedingTrackingModel({
    this.id,
    required this.babyId,
    required this.feedingDateTime,
    required this.durationMinutes,
    required this.breastSide,
    this.feedingQuality,
    this.babyWasSatisfied,
    this.hadDifficulty,
    this.difficultyNote,
    this.notes,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory BreastfeedingTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$BreastfeedingTrackingModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$BreastfeedingTrackingModelToJson(this);

  // For sorting purposes
  DateTime get startTime => feedingDateTime;

  // Factory constructor from database map
  factory BreastfeedingTrackingModel.fromMap(Map<String, dynamic> map) {
    return BreastfeedingTrackingModel(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      feedingDateTime: DateTime.parse(map['feeding_date_time'] as String),
      durationMinutes: map['duration_minutes'] as int,
      breastSide: BreastSide.values.firstWhere(
        (e) => e.toString().split('.').last == map['breast_side'],
        orElse: () => BreastSide.both,
      ),
      feedingQuality: map['feeding_quality'] != null
          ? BreastfeedingQuality.values.firstWhere(
              (e) => e.toString().split('.').last == map['feeding_quality'],
              orElse: () => BreastfeedingQuality.fair,
            )
          : null,
      babyWasSatisfied: map['baby_was_satisfied'] != null
          ? (map['baby_was_satisfied'] as int) == 1
          : null,
      hadDifficulty: map['had_difficulty'] != null
          ? (map['had_difficulty'] as int) == 1
          : null,
      difficultyNote: map['difficulty_note'] as String?,
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
      'duration_minutes': durationMinutes,
      'breast_side': breastSide.toString().split('.').last,
      'feeding_quality': feedingQuality?.toString().split('.').last,
      'baby_was_satisfied': babyWasSatisfied != null
          ? (babyWasSatisfied! ? 1 : 0)
          : null,
      'had_difficulty': hadDifficulty != null ? (hadDifficulty! ? 1 : 0) : null,
      'difficulty_note': difficultyNote,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Meme tarafı Türkçe açıklama
  String get breastSideDisplayName {
    switch (breastSide) {
      case BreastSide.left:
        return 'Sol Meme';
      case BreastSide.right:
        return 'Sağ Meme';
      case BreastSide.both:
        return 'Her İki Meme';
    }
  }

  // Emzirme kalitesi Türkçe açıklama
  String get feedingQualityDisplayName {
    switch (feedingQuality) {
      case BreastfeedingQuality.excellent:
        return 'Mükemmel';
      case BreastfeedingQuality.good:
        return 'İyi';
      case BreastfeedingQuality.fair:
        return 'Orta';
      case BreastfeedingQuality.poor:
        return 'Kötü';
      case BreastfeedingQuality.difficult:
        return 'Zor';
      case null:
        return 'Belirtilmemiş';
    }
  }

  // Emzirme süresi formatlı metin
  String get durationText {
    if (durationMinutes < 60) {
      return '$durationMinutes dakika';
    } else {
      int hours = durationMinutes ~/ 60;
      int minutes = durationMinutes % 60;
      return '$hours saat ${minutes > 0 ? '$minutes dakika' : ''}';
    }
  }

  // Emzirme özeti
  String get feedingSummary {
    String summary = '$breastSideDisplayName - $durationText';

    if (feedingQuality != null) {
      summary += ' ($feedingQualityDisplayName)';
    }

    if (babyWasSatisfied != null) {
      summary += babyWasSatisfied! ? ' ✓ Doydu' : ' ✗ Doymadı';
    }

    return summary;
  }

  // Günlük emzirme için tarih kısmı
  DateTime get feedingDate {
    return DateTime(
      feedingDateTime.year,
      feedingDateTime.month,
      feedingDateTime.day,
    );
  }

  // Emzirme başarılı mı?
  bool get isSuccessfulFeeding {
    if (feedingQuality == BreastfeedingQuality.difficult ||
        feedingQuality == BreastfeedingQuality.poor) {
      return false;
    }
    if (babyWasSatisfied != null && !babyWasSatisfied!) {
      return false;
    }
    if (hadDifficulty != null && hadDifficulty!) {
      return false;
    }
    return durationMinutes >= 5; // En az 5 dakika emzirme
  }

  // Süre uyarıları
  String? get durationWarning {
    if (durationMinutes < 5) {
      return 'Çok kısa süre emzirildi';
    } else if (durationMinutes > 60) {
      return 'Çok uzun süre emzirildi';
    }
    return null;
  }

  // Son emzirmeden geçen süre hesaplama
  Duration timeSinceFeeding(DateTime currentTime) {
    return currentTime.difference(feedingDateTime);
  }

  // Bir sonraki emzirme önerisi
  String getNextFeedingRecommendation(DateTime currentTime, int babyAgeInDays) {
    Duration timeSince = timeSinceFeeding(currentTime);

    // Yaş grubuna göre emzirme aralıkları
    int recommendedIntervalHours;
    if (babyAgeInDays <= 7) {
      recommendedIntervalHours = 2; // Yenidoğan: 1.5-3 saat
    } else if (babyAgeInDays <= 30) {
      recommendedIntervalHours = 3; // İlk ay: 2-4 saat
    } else if (babyAgeInDays <= 180) {
      recommendedIntervalHours = 4; // 0-6 ay: 3-4 saat
    } else {
      recommendedIntervalHours = 5; // 6+ ay: 4-6 saat
    }

    int hoursUntilNext = recommendedIntervalHours - timeSince.inHours;

    if (hoursUntilNext <= 0) {
      return 'Emzirme zamanı geldi';
    } else {
      return 'Yaklaşık $hoursUntilNext saat sonra emzirme zamanı';
    }
  }

  // Validation
  bool get isValidFeeding {
    return durationMinutes > 0 && durationMinutes <= 120; // Max 2 saat
  }

  // Copy with method
  BreastfeedingTrackingModel copyWith({
    int? id,
    int? babyId,
    DateTime? feedingDateTime,
    int? durationMinutes,
    BreastSide? breastSide,
    BreastfeedingQuality? feedingQuality,
    bool? babyWasSatisfied,
    bool? hadDifficulty,
    String? difficultyNote,
    String? notes,
    DateTime? createdAt,
  }) {
    return BreastfeedingTrackingModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      feedingDateTime: feedingDateTime ?? this.feedingDateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      breastSide: breastSide ?? this.breastSide,
      feedingQuality: feedingQuality ?? this.feedingQuality,
      babyWasSatisfied: babyWasSatisfied ?? this.babyWasSatisfied,
      hadDifficulty: hadDifficulty ?? this.hadDifficulty,
      difficultyNote: difficultyNote ?? this.difficultyNote,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BreastfeedingTrackingModel &&
        other.id == id &&
        other.babyId == babyId &&
        other.feedingDateTime == feedingDateTime &&
        other.durationMinutes == durationMinutes &&
        other.breastSide == breastSide &&
        other.feedingQuality == feedingQuality &&
        other.babyWasSatisfied == babyWasSatisfied &&
        other.hadDifficulty == hadDifficulty &&
        other.difficultyNote == difficultyNote &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      babyId,
      feedingDateTime,
      durationMinutes,
      breastSide,
      feedingQuality,
      babyWasSatisfied,
      hadDifficulty,
      difficultyNote,
      notes,
    );
  }

  @override
  String toString() {
    return 'BreastfeedingTrackingModel(id: $id, babyId: $babyId, '
        'feedingDateTime: $feedingDateTime, '
        'feedingSummary: $feedingSummary)';
  }
}

// Anne Sütü Emzirme Analizi ve İstatistikler
class BreastfeedingAnalyzer {
  // Günlük emzirme sayısı hesaplama
  static int getDailyFeedingCount(
    List<BreastfeedingTrackingModel> feedings,
    DateTime date,
  ) {
    DateTime targetDate = DateTime(date.year, date.month, date.day);
    return feedings
        .where((feeding) => feeding.feedingDate == targetDate)
        .length;
  }

  // Günlük toplam emzirme süresi (dakika)
  static int getDailyTotalDuration(
    List<BreastfeedingTrackingModel> feedings,
    DateTime date,
  ) {
    DateTime targetDate = DateTime(date.year, date.month, date.day);
    return feedings
        .where((feeding) => feeding.feedingDate == targetDate)
        .fold(0, (sum, feeding) => sum + feeding.durationMinutes);
  }

  // Meme kullanım dağılımı
  static Map<BreastSide, int> getBreastSideDistribution(
    List<BreastfeedingTrackingModel> feedings,
  ) {
    Map<BreastSide, int> distribution = {
      BreastSide.left: 0,
      BreastSide.right: 0,
      BreastSide.both: 0,
    };

    for (var feeding in feedings) {
      distribution[feeding.breastSide] =
          (distribution[feeding.breastSide] ?? 0) + 1;
    }

    return distribution;
  }

  // Başarılı emzirme oranı hesaplama
  static double getSuccessRate(List<BreastfeedingTrackingModel> feedings) {
    if (feedings.isEmpty) return 0.0;

    int successfulFeedings = feedings
        .where((feeding) => feeding.isSuccessfulFeeding)
        .length;

    return (successfulFeedings / feedings.length) * 100;
  }

  // Haftalık emzirme özeti
  static Map<String, dynamic> getWeeklyBreastfeedingSummary(
    List<BreastfeedingTrackingModel> feedings,
    DateTime weekStart,
  ) {
    DateTime weekEnd = weekStart.add(Duration(days: 7));
    List<BreastfeedingTrackingModel> weeklyFeedings = feedings
        .where(
          (feeding) =>
              feeding.feedingDateTime.isAfter(weekStart) &&
              feeding.feedingDateTime.isBefore(weekEnd),
        )
        .toList();

    if (weeklyFeedings.isEmpty) {
      return {
        'totalFeedings': 0,
        'avgDailyFeedings': 0.0,
        'totalDuration': 0,
        'avgDurationPerFeeding': 0.0,
        'successRate': 0.0,
        'breastSideDistribution': <BreastSide, int>{},
        'qualityDistribution': <BreastfeedingQuality, int>{},
      };
    }

    int totalDuration = weeklyFeedings.fold(
      0,
      (sum, feeding) => sum + feeding.durationMinutes,
    );

    Map<BreastfeedingQuality, int> qualityDistribution = {};
    for (var feeding in weeklyFeedings) {
      if (feeding.feedingQuality != null) {
        qualityDistribution[feeding.feedingQuality!] =
            (qualityDistribution[feeding.feedingQuality!] ?? 0) + 1;
      }
    }

    return {
      'totalFeedings': weeklyFeedings.length,
      'avgDailyFeedings': weeklyFeedings.length / 7,
      'totalDuration': totalDuration,
      'avgDurationPerFeeding': totalDuration / weeklyFeedings.length,
      'successRate': getSuccessRate(weeklyFeedings),
      'breastSideDistribution': getBreastSideDistribution(weeklyFeedings),
      'qualityDistribution': qualityDistribution,
    };
  }

  // Emzirme pattern analizi
  static Map<String, dynamic> analyzeFeedingPattern(
    List<BreastfeedingTrackingModel> feedings,
  ) {
    if (feedings.isEmpty) return {};

    feedings.sort((a, b) => a.feedingDateTime.compareTo(b.feedingDateTime));

    List<Duration> intervals = [];
    for (int i = 1; i < feedings.length; i++) {
      Duration interval = feedings[i].feedingDateTime.difference(
        feedings[i - 1].feedingDateTime,
      );
      intervals.add(interval);
    }

    if (intervals.isEmpty) return {};

    // Ortalama aralık
    int avgIntervalMinutes =
        intervals
            .map((interval) => interval.inMinutes)
            .reduce((a, b) => a + b) ~/
        intervals.length;

    // En kısa ve en uzun aralık
    int shortestInterval = intervals
        .map((interval) => interval.inMinutes)
        .reduce((a, b) => a < b ? a : b);

    int longestInterval = intervals
        .map((interval) => interval.inMinutes)
        .reduce((a, b) => a > b ? a : b);

    // Düzenlilik skoru (standart sapma ile)
    double mean = avgIntervalMinutes.toDouble();
    double variance =
        intervals
            .map(
              (interval) =>
                  (interval.inMinutes - mean) * (interval.inMinutes - mean),
            )
            .reduce((a, b) => a + b) /
        intervals.length;
    double stdDev = sqrt(variance);

    // Düzenlilik skoru: düşük standart sapma = yüksek skor
    double regularityScore =
        (180 - stdDev).clamp(0, 100) / 100; // 180 dakika = 3 saat

    return {
      'avgIntervalHours': avgIntervalMinutes / 60,
      'shortestIntervalHours': shortestInterval / 60,
      'longestIntervalHours': longestInterval / 60,
      'regularityScore': regularityScore,
      'totalSessions': feedings.length,
    };
  }

  // Emzirme önerileri
  static List<String> getBreastfeedingRecommendations(
    List<BreastfeedingTrackingModel> recentFeedings,
    int babyAgeInDays,
  ) {
    List<String> recommendations = [];

    if (recentFeedings.isEmpty) {
      recommendations.add('Emzirme kayıtlarını düzenli tutmaya başlayın.');
      return recommendations;
    }

    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    int dailyFeedingCount = getDailyFeedingCount(recentFeedings, yesterday);
    double successRate = getSuccessRate(recentFeedings);
    Map<BreastSide, int> breastDistribution = getBreastSideDistribution(
      recentFeedings.take(7).toList(),
    );

    // Yaş grubuna göre öneriler
    if (babyAgeInDays <= 7) {
      // İlk hafta
      if (dailyFeedingCount < 8) {
        recommendations.add('Yenidoğanlar günde 8-12 kez emzirilmeli.');
      }
      recommendations.add(
        'İlk haftalarda sık emzirme ile süt üretimi artırın.',
      );
    } else if (babyAgeInDays <= 30) {
      // İlk ay
      if (dailyFeedingCount < 8) {
        recommendations.add('İlk ayda günde 8-10 kez emzirin.');
      }
      recommendations.add('Emzirme rutini oluşturmaya başlayın.');
    } else if (babyAgeInDays <= 180) {
      // 0-6 ay
      if (dailyFeedingCount < 6) {
        recommendations.add('6 aya kadar günde 6-8 kez emzirin.');
      }
      recommendations.add(
        'Sadece anne sütü ile beslenme döneminde kalite önemli.',
      );
    }

    // Başarı oranı önerileri
    if (successRate < 70) {
      recommendations.add(
        'Emzirme kalitesini artırmak için laktasyon danışmanına başvurabilirsiniz.',
      );
    }

    // Meme dengesi önerileri
    int leftCount = breastDistribution[BreastSide.left] ?? 0;
    int rightCount = breastDistribution[BreastSide.right] ?? 0;

    if (leftCount > 0 && rightCount > 0) {
      double ratio = leftCount > rightCount
          ? leftCount / rightCount
          : rightCount / leftCount;

      if (ratio > 2) {
        recommendations.add('Her iki memeyi de dengeli kullanmaya çalışın.');
      }
    }

    // Son emzirme kontrolü
    if (recentFeedings.isNotEmpty) {
      recentFeedings.sort(
        (a, b) => b.feedingDateTime.compareTo(a.feedingDateTime),
      );
      DateTime lastFeeding = recentFeedings.first.feedingDateTime;
      int hoursSinceLastFeeding = DateTime.now()
          .difference(lastFeeding)
          .inHours;

      if (hoursSinceLastFeeding > 4 && babyAgeInDays < 180) {
        recommendations.add(
          'Son emzirmeden $hoursSinceLastFeeding saat geçti, emzirme zamanı olabilir.',
        );
      }
    }

    return recommendations;
  }

  // En iyi emzirme saatleri analizi
  static Map<int, int> getBestFeedingHours(
    List<BreastfeedingTrackingModel> feedings,
  ) {
    Map<int, int> hourCounts = {};

    for (var feeding in feedings) {
      if (feeding.isSuccessfulFeeding) {
        int hour = feeding.feedingDateTime.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    // Sıralayarak döndür
    var sortedEntries = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }
}
