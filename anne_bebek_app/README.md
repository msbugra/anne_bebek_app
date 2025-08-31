# Anne-Bebek Rehberi 📱👶

Modern, kapsamlı bir anne-bebek gelişim takip uygulaması. Flutter ile geliştirilmiş, offline-first mimariye sahip, Material Design 3 uyumlu mobil uygulama.

## 🌟 Özellikler

### 👩‍👧‍👦 Kullanıcı Yönetimi
- **Anne Kaydı**: Kişisel bilgiler, doğum tarihi, şehir
- **Bebek Kaydı**: Detaylı doğum bilgileri, sağlık verileri
- **Profil Yönetimi**: Düzenleme ve güncelleme özellikleri

### 📊 Sağlık Takibi
- **Aşı Takvimi**: T.C. Sağlık Bakanlığı + WHO standartları
- **Uyku Takibi**: Uyku süresi, kalitesi, patern analizi
- **Beslenme Takibi**: Emzirme, mama, katı gıdalar
- **Büyüme Takibi**: Boy, kilo, baş çevresi ölçümleri
- **Pediatrik Percentil**: WHO standartlarına göre değerlendirme

### 🧠 Gelişim Takibi
- **Yaş Bazlı Öneriler**: 0-5 yaş arası haftalık/günlük öneriler
- **Gelişimsel Dönemler**: Motor, sosyal, bilişsel gelişim
- **Aktivite Önerileri**: Oyun, müzik, kitap önerileri

### 🌙 Astroloji Modülü
- **Burç Hesaplama**: Doğum tarihine göre otomatik hesaplama
- **Uyumluluk Analizi**: Anne-bebek burç uyumluluğu
- **Özellikler**: Burçlara özel öneriler ve tavsiyeler

### 🎎 Kültürel Değerler
- **Türk Gelenekleri**: 20+ gelenek ve uygulama
- **Dünya Gelenekleri**: Farklı kültürlerden gelenekler
- **Kategori Filtreleme**: Tür, bölge, yaş grubu bazlı

### 🔒 Güvenlik & Gizlilik
- **Offline-First**: İnternet bağlantısı olmadan çalışabilme
- **Veri Şifreleme**: Hassas verilerin korunması
- **SQL Injection Koruması**: Güvenli veritabanı işlemleri
- **Input Validation**: Güvenli veri girişi kontrolü

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Android/iOS emulator veya fiziksel cihaz

### Adımlar

1. **Projeyi Klonlayın**
   ```bash
   git clone https://github.com/your-repo/anne-bebek-app.git
   cd anne_bebek_app
   ```

2. **Bağımlılıkları Yükleyin**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı Çalıştırın**
   ```bash
   # Debug mode
   flutter run

   # Release mode
   flutter run --release

   # Belirli bir cihazda
   flutter run -d <device_id>
   ```

4. **Build İşlemleri**
   ```bash
   # Android APK
   flutter build apk --release

   # Android App Bundle
   flutter build appbundle --release

   # iOS (macOS'ta)
   flutter build ios --release
   ```

## 📱 Kullanım

### İlk Kullanım
1. Uygulamayı açın
2. Hoş geldiniz ekranından başlayın
3. Anne bilgilerini girin
4. Bebek bilgilerini girin
5. Ana ekrana geçin

### Ana Özellikler

#### Sağlık Takibi
- **Aşı Takvimi**: Otomatik hatırlatmalar
- **Uyku Grafikleri**: Uyku paternleri analizi
- **Beslenme Kayıtları**: Detaylı beslenme takibi
- **Büyüme Eğris**: Percentil hesaplamaları

#### Gelişim Önerileri
- **Günlük Öneriler**: 0-3 yaş arası
- **Haftalık Öneriler**: 3-5 yaş arası
- **Kategori Bazlı**: Kitap, müzik, oyun, oyuncak

#### Astroloji Özellikleri
- **Otomatik Burç Hesaplama**
- **Uyumluluk Analizi**
- **Özelleştirilmiş Öneriler**

## 🏗️ Mimari

### Clean Architecture
```
lib/
├── core/           # Çekirdek işlevsellik
│   ├── constants/  # Sabitler
│   ├── services/   # Servisler (Database, Network)
│   ├── theme/      # Tema konfigürasyonu
│   └── utils/      # Yardımcı sınıflar
├── features/       # Özellik modülleri
│   ├── auth/       # Kimlik doğrulama
│   ├── home/       # Ana ekran
│   ├── health/     # Sağlık takibi
│   └── ...
├── shared/         # Paylaşılan bileşenler
│   ├── models/     # Veri modelleri
│   ├── providers/  # State management
│   └── widgets/    # Yeniden kullanılabilir widget'lar
└── main.dart       # Uygulama giriş noktası
```

