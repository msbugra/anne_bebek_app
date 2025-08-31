import 'package:json_annotation/json_annotation.dart';

part 'vaccination_model.g.dart';

enum VaccineStatus {
  @JsonValue('scheduled')
  scheduled, // Planlanmış
  @JsonValue('completed')
  completed, // Tamamlanmış
  @JsonValue('delayed')
  delayed, // Gecikmiş
  @JsonValue('skipped')
  skipped, // Atlanmış
}

@JsonSerializable()
class VaccinationModel {
  final int? id;
  final int babyId;
  final String vaccineName;
  final DateTime scheduledDate;
  final DateTime? administeredDate;
  final int doseNumber;
  final String? location; // Aşı yapılan yer (hastane, sağlık ocağı vb.)
  final String? notes;
  final VaccineStatus status;
  final DateTime createdAt;

  const VaccinationModel({
    this.id,
    required this.babyId,
    required this.vaccineName,
    required this.scheduledDate,
    this.administeredDate,
    this.doseNumber = 1,
    this.location,
    this.notes,
    this.status = VaccineStatus.scheduled,
    required this.createdAt,
  });

  // Factory constructor from JSON
  factory VaccinationModel.fromJson(Map<String, dynamic> json) =>
      _$VaccinationModelFromJson(json);

  // Convert to JSON
  Map<String, dynamic> toJson() => _$VaccinationModelToJson(this);

