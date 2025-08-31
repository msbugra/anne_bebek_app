import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/ad_constants.dart';
import '../../core/services/ad_service.dart';

/// Banner reklam widget'ı
/// Adaptive banner reklamları destekler ve responsive tasarıma uyar
class BannerAdWidget extends StatefulWidget {
  final AdPosition position;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Function(AdStatus)? onAdStatusChanged;

  const BannerAdWidget({
    super.key,
    this.position = AdPosition.bottom,
    this.height,
    this.margin,
    this.borderRadius,
    this.decoration,
    this.loadingWidget,
    this.errorWidget,
    this.onAdStatusChanged,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdService _adService = AdService();
  AdStatus _adStatus = AdStatus.loading;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBannerAd() async {
    setState(() {
      _isLoading = true;
      _adStatus = AdStatus.loading;
    });

    widget.onAdStatusChanged?.call(AdStatus.loading);

    try {
      await _adService.loadBannerAd(
        onStatusChanged: (status) {
          if (mounted) {
            setState(() {
              _adStatus = status;
              _isLoading = status == AdStatus.loading;
            });
            widget.onAdStatusChanged?.call(status);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _adStatus = AdStatus.failed;
          _isLoading = false;
        });
        widget.onAdStatusChanged?.call(AdStatus.failed);
      }
      debugPrint('❌ BannerAdWidget: Failed to load banner ad: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (_isLoading) {
      return _buildLoadingWidget(theme);
    }

    // Error state
    if (_adStatus == AdStatus.failed) {
      return _buildErrorWidget(theme);
    }

    // Success state - Banner reklamı göster
    final bannerWidget = _adService.getBannerAdWidget();

    if (bannerWidget == null) {
      return _buildErrorWidget(theme);
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.cardColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
        child: SizedBox(
          height: widget.height ?? AdConstants.bannerAdHeight,
          child: bannerWidget,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Container(
      height: widget.height ?? AdConstants.bannerAdHeight,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.cardColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
          ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      height: widget.height ?? AdConstants.bannerAdHeight,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.cardColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
          ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24),
            const SizedBox(height: 4),
            Text(
              'Reklam yüklenemedi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Adaptive Banner Ad Widget
/// Ekran boyutuna göre otomatik olarak banner reklam boyutu ayarlar
class AdaptiveBannerAdWidget extends StatefulWidget {
  final AdPosition position;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxDecoration? decoration;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Function(AdStatus)? onAdStatusChanged;

  const AdaptiveBannerAdWidget({
    super.key,
    this.position = AdPosition.bottom,
    this.margin,
    this.borderRadius,
    this.decoration,
    this.loadingWidget,
    this.errorWidget,
    this.onAdStatusChanged,
  });

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  final AdService _adService = AdService();
  AdStatus _adStatus = AdStatus.loading;
  bool _isLoading = true;
  AdSize? _adSize;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAdaptiveBannerAd() async {
    setState(() {
      _isLoading = true;
      _adStatus = AdStatus.loading;
    });

    widget.onAdStatusChanged?.call(AdStatus.loading);

    try {
      // Ekran genişliğini al
      final screenWidth = MediaQuery.of(context).size.width;

      // Adaptive banner boyutu hesapla
      final adSize =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            screenWidth.truncate(),
          );

      if (adSize == null) {
        debugPrint('Adaptive banner size could not be determined.');
        if (mounted) {
          setState(() {
            _adStatus = AdStatus.failed;
            _isLoading = false;
          });
          widget.onAdStatusChanged?.call(AdStatus.failed);
        }
        return;
      }

      _adSize = adSize;

      await _adService.loadBannerAd(
        size: _adSize,
        onStatusChanged: (status) {
          if (mounted) {
            setState(() {
              _adStatus = status;
              _isLoading = status == AdStatus.loading;
            });
            widget.onAdStatusChanged?.call(status);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _adStatus = AdStatus.failed;
          _isLoading = false;
        });
        widget.onAdStatusChanged?.call(AdStatus.failed);
      }
      debugPrint(
        '❌ AdaptiveBannerAdWidget: Failed to load adaptive banner ad: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (_isLoading) {
      return _buildLoadingWidget(theme);
    }

    // Error state
    if (_adStatus == AdStatus.failed) {
      return _buildErrorWidget(theme);
    }

    // Success state - Adaptive banner reklamı göster
    final bannerWidget = _adService.getBannerAdWidget();

    if (bannerWidget == null) {
      return _buildErrorWidget(theme);
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.cardColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
        child: SizedBox(
          height: _adSize?.height.toDouble() ?? AdConstants.bannerAdHeight,
          child: bannerWidget,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!;
    }

    return Container(
      height: AdConstants.bannerAdHeight,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.cardColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
          ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      height: AdConstants.bannerAdHeight,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: theme.cardColor,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8.0),
          ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24),
            const SizedBox(height: 4),
            Text(
              'Reklam yüklenemedi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
