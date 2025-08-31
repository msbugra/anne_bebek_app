import 'package:flutter/material.dart';
import '../../core/constants/ad_constants.dart';
import '../../core/services/ad_service.dart';

/// Reklam state yönetimi provider'ı
/// Uygulama genelinde reklam durumunu yönetir ve UI güncellemelerini sağlar
class AdProvider with ChangeNotifier {
  final AdService _adService = AdService();

  // Reklam durumları
  AdStatus _bannerAdStatus = AdStatus.loading;
  AdStatus _interstitialAdStatus = AdStatus.loading;
  AdStatus _rewardedAdStatus = AdStatus.loading;

  // Reklam sayaçları ve zamanlayıcılar
  int _sessionAdCount = 0;
  DateTime? _lastAdShownTime;
  bool _isAdEnabled = true;

  // Reklam koşulları
  bool _canShowInterstitialAd = false;
  bool _canShowRewardedAd = false;

  // Getters
  AdStatus get bannerAdStatus => _bannerAdStatus;
  AdStatus get interstitialAdStatus => _interstitialAdStatus;
  AdStatus get rewardedAdStatus => _rewardedAdStatus;

  bool get isAdEnabled => _isAdEnabled;
  bool get canShowInterstitialAd => _canShowInterstitialAd;
  bool get canShowRewardedAd => _canShowRewardedAd;

  int get sessionAdCount => _sessionAdCount;
  DateTime? get lastAdShownTime => _lastAdShownTime;

  AdService get adService => _adService;

  /// Provider'ı başlatır
  Future<void> initialize() async {
    await _adService.initialize();

    // Banner reklamı otomatik olarak yükle
    await loadBannerAd();

    if (AdConstants.enableAdLogging) {
      debugPrint('🎯 AdProvider: Initialized successfully');
    }
  }

  /// Banner reklamı yükler
  Future<void> loadBannerAd() async {
    if (!_isAdEnabled) return;

    _bannerAdStatus = AdStatus.loading;
    notifyListeners();

    try {
      await _adService.loadBannerAd(
        onStatusChanged: (status) {
          _bannerAdStatus = status;
          notifyListeners();

          if (AdConstants.enableAdLogging) {
            debugPrint('📺 Banner ad status changed: $status');
          }
        },
      );
    } catch (e) {
      _bannerAdStatus = AdStatus.failed;
      notifyListeners();
      debugPrint('❌ AdProvider: Failed to load banner ad: $e');
    }
  }

  /// Interstitial reklamı yükler
  Future<void> loadInterstitialAd() async {
    if (!_isAdEnabled) return;

    _interstitialAdStatus = AdStatus.loading;
    notifyListeners();

    try {
      await _adService.loadInterstitialAd(
        onStatusChanged: (status) {
          _interstitialAdStatus = status;
          _canShowInterstitialAd = status == AdStatus.loaded;
          notifyListeners();

          if (AdConstants.enableAdLogging) {
            debugPrint('📱 Interstitial ad status changed: $status');
          }
        },
      );
    } catch (e) {
      _interstitialAdStatus = AdStatus.failed;
      _canShowInterstitialAd = false;
      notifyListeners();
      debugPrint('❌ AdProvider: Failed to load interstitial ad: $e');
    }
  }

  /// Rewarded reklamı yükler
  Future<void> loadRewardedAd() async {
    if (!_isAdEnabled) return;

    _rewardedAdStatus = AdStatus.loading;
    notifyListeners();

    try {
      await _adService.loadRewardedAd(
        onStatusChanged: (status) {
          _rewardedAdStatus = status;
          _canShowRewardedAd = status == AdStatus.loaded;
          notifyListeners();

          if (AdConstants.enableAdLogging) {
            debugPrint('🎁 Rewarded ad status changed: $status');
          }
        },
      );
    } catch (e) {
      _rewardedAdStatus = AdStatus.failed;
      _canShowRewardedAd = false;
      notifyListeners();
      debugPrint('❌ AdProvider: Failed to load rewarded ad: $e');
    }
  }

