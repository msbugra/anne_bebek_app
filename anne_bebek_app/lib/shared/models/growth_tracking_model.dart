import 'package:json_annotation/json_annotation.dart';
import '../../core/utils/age_calculator.dart';

part 'growth_tracking_model.g.dart';

@JsonSerializable()
class GrowthTrackingModel {
  final int? id;
  final int babyId;
  final DateTime measurementDate;
  final int ageInDays;
  final double? weight; // kilogram
  final double? height; // santimetre
  final double? headCircumference; // santimetre
  final double? weightPercentile;
  final double? heightPercentile;
  final double? headPercentile;
  final DateTime createdAt;

  const GrowthTrackingModel({
    this.id,
    required this.babyId,
    required this.measurementDate,
    required this.ageInDays,
    this.weight,
    this.height,
    this.headCircumference,
    this.weightPercentile,
    this.heightPercentile,
    this.headPercentile,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory GrowthTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$GrowthTrackingModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$GrowthTrackingModelToJson(this);

  // For sorting purposes
  DateTime get date => measurementDate;

  // Factory constructor from database map
  factory GrowthTrackingModel.fromMap(Map<String, dynamic> map) {
    return GrowthTrackingModel(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      measurementDate: DateTime.parse(map['measurement_date'] as String),
      ageInDays: map['age_in_days'] as int,
      weight: map['weight'] as double?,
      height: map['height'] as double?,
      headCircumference: map['head_circumference'] as double?,
      weightPercentile: map['weight_percentile'] as double?,
      heightPercentile: map['height_percentile'] as double?,
      headPercentile: map['head_percentile'] as double?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'measurement_date': measurementDate.toIso8601String(),
      'age_in_days': ageInDays,
      'weight': weight,
      'height': height,
      'head_circumference': headCircumference,
      'weight_percentile': weightPercentile,
      'height_percentile': heightPercentile,
      'head_percentile': headPercentile,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Yaş grubu belirle
  String get ageGroup {
    return AgeCalculator.getAgeGroup(
      DateTime.now().subtract(Duration(days: ageInDays)),
    );
  }

  // Büyüme durumu değerlendirmesi
  String get growthAssessment {
    if (weightPercentile == null) return 'Değerlendirme yapılmadı';

    if (weightPercentile! < 3) return 'Normal altında';
    if (weightPercentile! < 10) return 'Normal alt sınır';
    if (weightPercentile! <= 90) return 'Normal';
    if (weightPercentile! <= 97) return 'Normal üst sınır';
    return 'Normal üstünde';
  }

  // Boy durumu değerlendirmesi
  String get heightAssessment {
    if (heightPercentile == null) return 'Değerlendirme yapılmadı';

    if (heightPercentile! < 3) return 'Kısa boy';
    if (heightPercentile! < 10) return 'Normal alt sınır';
    if (heightPercentile! <= 90) return 'Normal';
    if (heightPercentile! <= 97) return 'Normal üst sınır';
    return 'Uzun boy';
  }

  // Baş çevresi durumu değerlendirmesi
  String get headCircumferenceAssessment {
    if (headPercentile == null) return 'Değerlendirme yapılmadı';

    if (headPercentile! < 3) return 'Mikrosefali riski';
    if (headPercentile! < 10) return 'Normal alt sınır';
    if (headPercentile! <= 90) return 'Normal';
    if (headPercentile! <= 97) return 'Normal üst sınır';
    return 'Makrosefali riski';
  }

  // Copy with method
  GrowthTrackingModel copyWith({
    int? id,
    int? babyId,
    DateTime? measurementDate,
    int? ageInDays,
    double? weight,
    double? height,
    double? headCircumference,
    double? weightPercentile,
    double? heightPercentile,
    double? headPercentile,
    DateTime? createdAt,
  }) {
    return GrowthTrackingModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      measurementDate: measurementDate ?? this.measurementDate,
      ageInDays: ageInDays ?? this.ageInDays,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      headCircumference: headCircumference ?? this.headCircumference,
      weightPercentile: weightPercentile ?? this.weightPercentile,
      heightPercentile: heightPercentile ?? this.heightPercentile,
      headPercentile: headPercentile ?? this.headPercentile,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrowthTrackingModel &&
        other.id == id &&
        other.babyId == babyId &&
        other.measurementDate == measurementDate &&
        other.ageInDays == ageInDays &&
        other.weight == weight &&
        other.height == height &&
        other.headCircumference == headCircumference;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      babyId,
      measurementDate,
      ageInDays,
      weight,
      height,
      headCircumference,
    );
  }

  @override
  String toString() {
    return 'GrowthTrackingModel(id: $id, babyId: $babyId, '
        'measurementDate: $measurementDate, weight: $weight, '
        'height: $height, headCircumference: $headCircumference)';
  }
}

// WHO Büyüme Standartları ve Percentil Hesaplayıcı
class WHOGrowthCalculator {
  // Erkek bebek kilo percentilleri (0-24 ay) - özet veriler
  static final Map<int, Map<String, double>> _maleWeightPercentiles = {
    0: {
      'p3': 2.5,
      'p10': 2.9,
      'p25': 3.2,
      'p50': 3.3,
      'p75': 3.9,
      'p90': 4.4,
      'p97': 4.8,
    },
    30: {
      'p3': 3.4,
      'p10': 3.9,
      'p25': 4.5,
      'p50': 4.9,
      'p75': 5.6,
      'p90': 6.2,
      'p97': 6.7,
    },
    60: {
      'p3': 4.3,
      'p10': 4.9,
      'p25': 5.6,
      'p50': 6.2,
      'p75': 6.9,
      'p90': 7.5,
      'p97': 8.0,
    },
    90: {
      'p3': 5.0,
      'p10': 5.7,
      'p25': 6.4,
      'p50': 7.1,
      'p75': 7.8,
      'p90': 8.4,
      'p97': 8.9,
    },
    120: {
      'p3': 5.6,
      'p10': 6.4,
      'p25': 7.0,
      'p50': 7.8,
      'p75': 8.6,
      'p90': 9.2,
      'p97': 9.7,
    },
    365: {
      'p3': 7.7,
      'p10': 8.4,
      'p25': 9.4,
      'p50': 10.2,
      'p75': 11.1,
      'p90': 11.8,
      'p97': 12.4,
    },
    730: {
      'p3': 9.7,
      'p10': 10.8,
      'p25': 11.8,
      'p50': 12.9,
      'p75': 13.9,
      'p90': 14.8,
      'p97': 15.6,
    },
  };

  // Kız bebek kilo percentilleri (0-24 ay)
  static final Map<int, Map<String, double>> _femaleWeightPercentiles = {
    0: {
      'p3': 2.4,
      'p10': 2.8,
      'p25': 3.0,
      'p50': 3.2,
      'p75': 3.7,
      'p90': 4.2,
      'p97': 4.6,
    },
    30: {
      'p3': 3.2,
      'p10': 3.6,
      'p25': 4.2,
      'p50': 4.6,
      'p75': 5.2,
      'p90': 5.8,
      'p97': 6.2,
    },
    60: {
      'p3': 4.0,
      'p10': 4.5,
      'p25': 5.1,
      'p50': 5.7,
      'p75': 6.4,
      'p90': 7.0,
      'p97': 7.5,
    },
    90: {
      'p3': 4.6,
      'p10': 5.2,
      'p25': 5.9,
      'p50': 6.5,
      'p75': 7.2,
      'p90': 7.8,
      'p97': 8.2,
    },
    120: {
      'p3': 5.1,
      'p10': 5.7,
      'p25': 6.5,
      'p50': 7.3,
      'p75': 8.1,
      'p90': 8.7,
      'p97': 9.2,
    },
    365: {
      'p3': 7.0,
      'p10': 7.7,
      'p25': 8.5,
      'p50': 9.5,
      'p75': 10.4,
      'p90': 11.2,
      'p97': 11.8,
    },
    730: {
      'p3': 8.9,
      'p10': 9.9,
      'p25': 10.8,
      'p50': 12.1,
      'p75': 13.2,
      'p90': 14.1,
      'p97': 14.8,
    },
  };

  // Boy percentilleri (erkek)
  static final Map<int, Map<String, double>> _maleHeightPercentiles = {
    0: {
      'p3': 46.1,
      'p10': 47.3,
      'p25': 48.0,
      'p50': 49.9,
      'p75': 51.8,
      'p90': 53.7,
      'p97': 55.6,
    },
    30: {
      'p3': 50.8,
      'p10': 52.3,
      'p25': 53.6,
      'p50': 54.6,
      'p75': 56.7,
      'p90': 58.6,
      'p97': 60.4,
    },
    60: {
      'p3': 54.4,
      'p10': 56.0,
      'p25': 57.6,
      'p50': 58.4,
      'p75': 60.4,
      'p90': 62.4,
      'p97': 64.4,
    },
    365: {
      'p3': 71.0,
      'p10': 72.8,
      'p25': 74.9,
      'p50': 76.1,
      'p75': 78.0,
      'p90': 80.7,
      'p97': 82.9,
    },
    730: {
      'p3': 82.5,
      'p10': 84.8,
      'p25': 86.8,
      'p50': 87.8,
      'p75': 90.4,
      'p90': 92.9,
      'p97': 95.4,
    },
  };

  // Boy percentilleri (kız)
  static final Map<int, Map<String, double>> _femaleHeightPercentiles = {
    0: {
      'p3': 45.4,
      'p10': 46.5,
      'p25': 47.3,
      'p50': 49.1,
      'p75': 50.8,
      'p90': 52.9,
      'p97': 54.7,
    },
    30: {
      'p3': 49.8,
      'p10': 51.1,
      'p25': 52.8,
      'p50': 53.7,
      'p75': 55.6,
      'p90': 57.6,
      'p97': 59.5,
    },
    60: {
      'p3': 53.0,
      'p10': 54.6,
      'p25': 56.2,
      'p50': 57.1,
      'p75': 59.1,
      'p90': 61.1,
      'p97': 63.2,
    },
    365: {
      'p3': 69.8,
      'p10': 71.4,
      'p25': 73.1,
      'p50': 74.0,
      'p75': 76.0,
      'p90': 78.9,
      'p97': 80.7,
    },
    730: {
      'p3': 80.7,
      'p10': 82.8,
      'p25': 84.9,
      'p50': 86.4,
      'p75': 88.3,
      'p90': 91.0,
      'p97': 93.9,
    },
  };

  // Baş çevresi percentilleri (erkek)
  static final Map<int, Map<String, double>> _maleHeadPercentiles = {
    0: {
      'p3': 32.6,
      'p10': 33.2,
      'p25': 33.9,
      'p50': 34.5,
      'p75': 35.7,
      'p90': 36.5,
      'p97': 37.3,
    },
    30: {
      'p3': 35.8,
      'p10': 36.4,
      'p25': 37.1,
      'p50': 37.6,
      'p75': 38.4,
      'p90': 39.1,
      'p97': 39.7,
    },
    60: {
      'p3': 38.3,
      'p10': 39.0,
      'p25': 39.6,
      'p50': 40.5,
      'p75': 41.4,
      'p90': 42.0,
      'p97': 42.6,
    },
    365: {
      'p3': 44.9,
      'p10': 45.7,
      'p25': 46.5,
      'p50': 47.4,
      'p75': 48.4,
      'p90': 49.2,
      'p97': 50.1,
    },
    730: {
      'p3': 46.0,
      'p10': 46.9,
      'p25': 47.4,
      'p50': 48.4,
      'p75': 49.3,
      'p90': 50.2,
      'p97': 51.0,
    },
  };

  // Baş çevresi percentilleri (kız)
  static final Map<int, Map<String, double>> _femaleHeadPercentiles = {
    0: {
      'p3': 32.0,
      'p10': 32.7,
      'p25': 33.3,
      'p50': 33.9,
      'p75': 34.7,
      'p90': 35.4,
      'p97': 36.2,
    },
    30: {
      'p3': 35.0,
      'p10': 35.6,
      'p25': 36.2,
      'p50': 36.8,
      'p75': 37.6,
      'p90': 38.3,
      'p97': 38.9,
    },
    60: {
      'p3': 37.1,
      'p10': 37.8,
      'p25': 38.4,
      'p50': 39.1,
      'p75': 39.9,
      'p90': 40.7,
      'p97': 41.5,
    },
    365: {
      'p3': 43.5,
      'p10': 44.2,
      'p25': 44.9,
      'p50': 45.8,
      'p75': 46.8,
      'p90': 47.6,
      'p97': 48.4,
    },
    730: {
      'p3': 45.2,
      'p10': 45.8,
      'p25': 46.4,
      'p50': 47.4,
      'p75': 48.2,
      'p90': 49.0,
      'p97': 49.7,
    },
  };

  // Percentil hesaplama
  static double calculatePercentile(
    double value,
    int ageInDays,
    bool isMale,
    String measurementType,
  ) {
    Map<int, Map<String, double>>? percentileData;

    switch (measurementType.toLowerCase()) {
      case 'weight':
        percentileData = isMale
            ? _maleWeightPercentiles
            : _femaleWeightPercentiles;
        break;
      case 'height':
        percentileData = isMale
            ? _maleHeightPercentiles
            : _femaleHeightPercentiles;
        break;
      case 'head':
        percentileData = isMale ? _maleHeadPercentiles : _femaleHeadPercentiles;
        break;
      default:
        return 50.0; // Varsayılan
    }

    // En yakın yaş grubunu bul
    int closestAge = _findClosestAge(ageInDays, percentileData.keys.toList());
    Map<String, double>? ageData = percentileData[closestAge];

    if (ageData == null) return 50.0;

    // Value'yu percentillere göre konumlandır
    if (value <= ageData['p3']!) return 3.0;
    if (value <= ageData['p10']!) {
      return _interpolate(value, ageData['p3']!, ageData['p10']!, 3.0, 10.0);
    }
    if (value <= ageData['p25']!) {
      return _interpolate(value, ageData['p10']!, ageData['p25']!, 10.0, 25.0);
    }
    if (value <= ageData['p50']!) {
      return _interpolate(value, ageData['p25']!, ageData['p50']!, 25.0, 50.0);
    }
    if (value <= ageData['p75']!) {
      return _interpolate(value, ageData['p50']!, ageData['p75']!, 50.0, 75.0);
    }
    if (value <= ageData['p90']!) {
      return _interpolate(value, ageData['p75']!, ageData['p90']!, 75.0, 90.0);
    }
    if (value <= ageData['p97']!) {
      return _interpolate(value, ageData['p90']!, ageData['p97']!, 90.0, 97.0);
    }

    return 97.0;
  }

  // En yakın yaş grubunu bulma
  static int _findClosestAge(int ageInDays, List<int> availableAges) {
    int closest = availableAges.first;
    int minDiff = (ageInDays - closest).abs();

    for (int age in availableAges) {
      int diff = (ageInDays - age).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = age;
      }
    }

    return closest;
  }

  // Linear interpolasyon
  static double _interpolate(
    double value,
    double x1,
    double x2,
    double y1,
    double y2,
  ) {
    if (x2 == x1) return y1;
    return y1 + (value - x1) * (y2 - y1) / (x2 - x1);
  }

  // Z-score hesaplama (gelişmiş percentil hesaplama için)
  static double calculateZScore(double value, double mean, double sd) {
    return (value - mean) / sd;
  }

  // Z-score'dan percentil hesaplama
  static double zScoreToPercentile(double zScore) {
    // Basitleştirilmiş normal dağılım yaklaşımı
    if (zScore <= -3.0) return 0.1;
    if (zScore <= -2.0) return 2.3;
    if (zScore <= -1.0) return 15.9;
    if (zScore <= 0.0) return 50.0;
    if (zScore <= 1.0) return 84.1;
    if (zScore <= 2.0) return 97.7;
    if (zScore <= 3.0) return 99.9;
    return 99.9;
  }

  // Büyüme hızı hesaplama
  static double calculateGrowthVelocity(
    List<GrowthTrackingModel> measurements,
    String measurementType,
  ) {
    if (measurements.length < 2) return 0.0;

    measurements.sort((a, b) => a.measurementDate.compareTo(b.measurementDate));

    GrowthTrackingModel first = measurements.first;
    GrowthTrackingModel last = measurements.last;

    double? firstValue;
    double? lastValue;

    switch (measurementType.toLowerCase()) {
      case 'weight':
        firstValue = first.weight;
        lastValue = last.weight;
        break;
      case 'height':
        firstValue = first.height;
        lastValue = last.height;
        break;
      case 'head':
        firstValue = first.headCircumference;
        lastValue = last.headCircumference;
        break;
    }

    if (firstValue == null || lastValue == null) return 0.0;

    int daysDifference = last.measurementDate
        .difference(first.measurementDate)
        .inDays;
    if (daysDifference == 0) return 0.0;

    // Günlük büyüme hızı
    return (lastValue - firstValue) / daysDifference;
  }
}
