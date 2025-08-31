import 'package:anne_bebek_app/core/repositories/health_repository.dart';
import 'package:anne_bebek_app/core/utils/error_handler.dart';
import 'package:anne_bebek_app/shared/models/breastfeeding_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/feeding_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/growth_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/sleep_tracking_model.dart';
import 'package:anne_bebek_app/shared/models/vaccination_model.dart';

class MockHealthRepository implements HealthRepository {
  final bool shouldFail;
  final String failureType;

  MockHealthRepository({this.shouldFail = false, this.failureType = 'networkError'});

  @override
  Future<List<SleepTrackingModel>> getSleepRecords(String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Uyku kayıtları alınamadı');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Uyku kayıtları alınamadı');
        case 'serverError':
          throw ServerException('Sunucu hatası: Uyku kayıtları alınamadı');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Uyku kayıtları alınamadı');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Uyku kayıtları alınamadı');
      }
    }

    // Return mock data
    return [
      SleepTrackingModel(
        id: '1',
        babyId: babyId,
        sleepDate: DateTime.now().subtract(Duration(hours: 3)),
        wakeUpTime: DateTime.now().subtract(Duration(hours: 1)),
        durationInMinutes: 120,
        sleepQuality: 'good',
        notes: 'Rahat uyudu',
      ),
      SleepTrackingModel(
        id: '2',
        babyId: babyId,
        sleepDate: DateTime.now().subtract(Duration(days: 1, hours: 4)),
        wakeUpTime: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        durationInMinutes: 90,
        sleepQuality: 'fair',
        notes: 'Uyanık oldu',
      ),
    ];
  }

  @override
  Future<String> addSleepRecord(String babyId, SleepTrackingModel record) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Uyku kaydı eklenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Uyku kaydı eklenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Uyku kaydı eklenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Uyku kaydı eklenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Uyku kaydı eklenemedi');
      }
    }

    return 'mock_sleep_id';
  }

  @override
  Future<bool> updateSleepRecord(String babyId, SleepTrackingModel record) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Uyku kaydı güncellenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Uyku kaydı güncellenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Uyku kaydı güncellenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Uyku kaydı güncellenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Uyku kaydı güncellenemedi');
      }
    }

    return true;
  }

  @override
  Future<bool> deleteSleepRecord(String recordId, String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Uyku kaydı silinemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Uyku kaydı silinemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Uyku kaydı silinemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Uyku kaydı silinemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Uyku kaydı silinemedi');
      }
    }

    return true;
  }

  @override
  Future<List<GrowthTrackingModel>> getGrowthRecords(String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Büyüme kayıtları alınamadı');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Büyüme kayıtları alınamadı');
        case 'serverError':
          throw ServerException('Sunucu hatası: Büyüme kayıtları alınamadı');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Büyüme kayıtları alınamadı');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Büyüme kayıtları alınamadı');
      }
    }

    // Return mock data
    return [
      GrowthTrackingModel(
        id: '1',
        babyId: babyId,
        date: DateTime.now().subtract(Duration(days: 7)),
        weightKg: 4.2,
        heightCm: 55.5,
        headCircumferenceCm: 38.0,
        notes: 'Sağlıklı gelişme',
      ),
      GrowthTrackingModel(
        id: '2',
        babyId: babyId,
        date: DateTime.now().subtract(Duration(days: 30)),
        weightKg: 4.0,
        heightCm: 53.0,
        headCircumferenceCm: 37.0,
        notes: 'İlk ölçüm',
      ),
    ];
  }

  @override
  Future<String> addGrowthRecord(String babyId, GrowthTrackingModel record) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Büyüme kaydı eklenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Büyüme kaydı eklenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Büyüme kaydı eklenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Büyüme kaydı eklenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Büyüme kaydı eklenemedi');
      }
    }

    return 'mock_growth_id';
  }

  @override
  Future<bool> updateGrowthRecord(String babyId, GrowthTrackingModel record) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Büyüme kaydı güncellenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Büyüme kaydı güncellenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Büyüme kaydı güncellenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Büyüme kaydı güncellenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Büyüme kaydı güncellenemedi');
      }
    }

    return true;
  }

  @override
  Future<bool> deleteGrowthRecord(String recordId, String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Büyüme kaydı silinemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Büyüme kaydı silinemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Büyüme kaydı silinemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Büyüme kaydı silinemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Büyüme kaydı silinemedi');
      }
    }

    return true;
  }

  @override
  Future<List<FeedingTrackingModel>> getFeedingRecords(String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Beslenme kayıtları alınamadı');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Beslenme kayıtları alınamadı');
        case 'serverError':
          throw ServerException('Sunucu hatası: Beslenme kayıtları alınamadı');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Beslenme kayıtları alınamadı');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Beslenme kayıtları alınamadı');
      }
    }

    // Return mock data
    return [
      FeedingTrackingModel(
        id: '1',
        babyId: babyId,
        time: DateTime.now().subtract(Duration(hours: 2)),
        feedingType: 'breast',
        amountMl: null,
        durationMinutes: 25,
        notes: 'Sol meme',
      ),
      FeedingTrackingModel(
        id: '2',
        babyId: babyId,
        time: DateTime.now().subtract(Duration(hours: 4)),
        feedingType: 'bottle',
        amountMl: 120,
        durationMinutes: 15,
        notes: 'Anne sütü',
      ),
    ];
  }

  @override
  Future<String> addFeedingRecord(String babyId, FeedingTrackingModel record) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Beslenme kaydı eklenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Beslenme kaydı eklenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Beslenme kaydı eklenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Beslenme kaydı eklenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Beslenme kaydı eklenemedi');
      }
    }

    return 'mock_feeding_id';
  }

  @override
  Future<bool> updateFeedingRecord(String babyId, FeedingTrackingModel record) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Beslenme kaydı güncellenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Beslenme kaydı güncellenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Beslenme kaydı güncellenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Beslenme kaydı güncellenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Beslenme kaydı güncellenemedi');
      }
    }

    return true;
  }

  @override
  Future<bool> deleteFeedingRecord(String recordId, String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Beslenme kaydı silinemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Beslenme kaydı silinemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Beslenme kaydı silinemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Beslenme kaydı silinemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Beslenme kaydı silinemedi');
      }
    }

    return true;
  }

  @override
  Future<List<BreastfeedingTrackingModel>> getBreastfeedingRecords(
    String babyId,
  ) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Emzirme kayıtları alınamadı');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Emzirme kayıtları alınamadı');
        case 'serverError':
          throw ServerException('Sunucu hatası: Emzirme kayıtları alınamadı');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Emzirme kayıtları alınamadı');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Emzirme kayıtları alınamadı');
      }
    }

    // Return mock data
    return [
      BreastfeedingTrackingModel(
        id: '1',
        babyId: babyId,
        startTime: DateTime.now().subtract(Duration(hours: 2)),
        endTime: DateTime.now().subtract(Duration(hours: 1, minutes: 35)),
        leftBreastDuration: 15,
        rightBreastDuration: 20,
        notes: 'Rahat emdi',
      ),
    ];
  }

  @override
  Future<String> addBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  ) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Emzirme kaydı eklenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Emzirme kaydı eklenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Emzirme kaydı eklenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Emzirme kaydı eklenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Emzirme kaydı eklenemedi');
      }
    }

    return 'mock_breastfeeding_id';
  }

  @override
  Future<bool> updateBreastfeedingRecord(
    String babyId,
    BreastfeedingTrackingModel record,
  ) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Emzirme kaydı güncellenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Emzirme kaydı güncellenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Emzirme kaydı güncellenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Emzirme kaydı güncellenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Emzirme kaydı güncellenemedi');
      }
    }

    return true;
  }

  @override
  Future<bool> deleteBreastfeedingRecord(String recordId, String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Emzirme kaydı silinemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Emzirme kaydı silinemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Emzirme kaydı silinemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Emzirme kaydı silinemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Emzirme kaydı silinemedi');
      }
    }

    return true;
  }

  @override
  Future<List<VaccinationModel>> getVaccinations(String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Aşı kayıtları alınamadı');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Aşı kayıtları alınamadı');
        case 'serverError':
          throw ServerException('Sunucu hatası: Aşı kayıtları alınamadı');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Aşı kayıtları alınamadı');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Aşı kayıtları alınamadı');
      }
    }

    // Return mock data
    return [
      VaccinationModel(
        id: '1',
        babyId: babyId,
        vaccineName: 'Hep-B',
        scheduledDate: DateTime.now().subtract(Duration(days: 10)),
        administeredDate: DateTime.now().subtract(Duration(days: 10)),
        nextDoseDate: DateTime.now().add(Duration(days: 60)),
        administeredBy: 'Dr. Ahmet Yılmaz',
        batchNumber: 'HB12345',
        notes: 'İlk doz',
        status: 'completed',
      ),
      VaccinationModel(
        id: '2',
        babyId: babyId,
        vaccineName: 'DaBT-İPA-Hib',
        scheduledDate: DateTime.now().add(Duration(days: 5)),
        administeredDate: null,
        nextDoseDate: null,
        administeredBy: null,
        batchNumber: null,
        notes: 'İkinci doz',
        status: 'upcoming',
      ),
    ];
  }

  @override
  Future<List<VaccinationModel>> generateVaccinationSchedule(
    String babyId,
    DateTime birthDate,
  ) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Aşı takvimi oluşturulamadı');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Aşı takvimi oluşturulamadı');
        case 'serverError':
          throw ServerException('Sunucu hatası: Aşı takvimi oluşturulamadı');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Aşı takvimi oluşturulamadı');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Aşı takvimi oluşturulamadı');
      }
    }

    // Return mock data
    return [
      VaccinationModel(
        id: '1',
        babyId: babyId,
        vaccineName: 'Hep-B',
        scheduledDate: birthDate.add(Duration(days: 1)),
        administeredDate: null,
        nextDoseDate: birthDate.add(Duration(days: 61)),
        administeredBy: null,
        batchNumber: null,
        notes: 'İlk doz',
        status: 'upcoming',
      ),
    ];
  }

  @override
  Future<String> addVaccination(String babyId, VaccinationModel vaccination) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Aşı kaydı eklenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Aşı kaydı eklenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Aşı kaydı eklenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Aşı kaydı eklenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Aşı kaydı eklenemedi');
      }
    }

    return 'mock_vaccination_id';
  }

  @override
  Future<bool> updateVaccination(String babyId, VaccinationModel vaccination) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Aşı kaydı güncellenemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Aşı kaydı güncellenemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Aşı kaydı güncellenemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Aşı kaydı güncellenemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Aşı kaydı güncellenemedi');
      }
    }

    return true;
  }

  @override
  Future<bool> deleteVaccination(String recordId, String babyId) async {
    if (shouldFail) {
      await Future.delayed(Duration(milliseconds: 100));
      switch (failureType) {
        case 'networkError':
          throw NetworkException('Ağ hatası: Aşı kaydı silinemedi');
        case 'databaseError':
          throw DatabaseException('Veritabanı hatası: Aşı kaydı silinemedi');
        case 'serverError':
          throw ServerException('Sunucu hatası: Aşı kaydı silinemedi');
        case 'timeoutError':
          throw TimeoutException('Zaman aşımı: Aşı kaydı silinemedi');
        default:
          throw AppException(failureType, 'Bilinmeyen hata: Aşı kaydı silinemedi');
      }
    }

    return true;
  }
}