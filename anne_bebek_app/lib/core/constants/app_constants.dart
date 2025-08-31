class AppConstants {
  // App Info
  static const String appName = 'Anne-Bebek Rehberi';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'anne_bebek_app.db';
  static const int dbVersion = 1;

  // Shared Preferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyMotherName = 'mother_name';
  static const String keyBabyName = 'baby_name';
  static const String keyBabyBirthDate = 'baby_birth_date';
  static const String keyAstrologyEnabled = 'astrology_enabled';

  // Age Milestones (in days)
  static const int newbornPeriod = 28; // 0-28 gün: yenidoğan
  static const int infantPeriod = 365; // 0-12 ay: bebek
  static const int toddlerStart = 365; // 1-3 yaş: çocuk
  static const int preschoolStart = 1095; // 3-5 yaş: okul öncesi
  static const int totalTrackingDays = 1825; // 5 yaş = 1825 gün

  // Recommendation Categories
  static const List<String> recommendationCategories = [
    'Kitap',
    'Müzik',
    'Oyun',
    'Oyuncak',
    'Aktivite',
    'Gelişim',
  ];

  // Health Tracking
  static const List<String> vaccineTypes = [
    'Hepatit B',
    'BCG',
    'DaBT-İPA-Hib',
    'OPV',
    'Pnömokok',
    'MMR',
    'Suçiçeği',
    'Hepatit A',
    'Meningokok',
  ];

  // Turkish Cities
  static const List<String> turkishCities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkâri',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  // Astrological Signs
  static const List<String> zodiacSigns = [
    'Koç',
    'Boğa',
    'İkizler',
    'Yengeç',
    'Aslan',
    'Başak',
    'Terazi',
    'Akrep',
    'Yay',
    'Oğlak',
    'Kova',
    'Balık',
  ];

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
