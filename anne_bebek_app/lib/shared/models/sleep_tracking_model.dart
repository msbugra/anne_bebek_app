import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

part 'sleep_tracking_model.g.dart';

enum SleepQuality {
  @JsonValue('excellent')
  excellent, // Mükemmel
  @JsonValue('good')
  good, // İyi
  @JsonValue('fair')
  fair, // Orta
  @JsonValue('poor')
  poor, // Kötü
  @JsonValue('very_poor')
  veryPoor, // Çok Kötü
}

@JsonSerializable()
class SleepTrackingModel {
  final int? id;
  final int babyId;
  final DateTime sleepDate;
  final String? bedTime; // "HH:mm" formatında
  final String? wakeTime; // "HH:mm" formatında
  final int? napCount; // Gündüz uykusu sayısı
  final int? napDurationMinutes; // Gündüz uykusu toplam süresi (dakika)
  final SleepQuality? sleepQuality;
  final String? notes;
  final DateTime createdAt;

  const SleepTrackingModel({
    this.id,
    required this.babyId,
    required this.sleepDate,
    this.bedTime,
    this.wakeTime,
    this.napCount,
    this.napDurationMinutes,
    this.sleepQuality,
    this.notes,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory SleepTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$SleepTrackingModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$SleepTrackingModelToJson(this);

  // Factory constructor from database map
  factory SleepTrackingModel.fromMap(Map<String, dynamic> map) {
    return SleepTrackingModel(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      sleepDate: DateTime.parse(map['sleep_date'] as String),
      bedTime: map['bed_time'] as String?,
      wakeTime: map['wake_time'] as String?,
      napCount: map['nap_count'] as int?,
      napDurationMinutes: map['nap_duration_minutes'] as int?,
      sleepQuality: map['sleep_quality'] != null
          ? SleepQuality.values.firstWhere(
              (e) => e.toString().split('.').last == map['sleep_quality'],
              orElse: () => SleepQuality.fair,
            )
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
      'sleep_date': sleepDate.toIso8601String().split('T')[0], // Sadece tarih
      'bed_time': bedTime,
      'wake_time': wakeTime,
      'nap_count': napCount,
      'nap_duration_minutes': napDurationMinutes,
      'sleep_quality': sleepQuality?.toString().split('.').last,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Toplam gece uykusu süresi hesaplama (dakika cinsinden)
  int? get nightSleepDurationMinutes {
    if (bedTime == null || wakeTime == null) return null;

    try {
      List<String> bedTimeParts = bedTime!.split(':');
      List<String> wakeTimeParts = wakeTime!.split(':');

      int bedHour = int.parse(bedTimeParts[0]);
      int bedMinute = int.parse(bedTimeParts[1]);
      int wakeHour = int.parse(wakeTimeParts[0]);
      int wakeMinute = int.parse(wakeTimeParts[1]);

      DateTime bedDateTime = DateTime(
        sleepDate.year,
        sleepDate.month,
        sleepDate.day,
        bedHour,
        bedMinute,
      );

      DateTime wakeDateTime = DateTime(
        sleepDate.year,
        sleepDate.month,
        sleepDate.day + 1, // Ertesi gün
        wakeHour,
        wakeMinute,
      );

      // Eğer kalkış saati yatış saatinden erken ise, aynı gün kalkıyor demektir
      if (wakeHour > bedHour ||
          (wakeHour == bedHour && wakeMinute >= bedMinute)) {
        wakeDateTime = DateTime(
          sleepDate.year,
          sleepDate.month,
          sleepDate.day,
          wakeHour,
          wakeMinute,
        );
      }

      return wakeDateTime.difference(bedDateTime).inMinutes;
    } catch (e) {
      return null;
    }
  }

  // Toplam uyku süresi (gece + gündüz)
  int? get totalSleepDurationMinutes {
    int? nightSleep = nightSleepDurationMinutes;
    int? napSleep = napDurationMinutes;

    if (nightSleep == null && napSleep == null) return null;
    return (nightSleep ?? 0) + (napSleep ?? 0);
  }

  // Uyku kalitesi Türkçe açıklama
  String get sleepQualityDisplayName {
    switch (sleepQuality) {
      case SleepQuality.excellent:
        return 'Mükemmel';
      case SleepQuality.good:
        return 'İyi';
      case SleepQuality.fair:
        return 'Orta';
      case SleepQuality.poor:
        return 'Kötü';
      case SleepQuality.veryPoor:
        return 'Çok Kötü';
      case null:
        return 'Belirtilmemiş';
    }
  }

  // Uyku değerlendirmesi
  String get sleepAssessment {
    int? totalMinutes = totalSleepDurationMinutes;
    if (totalMinutes == null) return 'Değerlendirme yapılamıyor';

    double totalHours = totalMinutes / 60;

    // Yaş gruplarına göre önerilen uyku süreleri
    if (totalHours >= 14 && totalHours <= 17) {
      return 'Yenidoğan için ideal'; // 0-3 ay
    } else if (totalHours >= 12 && totalHours <= 16) {
      return 'Bebek için ideal'; // 4-11 ay
    } else if (totalHours >= 11 && totalHours <= 14) {
      return 'Toddler için ideal'; // 1-2 yaş
    } else if (totalHours < 10) {
      return 'Uyku süresi yetersiz';
    } else if (totalHours > 18) {
      return 'Uyku süresi fazla';
    }

    return 'Normal aralıkta';
  }

  // Uyku düzenli mi kontrolü
  bool get hasRegularSchedule {
    return bedTime != null && wakeTime != null;
  }

  // Copy with method
  SleepTrackingModel copyWith({
    int? id,
    int? babyId,
    DateTime? sleepDate,
    String? bedTime,
    String? wakeTime,
    int? napCount,
    int? napDurationMinutes,
    SleepQuality? sleepQuality,
    String? notes,
    DateTime? createdAt,
  }) {
    return SleepTrackingModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      sleepDate: sleepDate ?? this.sleepDate,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      napCount: napCount ?? this.napCount,
      napDurationMinutes: napDurationMinutes ?? this.napDurationMinutes,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SleepTrackingModel &&
        other.id == id &&
        other.babyId == babyId &&
        other.sleepDate == sleepDate &&
        other.bedTime == bedTime &&
        other.wakeTime == wakeTime &&
        other.napCount == napCount &&
        other.napDurationMinutes == napDurationMinutes &&
        other.sleepQuality == sleepQuality &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      babyId,
      sleepDate,
      bedTime,
      wakeTime,
      napCount,
      napDurationMinutes,
      sleepQuality,
      notes,
    );
  }

  @override
  String toString() {
    return 'SleepTrackingModel(id: $id, babyId: $babyId, '
        'sleepDate: $sleepDate, bedTime: $bedTime, wakeTime: $wakeTime, '
        'totalSleepMinutes: $totalSleepDurationMinutes, '
        'sleepQuality: $sleepQualityDisplayName)';
  }
}

// Uyku Patternleri ve Öneriler
class SleepPatternAnalyzer {
  // Haftalık uyku ortalaması hesaplama
  static Map<String, dynamic> calculateWeeklyAverage(
    List<SleepTrackingModel> sleepRecords,
  ) {
    if (sleepRecords.isEmpty) {
      return {
        'averageNightSleep': 0.0,
        'averageNapTime': 0.0,
        'averageTotalSleep': 0.0,
        'consistencyScore': 0.0,
      };
    }

    double totalNightSleep = 0;
    double totalNapTime = 0;
    double totalSleep = 0;
    int validRecords = 0;

    List<int> bedTimes = [];
    List<int> wakeTimes = [];

    for (var record in sleepRecords) {
      int? nightSleep = record.nightSleepDurationMinutes;
      int? napTime = record.napDurationMinutes;
      int? total = record.totalSleepDurationMinutes;

      if (total != null) {
        totalNightSleep += (nightSleep ?? 0) / 60; // Saat cinsinden
        totalNapTime += (napTime ?? 0) / 60;
        totalSleep += total / 60;
        validRecords++;
      }

      // Tutarlılık için yatış ve kalkış saatlerini topla
      if (record.bedTime != null) {
        try {
          List<String> parts = record.bedTime!.split(':');
          bedTimes.add(int.parse(parts[0]) * 60 + int.parse(parts[1]));
        } catch (e) {
          // Hata durumunda göz ardı et
        }
      }

      if (record.wakeTime != null) {
        try {
          List<String> parts = record.wakeTime!.split(':');
          wakeTimes.add(int.parse(parts[0]) * 60 + int.parse(parts[1]));
        } catch (e) {
          // Hata durumunda göz ardı et
        }
      }
    }

    if (validRecords == 0) {
      return {
        'averageNightSleep': 0.0,
        'averageNapTime': 0.0,
        'averageTotalSleep': 0.0,
        'consistencyScore': 0.0,
      };
    }

    // Tutarlılık skoru hesaplama (standart sapma ile)
    double consistencyScore = 0.0;
    if (bedTimes.length > 1) {
      double bedTimeMean = bedTimes.reduce((a, b) => a + b) / bedTimes.length;
      double bedTimeVariance =
          bedTimes
              .map((time) => (time - bedTimeMean) * (time - bedTimeMean))
              .reduce((a, b) => a + b) /
          bedTimes.length;
      double bedTimeStdDev = sqrt(bedTimeVariance);

      // Tutarlılık skoru: düşük standart sapma = yüksek skor
      consistencyScore = (60 - bedTimeStdDev).clamp(0, 100) / 100;
    }

    return {
      'averageNightSleep': totalNightSleep / validRecords,
      'averageNapTime': totalNapTime / validRecords,
      'averageTotalSleep': totalSleep / validRecords,
      'consistencyScore': consistencyScore,
    };
  }

  // Uyku önerileri
  static List<String> getSleepRecommendations(
    List<SleepTrackingModel> recentSleepRecords,
    int babyAgeInDays,
  ) {
    List<String> recommendations = [];

    if (recentSleepRecords.isEmpty) {
      recommendations.add('Uyku kayıtlarını düzenli tutmaya başlayın.');
      return recommendations;
    }

    Map<String, dynamic> weeklyStats = calculateWeeklyAverage(
      recentSleepRecords,
    );
    double avgTotalSleep = weeklyStats['averageTotalSleep'];
    double consistencyScore = weeklyStats['consistencyScore'];

    // Yaş grubuna göre öneriler
    if (babyAgeInDays <= 90) {
      // 0-3 ay
      if (avgTotalSleep < 14) {
        recommendations.add('Yenidoğanlar günde 14-17 saat uyumalıdır.');
      }
      recommendations.add('Gündüz ve gece arasında fark oluşturmaya başlayın.');
    } else if (babyAgeInDays <= 365) {
      // 4-12 ay
      if (avgTotalSleep < 12) {
        recommendations.add('Bebekler günde 12-16 saat uyumalıdır.');
      }
      if (consistencyScore < 0.7) {
        recommendations.add('Düzenli yatış saati oluşturmaya çalışın.');
      }
    } else {
      // 1+ yaş
      if (avgTotalSleep < 11) {
        recommendations.add('Toddlerlar günde 11-14 saat uyumalıdır.');
      }
      recommendations.add('Gündüz uykusunu kademeli olarak azaltın.');
    }

    // Genel öneriler
    if (consistencyScore < 0.5) {
      recommendations.add('Uyku rutini oluşturun ve tutarlı olun.');
    }

    return recommendations;
  }

  // En iyi yatış saati önerisi
  static String? suggestOptimalBedtime(List<SleepTrackingModel> sleepRecords) {
    List<int> qualityBedTimes = [];

    for (var record in sleepRecords) {
      if (record.bedTime != null &&
          (record.sleepQuality == SleepQuality.good ||
              record.sleepQuality == SleepQuality.excellent)) {
        try {
          List<String> parts = record.bedTime!.split(':');
          int minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          qualityBedTimes.add(minutes);
        } catch (e) {
          // Hata durumunda göz ardı et
        }
      }
    }

    if (qualityBedTimes.isEmpty) return null;

    // Ortalama kaliteli yatış saati
    int avgMinutes =
        qualityBedTimes.reduce((a, b) => a + b) ~/ qualityBedTimes.length;
    int hours = avgMinutes ~/ 60;
    int minutes = avgMinutes % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
}
