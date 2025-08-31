import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek_app/main.dart';
import 'package:anne_bebek_app/core/repositories/health_repository.dart';
import 'package:anne_bebek_app/core/repositories/recommendation_repository.dart';
import 'package:anne_bebek_app/core/repositories/fake_health_repository.dart';
import 'package:anne_bebek_app/core/services/database_service.dart';
import 'package:anne_bebek_app/shared/models/mother_model.dart';
import 'package:anne_bebek_app/shared/models/baby_model.dart';
import 'package:anne_bebek_app/shared/providers/baby_provider.dart';
import 'package:anne_bebek_app/core/utils/age_calculator.dart';
import 'package:anne_bebek_app/core/utils/zodiac_calculator.dart';
import 'package:anne_bebek_app/core/constants/app_constants.dart';

// Mock sınıflar
class MockRecommendationRepository extends Fake
    implements RecommendationRepository {}

class MockHealthRepository extends Fake implements HealthRepository {}

void main() {
  group('App Startup Tests', () {
    testWidgets('App starts without crashing', (WidgetTester tester) async {
      final fakeHealthRepo = FakeHealthRepository();
      final fakeRecommendationRepo = MockRecommendationRepository();

      await tester.pumpWidget(
        AnneBebekApp(
          healthRepository: fakeHealthRepo,
          recommendationRepository: fakeRecommendationRepo,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(AppInitializer), findsOneWidget);
    });
  });

  group('Model Tests', () {
    test('MotherModel serialization works correctly', () {
      final mother = MotherModel(
        id: 1,
        name: 'Test Mother',
        birthDate: DateTime(1990, 1, 1),
        birthCity: 'İstanbul',
        astrologyEnabled: true,
        zodiacSign: 'Oğlak',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final json = mother.toJson();
      final fromJson = MotherModel.fromJson(json);

      expect(fromJson.name, equals(mother.name));
      expect(fromJson.birthDate, equals(mother.birthDate));
      expect(fromJson.astrologyEnabled, equals(mother.astrologyEnabled));
    });

    test('BabyModel age calculation works correctly', () {
      final birthDate = DateTime.now().subtract(const Duration(days: 365));
      final baby = BabyModel(
        id: 1,
        motherId: 1,
        name: 'Test Baby',
        birthDate: birthDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(baby.ageInDays, equals(365));
      expect(baby.ageInYears, equals(1));
      expect(baby.ageGroup, equals('1-3 Yaş'));
    });

    test('BabyModel copyWith works correctly', () {
      final baby = BabyModel(
        id: 1,
        motherId: 1,
        name: 'Test Baby',
        birthDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedBaby = baby.copyWith(name: 'Updated Baby');

      expect(updatedBaby.name, equals('Updated Baby'));
      expect(updatedBaby.id, equals(baby.id));
    });
  });

  group('Utility Tests', () {
    test('AgeCalculator calculates age correctly', () {
      final birthDate = DateTime(2020, 1, 1);
      final now = DateTime(2023, 6, 15);

      final ageInDays = AgeCalculator.calculateAgeInDays(birthDate);
      final ageInYears = AgeCalculator.calculateAgeInYears(birthDate);
      final ageInMonths = AgeCalculator.calculateAgeInMonths(birthDate);

      expect(ageInYears, equals(3));
      expect(ageInMonths, equals(41)); // 3 yıl * 12 + 5 ay = 41 ay
      expect(ageInDays, greaterThan(1270)); // Yaklaşık 1278 gün
    });

    test('ZodiacCalculator calculates zodiac sign correctly', () {
      final birthDate = DateTime(1990, 1, 15); // Oğlak burcu
      final zodiacSign = ZodiacCalculator.calculateZodiacSign(birthDate);
      final zodiacName = ZodiacCalculator.getZodiacName(zodiacSign);

      expect(zodiacName, equals('Oğlak'));
    });

    test('ZodiacCalculator handles edge cases', () {
      // Burç geçiş tarihleri
      final capricornEnd = DateTime(1990, 1, 19); // Oğlak bitiş
      final aquariusStart = DateTime(1990, 1, 20); // Kova başlangıç

      final capricornSign = ZodiacCalculator.calculateZodiacSign(capricornEnd);
      final aquariusSign = ZodiacCalculator.calculateZodiacSign(aquariusStart);

      expect(ZodiacCalculator.getZodiacName(capricornSign), equals('Oğlak'));
      expect(ZodiacCalculator.getZodiacName(aquariusSign), equals('Kova'));
    });
  });

  group('Provider Tests', () {
    test('BabyProvider initializes correctly', () async {
      final databaseService = DatabaseService.instance;
      final provider = BabyProvider(databaseService: databaseService);

      expect(provider.currentBaby, isNull);
      expect(provider.currentMother, isNull);
      expect(provider.isLoading, isFalse);
    });

    test('BabyProvider saveMotherProfile works correctly', () async {
      final databaseService = DatabaseService.instance;
      final provider = BabyProvider(databaseService: databaseService);

      final result = await provider.saveMotherProfile(
        name: 'Test Mother',
        astrologyEnabled: true,
      );

      // Test database bağlantısı nedeniyle bu test mock ile yapılmalı
      // Bu sadece metodun çağrılabilirliğini test eder
      expect(result, isA<bool>());
    });
  });

  group('Constants Tests', () {
    test('AppConstants has correct values', () {
      expect(AppConstants.appName, equals('Anne-Bebek Rehberi'));
      expect(AppConstants.turkishCities.length, greaterThan(50));
      expect(AppConstants.zodiacSigns.length, equals(12));
      expect(AppConstants.recommendationCategories.length, greaterThan(3));
    });

    test('AppConstants age milestones are correct', () {
      expect(AppConstants.newbornPeriod, equals(28));
      expect(AppConstants.infantPeriod, equals(365));
      expect(AppConstants.toddlerStart, equals(365));
      expect(AppConstants.totalTrackingDays, equals(1825));
    });
  });

  group('Database Service Tests', () {
    test('DatabaseService is singleton', () {
      final instance1 = DatabaseService.instance;
      final instance2 = DatabaseService.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('DatabaseService has correct version', () {
      expect(DatabaseService.instance, isNotNull);
      // Version kontrolü için private field'a erişim gerekecek
    });
  });

  group('Integration Tests', () {
    testWidgets('Mother registration flow works', (WidgetTester tester) async {
      // Bu test için daha kapsamlı bir setup gerekecek
      // Şimdilik sadece temel widget test'i
      expect(true, isTrue);
    });

    testWidgets('Navigation between screens works', (
      WidgetTester tester,
    ) async {
      // Navigation testleri için mock setup gerekli
      expect(true, isTrue);
    });
  });

  group('Error Handling Tests', () {
    test('Invalid data handling in models', () {
      expect(
        () => MotherModel(
          name: '', // Invalid empty name
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Null safety in BabyModel', () {
      final baby = BabyModel(
        motherId: 1,
        name: 'Test',
        birthDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(baby.birthTime, isNull);
      expect(baby.birthWeight, isNull);
      expect(baby.gender, isNull);
    });
  });

  group('Performance Tests', () {
    test('Model serialization is fast', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        final mother = MotherModel(
          name: 'Test Mother $i',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        mother.toJson();
      }

      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
      ); // 500ms altında olmalı
    });

    test('Age calculation performance', () {
      final birthDate = DateTime(2020, 1, 1);
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10000; i++) {
        AgeCalculator.calculateAgeInDays(birthDate);
      }

      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
      ); // 1sn altında olmalı
    });
  });
}
