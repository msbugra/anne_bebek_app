import 'package:flutter/material.dart';
import '../../core/constants/ad_constants.dart';
import '../../shared/providers/ad_provider.dart';
import '../../shared/widgets/banner_ad_widget.dart';

/// Reklam yerleştirme yöneticisi
/// Uygulama genelinde reklamların stratejik yerleştirilmesini yönetir
class AdPlacementManager {
  final AdProvider _adProvider;

  AdPlacementManager(this._adProvider);

  /// Ana ekran için banner reklam widget'ı döndürür
  Widget? getHomeScreenBannerAd({
    EdgeInsetsGeometry? margin,
    Function(AdStatus)? onAdStatusChanged,
  }) {
    if (!_adProvider.shouldShowAdOnScreen('home')) {
      return null;
    }

    return BannerAdWidget(
      position: AdPosition.bottom,
      margin: margin ?? const EdgeInsets.all(16.0),
      onAdStatusChanged: onAdStatusChanged,
    );
  }

  /// Sağlık dashboard ekranı için banner reklam widget'ı döndürür
  Widget? getHealthDashboardBannerAd({
    EdgeInsetsGeometry? margin,
    Function(AdStatus)? onAdStatusChanged,
  }) {
    if (!_adProvider.shouldShowAdOnScreen('health_dashboard')) {
      return null;
    }

    return AdaptiveBannerAdWidget(
      position: AdPosition.bottom,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      onAdStatusChanged: onAdStatusChanged,
    );
  }

  /// Öneriler ekranı için banner reklam widget'ı döndürür
  Widget? getRecommendationsBannerAd({
    EdgeInsetsGeometry? margin,
    Function(AdStatus)? onAdStatusChanged,
  }) {
    if (!_adProvider.shouldShowAdOnScreen('recommendations')) {
      return null;
    }

    return BannerAdWidget(
      position: AdPosition.bottom,
      margin: margin ?? const EdgeInsets.all(16.0),
      onAdStatusChanged: onAdStatusChanged,
    );
  }

  /// Kültür ekranı için banner reklam widget'ı döndürür
  Widget? getCultureBannerAd({
    EdgeInsetsGeometry? margin,
    Function(AdStatus)? onAdStatusChanged,
  }) {
    if (!_adProvider.shouldShowAdOnScreen('culture')) {
      return null;
    }

    return AdaptiveBannerAdWidget(
      position: AdPosition.bottom,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      onAdStatusChanged: onAdStatusChanged,
    );
  }

  /// Astroloji ekranı için banner reklam widget'ı döndürür
  Widget? getAstrologyBannerAd({
    EdgeInsetsGeometry? margin,
    Function(AdStatus)? onAdStatusChanged,
  }) {
    if (!_adProvider.shouldShowAdOnScreen('astrology')) {
      return null;
    }

    return BannerAdWidget(
      position: AdPosition.bottom,
      margin: margin ?? const EdgeInsets.all(16.0),
      onAdStatusChanged: onAdStatusChanged,
    );
  }

  /// Belirli bir ekran için reklam widget'ı döndürür
  Widget? getBannerAdForScreen(
    String screenName, {
    EdgeInsetsGeometry? margin,
    Function(AdStatus)? onAdStatusChanged,
    bool adaptive = false,
  }) {
    if (!_adProvider.shouldShowAdOnScreen(screenName)) {
      return null;
    }

    final adMargin = margin ?? const EdgeInsets.all(16.0);

    if (adaptive) {
      return AdaptiveBannerAdWidget(
        position: AdPosition.bottom,
        margin: adMargin,
        onAdStatusChanged: onAdStatusChanged,
      );
    } else {
      return BannerAdWidget(
        position: AdPosition.bottom,
        margin: adMargin,
        onAdStatusChanged: onAdStatusChanged,
      );
    }
  }

  /// Interstitial reklam gösterimini yönetir
  Future<void> tryShowInterstitialAd({
    String? triggerReason,
    int minSessionTime = 30,
  }) async {
    // Oturum süresi kontrolü
    final sessionStartTime = _getSessionStartTime();
    if (sessionStartTime != null) {
      final sessionDuration = DateTime.now().difference(sessionStartTime);
      if (sessionDuration.inSeconds < minSessionTime) {
        if (AdConstants.enableAdLogging) {
          debugPrint(
            '⏰ Session too short for interstitial ad: ${sessionDuration.inSeconds}s',
          );
        }
        return;
      }
    }

    // Reklam sıklığı kontrolü
    if (!_adProvider.canShowAdByFrequency()) {
      if (AdConstants.enableAdLogging) {
        debugPrint('⏰ Ad frequency limit reached for interstitial ad');
      }
      return;
    }

    // Interstitial reklamı göster
    await _adProvider.showInterstitialAd();

    if (AdConstants.enableAdLogging) {
      debugPrint('📱 Interstitial ad shown for: $triggerReason');
    }
  }

  /// Rewarded reklam gösterimini yönetir
  Future<void> tryShowRewardedAd({
    String? triggerReason,
    Function? onRewardEarned,
  }) async {
    if (!_adProvider.canShowRewardedAd) {
      if (AdConstants.enableAdLogging) {
        debugPrint('⚠️ Rewarded ad not available');
      }
      return;
    }

    // Rewarded reklamı göster
    await _adProvider.showRewardedAd();

    if (AdConstants.enableAdLogging) {
      debugPrint('🎁 Rewarded ad shown for: $triggerReason');
    }

    // Ödül kazanma callback'i
    if (onRewardEarned != null) {
      onRewardEarned();
    }
  }

