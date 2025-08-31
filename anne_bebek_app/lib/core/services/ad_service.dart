import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../constants/ad_constants.dart';

/// Ana reklam servis sınıfı
/// Tüm reklam işlemlerini yönetir ve merkezi bir kontrol noktası sağlar
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Reklam durumları
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Durum kontrolü
  bool _isInitialized = false;
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;

  // Callbacks
  Function(AdStatus)? _onBannerAdStatusChanged;
  Function(AdStatus)? _onInterstitialAdStatusChanged;
  Function(AdStatus)? _onRewardedAdStatusChanged;

  // Reklam sayacı ve zamanlayıcılar
  int _adRequestCount = 0;
  DateTime? _lastAdRequestTime;
  Timer? _bannerRefreshTimer;

  /// Servisi başlatır ve Mobile Ads SDK'sını initialize eder
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Web ve desteklenmeyen platformlarda reklamları devre dışı bırak
    if (!_adsSupportedPlatform) {
      _isInitialized = true;
      if (AdConstants.enableAdLogging) {
        debugPrint('🎯 AdService: Platform not supported for ads - disabled');
      }
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;

      if (AdConstants.enableAdLogging) {
        debugPrint('🎯 AdService: Mobile Ads SDK initialized successfully');
      }

      // Test cihazlarını ayarla (geliştirme için)
      if (AdConstants.enableTestAds) {
        await _configureTestDevices();
      }
    } catch (e) {
      debugPrint('❌ AdService: Failed to initialize Mobile Ads SDK: $e');
      rethrow;
    }
  }

  /// Test cihazlarını konfigüre eder
  Future<void> _configureTestDevices() async {
    final RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: [
        'YOUR_TEST_DEVICE_ID_HERE',
      ], // Gerçek test cihaz ID'si eklenebilir
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);
  }

  /// Banner reklamı yükler
  Future<void> loadBannerAd({
    AdSize? size,
    Function(AdStatus)? onStatusChanged,
  }) async {
    // Desteklenmeyen platformlarda reklam yükleme
    if (!_adsSupportedPlatform) {
      _onBannerAdStatusChanged = onStatusChanged;
      _onBannerAdStatusChanged?.call(AdStatus.failed);
      if (AdConstants.enableAdLogging) {
        debugPrint('⚠️ Banner ad not supported on this platform');
      }
      return;
    }

    if (!_isInitialized) await initialize();

    _onBannerAdStatusChanged = onStatusChanged;
    _onBannerAdStatusChanged?.call(AdStatus.loading);

    // Mevcut banner reklamı dispose et
    await disposeBannerAd();

    try {
      // Reklam yükleme sıklığını kontrol et
      if (!_canRequestAd()) {
        throw Exception('Ad request rate limit exceeded');
      }

      _bannerAd = BannerAd(
        adUnitId: AdConstants.bannerAdUnitId,
        size: size ?? AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            _onBannerAdStatusChanged?.call(AdStatus.loaded);
            if (AdConstants.enableAdLogging) {
              final bannerAd = ad as BannerAd;
              debugPrint(
                '✅ Banner ad loaded successfully with size: ${bannerAd.size.width}x${bannerAd.size.height}',
              );
            }
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            _onBannerAdStatusChanged?.call(AdStatus.failed);
            ad.dispose();
            if (AdConstants.enableAdLogging) {
              debugPrint('❌ Banner ad failed to load: $error');
            }
          },
          onAdOpened: (ad) {
            if (AdConstants.enableAdLogging) {
              debugPrint('📱 Banner ad opened');
            }
          },
          onAdClosed: (ad) {
            if (AdConstants.enableAdLogging) {
              debugPrint('❌ Banner ad closed');
            }
          },
        ),
      );

      await _bannerAd!.load();
      _adRequestCount++;
      _lastAdRequestTime = DateTime.now();
    } catch (e) {
      _isBannerAdLoaded = false;
      _onBannerAdStatusChanged?.call(AdStatus.failed);
      debugPrint('❌ Failed to load banner ad: $e');
    }
  }

  /// Interstitial reklamı yükler
  Future<void> loadInterstitialAd({Function(AdStatus)? onStatusChanged}) async {
    // Desteklenmeyen platformlarda reklam yükleme
    if (!_adsSupportedPlatform) {
      _onInterstitialAdStatusChanged = onStatusChanged;
      _onInterstitialAdStatusChanged?.call(AdStatus.failed);
      if (AdConstants.enableAdLogging) {
        debugPrint('⚠️ Interstitial ad not supported on this platform');
      }
      return;
    }

    if (!_isInitialized) await initialize();

    _onInterstitialAdStatusChanged = onStatusChanged;
    _onInterstitialAdStatusChanged?.call(AdStatus.loading);

    // Mevcut interstitial reklamı dispose et
    await disposeInterstitialAd();

    try {
      if (!_canRequestAd()) {
        throw Exception('Ad request rate limit exceeded');
      }

      InterstitialAd.load(
        adUnitId: AdConstants.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _onInterstitialAdStatusChanged?.call(AdStatus.loaded);

            // Event listener'ları ekle
            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
                  onAdShowedFullScreenContent: (ad) {
                    _onInterstitialAdStatusChanged?.call(AdStatus.showing);
                  },
                  onAdDismissedFullScreenContent: (ad) {
                    _onInterstitialAdStatusChanged?.call(AdStatus.dismissed);
                    disposeInterstitialAd();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    _onInterstitialAdStatusChanged?.call(AdStatus.failed);
                    disposeInterstitialAd();
                  },
                );

            if (AdConstants.enableAdLogging) {
              debugPrint('✅ Interstitial ad loaded successfully');
            }
          },
          onAdFailedToLoad: (error) {
            _isInterstitialAdLoaded = false;
            _onInterstitialAdStatusChanged?.call(AdStatus.failed);
            if (AdConstants.enableAdLogging) {
              debugPrint('❌ Interstitial ad failed to load: $error');
            }
          },
        ),
      );

      _adRequestCount++;
      _lastAdRequestTime = DateTime.now();
    } catch (e) {
      _isInterstitialAdLoaded = false;
      _onInterstitialAdStatusChanged?.call(AdStatus.failed);
      debugPrint('❌ Failed to load interstitial ad: $e');
    }
  }

  /// Rewarded reklamı yükler
  Future<void> loadRewardedAd({Function(AdStatus)? onStatusChanged}) async {
    // Desteklenmeyen platformlarda reklam yükleme
    if (!_adsSupportedPlatform) {
      _onRewardedAdStatusChanged = onStatusChanged;
      _onRewardedAdStatusChanged?.call(AdStatus.failed);
      if (AdConstants.enableAdLogging) {
        debugPrint('⚠️ Rewarded ad not supported on this platform');
      }
      return;
    }

    if (!_isInitialized) await initialize();

    _onRewardedAdStatusChanged = onStatusChanged;
    _onRewardedAdStatusChanged?.call(AdStatus.loading);

    // Mevcut rewarded reklamı dispose et
    await disposeRewardedAd();

    try {
      if (!_canRequestAd()) {
        throw Exception('Ad request rate limit exceeded');
      }

      RewardedAd.load(
        adUnitId: AdConstants.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            _onRewardedAdStatusChanged?.call(AdStatus.loaded);

            // Event listener'ları ekle
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _onRewardedAdStatusChanged?.call(AdStatus.showing);
              },
              onAdDismissedFullScreenContent: (ad) {
                _onRewardedAdStatusChanged?.call(AdStatus.dismissed);
                disposeRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _onRewardedAdStatusChanged?.call(AdStatus.failed);
                disposeRewardedAd();
              },
            );

            if (AdConstants.enableAdLogging) {
              debugPrint('✅ Rewarded ad loaded successfully');
            }
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdLoaded = false;
            _onRewardedAdStatusChanged?.call(AdStatus.failed);
            if (AdConstants.enableAdLogging) {
              debugPrint('❌ Rewarded ad failed to load: $error');
            }
          },
        ),
      );

      _adRequestCount++;
      _lastAdRequestTime = DateTime.now();
    } catch (e) {
      _isRewardedAdLoaded = false;
      _onRewardedAdStatusChanged?.call(AdStatus.failed);
      debugPrint('❌ Failed to load rewarded ad: $e');
    }
  }

  /// Banner reklamı gösterir
  Widget? getBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return AdWidget(ad: _bannerAd!);
    }
    return null;
  }

  /// Interstitial reklamı gösterir
  Future<void> showInterstitialAd() async {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      debugPrint('⚠️ Interstitial ad is not loaded');
    }
  }

  /// Rewarded reklamı gösterir
  Future<void> showRewardedAd() async {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          if (AdConstants.enableAdLogging) {
            debugPrint(
              '🎁 User earned reward: ${reward.amount} ${reward.type}',
            );
          }
        },
      );
    } else {
      debugPrint('⚠️ Rewarded ad is not loaded');
    }
  }

  /// Reklam yükleme sıklığını kontrol eder
  bool _canRequestAd() {
    if (_lastAdRequestTime == null) return true;

    final timeSinceLastRequest = DateTime.now().difference(_lastAdRequestTime!);
    final requestsPerMinute =
        _adRequestCount / (timeSinceLastRequest.inSeconds / 60);

    return requestsPerMinute < AdConstants.maxAdRequestsPerMinute;
  }

  /// Banner reklam yenileme timer'ını başlatır
  void startBannerRefreshTimer() {
    _bannerRefreshTimer?.cancel();
    _bannerRefreshTimer = Timer.periodic(
      Duration(seconds: AdConstants.bannerAdRefreshInterval),
      (timer) {
        if (_isBannerAdLoaded) {
          loadBannerAd(onStatusChanged: _onBannerAdStatusChanged);
        }
      },
    );
  }

  /// Banner reklam yenileme timer'ını durdurur
  void stopBannerRefreshTimer() {
    _bannerRefreshTimer?.cancel();
    _bannerRefreshTimer = null;
  }

  /// Banner reklamı dispose eder
  Future<void> disposeBannerAd() async {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  /// Interstitial reklamı dispose eder
  Future<void> disposeInterstitialAd() async {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;
  }

  /// Rewarded reklamı dispose eder
  Future<void> disposeRewardedAd() async {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdLoaded = false;
  }

  /// Tüm reklamları dispose eder ve servisi temizler
  Future<void> dispose() async {
    stopBannerRefreshTimer();
    await disposeBannerAd();
    await disposeInterstitialAd();
    await disposeRewardedAd();
    _isInitialized = false;

    if (AdConstants.enableAdLogging) {
      debugPrint('🧹 AdService disposed');
    }
  }

  // Getter'lar
  bool get isInitialized => _isInitialized;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  bool get _adsSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS; // GMA supports macOS
  }
}
