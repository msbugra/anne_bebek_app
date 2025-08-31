/// Reklam sabitleri ve konfigürasyonları
class AdConstants {
  // Test reklam ID'leri (Google tarafından sağlanan)
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Production reklam ID'leri (AdMob hesabından alınacak)
  // Bu ID'ler gerçek uygulamada değiştirilmelidir
  static const String bannerAdUnitId =
      testBannerAdUnitId; // Production'da gerçek ID
  static const String interstitialAdUnitId =
      testInterstitialAdUnitId; // Production'da gerçek ID
  static const String rewardedAdUnitId =
      testRewardedAdUnitId; // Production'da gerçek ID

  // Reklam konfigürasyonları
  static const int bannerAdRefreshInterval = 30; // saniye
  static const int maxAdRequestsPerMinute = 5;
  static const int adLoadTimeout = 10; // saniye

  // Reklam gösterim koşulları
  static const int minTimeBetweenAds = 60; // saniye
  static const int maxAdsPerSession = 10;
  static const int minSessionTimeForAds = 30; // saniye

  // Banner reklam boyutları
  static const double bannerAdHeight = 50.0;
  static const double adaptiveBannerMinHeight = 50.0;
  static const double adaptiveBannerMaxHeight = 90.0;

  // Reklam yerleştirme stratejileri
  static const List<String> bannerAdScreens = [
    'home',
    'health_dashboard',
    'recommendations',
    'culture',
    'astrology',
  ];

  // Reklam gelir takibi
  static const String adRevenueEventName = 'ad_revenue';
  static const String adImpressionEventName = 'ad_impression';
  static const String adClickEventName = 'ad_click';

  // Hata kodları
  static const int adLoadErrorCode = 1001;
  static const int adShowErrorCode = 1002;
  static const int adTimeoutErrorCode = 1003;
  static const int adNetworkErrorCode = 1004;

  // Debug ayarları
  static const bool enableTestAds = true;
  static const bool enableAdLogging = true;
  static const bool enableAdAnalytics = true;
}

/// Reklam türleri enum'ı
enum AdType { banner, interstitial, rewarded, native }

/// Reklam durumu enum'ı
enum AdStatus { loading, loaded, failed, showing, dismissed }

/// Reklam yerleştirme pozisyonları
enum AdPosition { top, bottom, center, inline }

/// Reklam ağları
enum AdNetwork { admob, facebook, unity, applovin }