  /// Ekran geçişlerinde interstitial reklam gösterimini kontrol eder
  Future<void> handleScreenTransition(
    String fromScreen,
    String toScreen, {
    bool forceShow = false,
  }) async {
    // Belirli ekran geçişlerinde reklam göster
    final transitionRules = {
      'home': ['health_dashboard', 'recommendations', 'culture'],
      'health_dashboard': ['home', 'recommendations'],
      'recommendations': ['health_dashboard', 'culture'],
      'culture': ['home', 'astrology'],
    };

    final shouldShowAd =
        transitionRules[fromScreen]?.contains(toScreen) ?? false;

    if (shouldShowAd || forceShow) {
      await tryShowInterstitialAd(
        triggerReason: 'Screen transition: $fromScreen -> $toScreen',
      );
    }
  }

  /// Kullanıcı aksiyonlarına göre reklam gösterimini yönetir
  Future<void> handleUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    // Belirli aksiyonlarda reklam göster
    final adTriggerActions = [
      'premium_feature_access',
      'data_export',
      'advanced_analysis',
      'detailed_report',
    ];

    if (adTriggerActions.contains(action)) {
      await tryShowInterstitialAd(triggerReason: 'User action: $action');
    }

    // Premium özellikler için rewarded reklam öner
    final rewardedTriggerActions = [
      'unlock_premium_content',
      'extend_trial',
      'bonus_features',
    ];

    if (rewardedTriggerActions.contains(action)) {
      await tryShowRewardedAd(
        triggerReason: 'Premium action: $action',
        onRewardEarned: () {
          // Ödül kazanma işlemi burada yönetilebilir
          if (AdConstants.enableAdLogging) {
            debugPrint('🎉 Reward earned for action: $action');
          }
        },
      );
    }
  }

  /// Reklam gösterim istatistiklerini takip eder
  void trackAdImpression({
    required String screenName,
    required AdType adType,
    String? adUnitId,
  }) {
    if (!AdConstants.enableAdAnalytics) return;

    // Burada analytics servisi ile entegre edilebilir
    if (AdConstants.enableAdLogging) {
      debugPrint('📊 Ad impression tracked: $adType on $screenName');
    }
  }

  /// Reklam tıklama olaylarını takip eder
  void trackAdClick({
    required String screenName,
    required AdType adType,
    String? adUnitId,
  }) {
    if (!AdConstants.enableAdAnalytics) return;

    // Burada analytics servisi ile entegre edilebilir
    if (AdConstants.enableAdLogging) {
      debugPrint('👆 Ad click tracked: $adType on $screenName');
    }
  }

  /// Reklam gelirini takip eder
  void trackAdRevenue({
    required String screenName,
    required AdType adType,
    required double revenue,
    String currency = 'USD',
    String? adUnitId,
  }) {
    if (!AdConstants.enableAdAnalytics) return;

    _adProvider.trackAdRevenue(
      adUnitId: adUnitId ?? '',
      adType: adType.name,
      revenue: revenue,
      currency: currency,
    );

    if (AdConstants.enableAdLogging) {
      debugPrint(
        '💰 Ad revenue tracked: $revenue $currency for $adType on $screenName',
      );
    }
  }

  /// Oturum başlangıç zamanını alır (shared preferences'dan)
  DateTime? _getSessionStartTime() {
    // Bu kısım shared preferences ile entegre edilebilir
    // Şimdilik null döndürüyoruz
    return null;
  }

  /// Reklam optimizasyon önerileri üretir
  Map<String, dynamic> getAdOptimizationSuggestions() {
    final suggestions = <String, dynamic>{};

    // Reklam gösterim sıklığı analizi
    if (_adProvider.sessionAdCount > AdConstants.maxAdsPerSession) {
      suggestions['frequency'] = 'Reklam gösterim sıklığı çok yüksek';
    }

    // Reklam başarısı analizi
    if (_adProvider.bannerAdStatus == AdStatus.failed) {
      suggestions['banner'] = 'Banner reklam yükleme sorunları var';
    }

    if (_adProvider.interstitialAdStatus == AdStatus.failed) {
      suggestions['interstitial'] = 'Interstitial reklam yükleme sorunları var';
    }

    return suggestions;
  }

  /// Reklam ayarlarını optimize eder
  void optimizeAdSettings() {
    // Reklam sıklığını optimize et
    if (_adProvider.sessionAdCount > AdConstants.maxAdsPerSession * 0.8) {
      // Reklam sıklığını azalt
      if (AdConstants.enableAdLogging) {
        debugPrint('⚙️ Optimizing ad frequency');
      }
    }

    // Banner reklam yenileme sıklığını optimize et
    if (_adProvider.bannerAdStatus == AdStatus.failed) {
      // Yenileme sıklığını azalt
      if (AdConstants.enableAdLogging) {
        debugPrint('⚙️ Optimizing banner refresh rate');
      }
    }
  }
}

/// Reklam yerleştirme için extension methods
extension AdPlacementExtensions on BuildContext {
  /// Mevcut context için reklam yerleştirme yöneticisini alır
  AdPlacementManager? getAdPlacementManager() {
    try {
      final adProvider = AdProvider();
      return AdPlacementManager(adProvider);
    } catch (e) {
      debugPrint('❌ Failed to get AdPlacementManager: $e');
      return null;
    }
  }
}