  /// Interstitial reklamı gösterir
  Future<void> showInterstitialAd() async {
    if (!_canShowInterstitialAd || !_isAdEnabled) {
      debugPrint('⚠️ AdProvider: Cannot show interstitial ad');
      return;
    }

    // Reklam sıklığı kontrolü
    if (!canShowAdByFrequency()) {
      debugPrint('⚠️ AdProvider: Ad frequency limit reached');
      return;
    }

    try {
      await _adService.showInterstitialAd();
      _sessionAdCount++;
      _lastAdShownTime = DateTime.now();
      _canShowInterstitialAd = false;

      // Reklam gösterildikten sonra yenisini yükle
      Future.delayed(const Duration(seconds: 5), () {
        loadInterstitialAd();
      });

      if (AdConstants.enableAdLogging) {
        debugPrint('📱 Interstitial ad shown successfully');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ AdProvider: Failed to show interstitial ad: $e');
    }
  }

  /// Rewarded reklamı gösterir
  Future<void> showRewardedAd() async {
    if (!_canShowRewardedAd || !_isAdEnabled) {
      debugPrint('⚠️ AdProvider: Cannot show rewarded ad');
      return;
    }

    try {
      await _adService.showRewardedAd();
      _sessionAdCount++;
      _lastAdShownTime = DateTime.now();
      _canShowRewardedAd = false;

      // Reklam gösterildikten sonra yenisini yükle
      Future.delayed(const Duration(seconds: 5), () {
        loadRewardedAd();
      });

      if (AdConstants.enableAdLogging) {
        debugPrint('🎁 Rewarded ad shown successfully');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ AdProvider: Failed to show rewarded ad: $e');
    }
  }

  /// Reklam sıklığını kontrol eder
  bool canShowAdByFrequency() {
    if (_lastAdShownTime == null) return true;

    final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
    final canShowByTime =
        timeSinceLastAd.inSeconds >= AdConstants.minTimeBetweenAds;
    final canShowByCount = _sessionAdCount < AdConstants.maxAdsPerSession;

    return canShowByTime && canShowByCount;
  }

  /// Reklamları etkinleştirir/devre dışı bırakır
  void setAdEnabled(bool enabled) {
    _isAdEnabled = enabled;
    notifyListeners();

    if (AdConstants.enableAdLogging) {
      debugPrint('🎯 AdProvider: Ads ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Otomatik reklam yenileme timer'ını başlatır
  void startAutoRefresh() {
    _adService.startBannerRefreshTimer();
  }

  /// Otomatik reklam yenileme timer'ını durdurur
  void stopAutoRefresh() {
    _adService.stopBannerRefreshTimer();
  }

  /// Belirli bir ekranda reklam gösterilip gösterilmeyeceğini kontrol eder
  bool shouldShowAdOnScreen(String screenName) {
    if (!_isAdEnabled) return false;

    // Reklam gösterilecek ekranları kontrol et
    return AdConstants.bannerAdScreens.contains(screenName);
  }

  /// Reklam gelirini takip eder (gelecekte analytics ile entegre edilecek)
  void trackAdRevenue({
    required String adUnitId,
    required String adType,
    required double revenue,
    String currency = 'USD',
  }) {
    if (!AdConstants.enableAdAnalytics) return;

    // Burada analytics servisi ile entegre edilebilir
    if (AdConstants.enableAdLogging) {
      debugPrint('💰 Ad revenue tracked: $revenue $currency for $adType');
    }
  }

  /// Reklam gösterim istatistiklerini sıfırlar
  void resetAdStatistics() {
    _sessionAdCount = 0;
    _lastAdShownTime = null;
    notifyListeners();

    if (AdConstants.enableAdLogging) {
      debugPrint('📊 Ad statistics reset');
    }
  }

  /// Tüm reklamları yeniden yükler
  Future<void> reloadAllAds() async {
    if (!_isAdEnabled) return;

    await Future.wait([loadBannerAd(), loadInterstitialAd(), loadRewardedAd()]);

    if (AdConstants.enableAdLogging) {
      debugPrint('🔄 All ads reloaded');
    }
  }

  /// Provider dispose edildiğinde temizlik yapar
  @override
  void dispose() {
    stopAutoRefresh();
    _adService.dispose();
    super.dispose();

    if (AdConstants.enableAdLogging) {
      debugPrint('🧹 AdProvider disposed');
    }
  }
}