  // Factory constructor from database map
  factory VaccinationModel.fromMap(Map<String, dynamic> map) {
    return VaccinationModel(
      id: map['id'] as int?,
      babyId: map['baby_id'] as int,
      vaccineName: map['vaccine_name'] as String,
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      administeredDate: map['administered_date'] != null
          ? DateTime.parse(map['administered_date'] as String)
          : null,
      doseNumber: map['dose_number'] as int? ?? 1,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      status: VaccineStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (map['is_completed'] == 1 ? 'completed' : 'scheduled'),
        orElse: () => VaccineStatus.scheduled,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'baby_id': babyId,
      'vaccine_name': vaccineName,
      'scheduled_date': scheduledDate.toIso8601String(),
      'administered_date': administeredDate?.toIso8601String(),
      'dose_number': doseNumber,
      'location': location,
      'notes': notes,
      'is_completed': status == VaccineStatus.completed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Status'u Türkçe olarak döndür
  String get statusDisplayName {
    switch (status) {
      case VaccineStatus.scheduled:
        return 'Planlanmış';
      case VaccineStatus.completed:
        return 'Tamamlanmış';
      case VaccineStatus.delayed:
        return 'Gecikmiş';
      case VaccineStatus.skipped:
        return 'Atlanmış';
    }
  }

  // Aşı durumunu kontrol et
  bool get isCompleted => status == VaccineStatus.completed;
  bool get isPending => status == VaccineStatus.scheduled;
  bool get isDelayed =>
      status == VaccineStatus.scheduled &&
      DateTime.now().isAfter(scheduledDate.add(const Duration(days: 7)));

  // Gecikme gün sayısı
  int get delayDays {
    if (!isDelayed) return 0;
    return DateTime.now().difference(scheduledDate).inDays;
  }

  // Copy with method
  VaccinationModel copyWith({
    int? id,
    int? babyId,
    String? vaccineName,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    int? doseNumber,
    String? location,
    String? notes,
    VaccineStatus? status,
    DateTime? createdAt,
  }) {
    return VaccinationModel(
      id: id ?? this.id,
      babyId: babyId ?? this.babyId,
      vaccineName: vaccineName ?? this.vaccineName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      administeredDate: administeredDate ?? this.administeredDate,
      doseNumber: doseNumber ?? this.doseNumber,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VaccinationModel &&
        other.id == id &&
        other.babyId == babyId &&
        other.vaccineName == vaccineName &&
        other.scheduledDate == scheduledDate &&
        other.administeredDate == administeredDate &&
        other.doseNumber == doseNumber &&
        other.location == location &&
        other.notes == notes &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      babyId,
      vaccineName,
      scheduledDate,
      administeredDate,
      doseNumber,
      location,
      notes,
      status,
    );
  }

  @override
  String toString() {
    return 'VaccinationModel(id: $id, vaccineName: $vaccineName, '
        'doseNumber: $doseNumber, scheduledDate: $scheduledDate, '
        'status: $statusDisplayName)';
  }
}

// T.C. Sağlık Bakanlığı Aşı Takvimi
class TurkishVaccinationSchedule {
  static List<Map<String, dynamic>> getSchedule() {
    return [
      // Doğumda
      {
        'vaccine': 'Hepatit B',
        'dose': 1,
        'ageInDays': 0,
        'description': 'Doğumdan sonraki ilk 24 saat içinde',
      },
      {
        'vaccine': 'BCG',
        'dose': 1,
        'ageInDays': 0,
        'description': 'Doğumdan sonraki ilk ay içinde',
      },

      // 2. ay
      {
        'vaccine': 'Hepatit B',
        'dose': 2,
        'ageInDays': 60,
        'description': '2. ay tamamlandıktan sonra',
      },
      {
        'vaccine': 'DaBT-İPA-Hib',
        'dose': 1,
        'ageInDays': 60,
        'description':
            'Difteri, Boğmaca, Tetanos, İnaktif Polio, Haemophilus influenzae tip b',
      },
      {
        'vaccine': 'Pnömokok',
        'dose': 1,
        'ageInDays': 60,
        'description': 'Pnömokok konjuge aşısı',
      },

      // 4. ay
      {
        'vaccine': 'DaBT-İPA-Hib',
        'dose': 2,
        'ageInDays': 120,
        'description': 'İkinci doz',
      },
      {
        'vaccine': 'Pnömokok',
        'dose': 2,
        'ageInDays': 120,
        'description': 'İkinci doz',
      },
      {
        'vaccine': 'OPV',
        'dose': 1,
        'ageInDays': 120,
        'description': 'Oral Polio Aşısı',
      },

      // 6. ay
      {
        'vaccine': 'Hepatit B',
        'dose': 3,
        'ageInDays': 180,
        'description': 'Üçüncü doz',
      },
      {
        'vaccine': 'DaBT-İPA-Hib',
        'dose': 3,
        'ageInDays': 180,
        'description': 'Üçüncü doz',
      },
      {
        'vaccine': 'OPV',
        'dose': 2,
        'ageInDays': 180,
        'description': 'İkinci doz',
      },

      // 12. ay
      {
        'vaccine': 'Pnömokok',
        'dose': 3,
        'ageInDays': 365,
        'description': 'Üçüncü doz (Pekiştirme)',
      },
      {
        'vaccine': 'MMR',
        'dose': 1,
        'ageInDays': 365,
        'description': 'Kızamık, Kabakulak, Kızamıkçık',
      },
      {
        'vaccine': 'Suçiçeği',
        'dose': 1,
        'ageInDays': 365,
        'description': 'Varisella Aşısı',
      },

      // 18. ay
      {
        'vaccine': 'DaBT-İPA-Hib',
        'dose': 4,
        'ageInDays': 540,
        'description': 'Dördüncü doz (Pekiştirme)',
      },
      {
        'vaccine': 'OPV',
        'dose': 3,
        'ageInDays': 540,
        'description': 'Üçüncü doz',
      },
      {
        'vaccine': 'Hepatit A',
        'dose': 1,
        'ageInDays': 540,
        'description': 'İlk doz',
      },

      // 24. ay
      {
        'vaccine': 'Hepatit A',
        'dose': 2,
        'ageInDays': 720,
        'description': 'İkinci doz',
      },

      // 48. ay (4 yaş)
      {
        'vaccine': 'DaBT-İPA',
        'dose': 5,
        'ageInDays': 1460,
        'description': 'Beşinci doz (Okul öncesi pekiştirme)',
      },
      {
        'vaccine': 'OPV',
        'dose': 4,
        'ageInDays': 1460,
        'description': 'Dördüncü doz',
      },
      {
        'vaccine': 'MMR',
        'dose': 2,
        'ageInDays': 1460,
        'description': 'İkinci doz',
      },
    ];
  }

  // Bebek için aşı takvimi oluştur
  static List<VaccinationModel> generateScheduleForBaby(
    int babyId,
    DateTime birthDate,
  ) {
    List<VaccinationModel> vaccines = [];
    List<Map<String, dynamic>> schedule = getSchedule();
    DateTime now = DateTime.now();

    for (var vaccineInfo in schedule) {
      DateTime scheduledDate = birthDate.add(
        Duration(days: vaccineInfo['ageInDays']),
      );

      vaccines.add(
        VaccinationModel(
          babyId: babyId,
          vaccineName: vaccineInfo['vaccine'],
          scheduledDate: scheduledDate,
          doseNumber: vaccineInfo['dose'],
          notes: vaccineInfo['description'],
          status: scheduledDate.isBefore(now)
              ? VaccineStatus.delayed
              : VaccineStatus.scheduled,
          createdAt: now,
        ),
      );
    }

    return vaccines;
  }

  // Yaşa göre aktif aşıları getir
  static List<Map<String, dynamic>> getVaccinesForAge(int ageInDays) {
    List<Map<String, dynamic>> schedule = getSchedule();
    return schedule.where((vaccine) {
      int vaccineAge = vaccine['ageInDays'];
      return ageInDays >= vaccineAge &&
          ageInDays <= (vaccineAge + 30); // 30 gün tolerans
    }).toList();
  }

  // Sonraki aşıları getir
  static List<Map<String, dynamic>> getUpcomingVaccines(int ageInDays) {
    List<Map<String, dynamic>> schedule = getSchedule();
    return schedule
        .where((vaccine) {
          int vaccineAge = vaccine['ageInDays'];
          return vaccineAge > ageInDays;
        })
        .take(3)
        .toList(); // İlk 3 sonraki aşı
  }
}