### State Management
- **Provider Pattern**: Reactive state management
- **ChangeNotifier**: Basit ve etkili state güncellemeleri
- **Dependency Injection**: Service locator pattern

### Database
- **SQLite**: Yerel veritabanı
- **Migration System**: Versiyon güncellemeleri
- **Indexing**: Performance optimizasyonu
- **Foreign Keys**: Veri bütünlüğü

## 🔧 API Referansı

### Core Classes

#### DatabaseService
```dart
class DatabaseService {
  static Future<Database> get database => _initDatabase();

  Future<int> insert(String table, Map<String, dynamic> row);
  Future<List<Map<String, dynamic>>> query(String table, {String? where});
  Future<int> update(String table, Map<String, dynamic> row, {String? where});
  Future<int> delete(String table, {String? where});
}
```

#### BabyProvider
```dart
class BabyProvider with ChangeNotifier {
  Future<bool> saveMotherProfile({
    required String name,
    DateTime? birthDate,
    String? birthCity,
    bool astrologyEnabled = false,
    String? zodiacSign,
  });

  Future<bool> saveBabyProfile({
    required String name,
    required DateTime birthDate,
    // ... diğer parametreler
  });
}
```

#### AgeCalculator
```dart
class AgeCalculator {
  static int calculateAgeInDays(DateTime birthDate);
  static int calculateAgeInWeeks(DateTime birthDate);
  static int calculateAgeInMonths(DateTime birthDate);
  static int calculateAgeInYears(DateTime birthDate);
  static String getFormattedAge(DateTime birthDate);
}
```

#### ZodiacCalculator
```dart
class ZodiacCalculator {
  static String calculateZodiacSign(DateTime birthDate);
  static String getZodiacName(String sign);
  static Map<String, dynamic> getZodiacCompatibility(String sign1, String sign2);
}
```

### Security Utils
```dart
class SecurityUtils {
  static String sanitizeSqlInput(String input);
  static bool isValidEmail(String email);
  static bool isValidName(String name);
  static ValidationResult validateInput(String input);
}
```

## 🧪 Test

### Unit Testler
```bash
flutter test
```

### Widget Testler
```bash
flutter test --type=widget
```

### Integration Testler
```bash
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
```

## 📊 Performans

### Optimizasyonlar
- **Lazy Loading**: Büyük listelerde sayfalama
- **Caching**: Yaş hesaplama sonuçları cache'leniyor
- **Database Indexing**: Sık kullanılan alanlar indexlenmiş
- **Memory Management**: Controller'lar dispose ediliyor
- **Image Optimization**: Asset'ler optimize edilmiş

### Metrics
- **Build Size**: ~15MB (Android APK)
- **Startup Time**: <2 saniye
- **Memory Usage**: ~50MB ortalama
- **Battery Impact**: Minimal

## 🔒 Güvenlik

### Veri Koruma
- **Encryption**: Hassas veriler şifreleniyor
- **SQL Injection Protection**: Input sanitization
- **XSS Protection**: HTML sanitization
- **Input Validation**: Tüm girişler kontrol ediliyor

### Gizlilik
- **Offline Storage**: Veriler cihazda kalıyor
- **No External APIs**: Üçüncü parti servis kullanılmıyor
- **Data Minimization**: Sadece gerekli veriler toplanıyor

## 🚀 Deployment

### Android
```bash
# Keystore oluştur
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build
flutter build appbundle --release
```

### iOS
```bash
# iOS build (macOS'ta)
flutter build ios --release

# TestFlight upload
xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive -exportOptionsPlist exportOptions.plist -exportPath build/ios/ipa
```

## 📝 Changelog

### v1.0.0 (Current)
- ✅ İlk yayın
- ✅ Temel özellikler tamamlandı
- ✅ Offline-first mimari
- ✅ Material Design 3 uyumluluk
- ✅ Güvenlik iyileştirmeleri

### v1.1.0 (Planned)
- 🔄 Push notifications
- 🔄 Cloud backup
- 🔄 Advanced analytics
- 🔄 Multi-language support

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit edin (`git commit -m 'Add amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 📞 İletişim

- **Email**: info@annebebekrehberi.com
- **Website**: https://annebebekrehberi.com
- **Issues**: [GitHub Issues](https://github.com/your-repo/anne-bebek-app/issues)

## 🙏 Teşekkürler

Bu projede kullanılan açık kaynak kütüphanelere ve topluluğa teşekkür ederiz:

- Flutter Framework
- SQLite
- Provider Package
- Google Fonts
- Material Design Icons

---

**Made with ❤️ for parents and babies everywhere**
