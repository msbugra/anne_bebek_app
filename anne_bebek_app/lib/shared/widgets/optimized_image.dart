import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized image widget with caching and lazy loading
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration? fadeInDuration;
  final bool useHero;
  final String? heroTag;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration,
    this.useHero = false,
    this.heroTag,
    this.backgroundColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeInOut,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color:
                backgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color:
                backgroundColor ??
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 48,
            ),
          ),
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    // Apply hero animation if enabled
    if (useHero && heroTag != null) {
      imageWidget = Hero(tag: heroTag!, child: imageWidget);
    }

    // Apply background color if provided
    if (backgroundColor != null) {
      imageWidget = Container(color: backgroundColor, child: imageWidget);
    }

    // Apply padding and margin
    if (padding != null || margin != null) {
      imageWidget = Container(
        padding: padding,
        margin: margin,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Optimized circular avatar with caching
class OptimizedCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? heroTag;

  const OptimizedCircleAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimaryContainer,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  child ?? Icon(Icons.person_rounded, size: radius * 0.8),
            )
          : child ?? Icon(Icons.person_rounded, size: radius * 0.8),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    return avatar;
  }
}

/// Lazy loading list view with pagination support
class LazyLoadingListView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Future<void> Function()? onLoadMore;
  final bool hasMoreData;
  final int loadMoreThreshold;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const LazyLoadingListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.onLoadMore,
    this.hasMoreData = false,
    this.loadMoreThreshold = 5,
    this.controller,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<LazyLoadingListView> createState() => _LazyLoadingListViewState();
}

class _LazyLoadingListViewState extends State<LazyLoadingListView> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || !widget.hasMoreData || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - (widget.loadMoreThreshold * 100.0);

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0 && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      itemCount: widget.itemCount + (widget.hasMoreData && _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          // Loading indicator
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Lazy loading grid view with pagination
class LazyLoadingGridView extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Future<void> Function()? onLoadMore;
  final bool hasMoreData;
  final int loadMoreThreshold;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const LazyLoadingGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.onLoadMore,
    this.hasMoreData = false,
    this.loadMoreThreshold = 5,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<LazyLoadingGridView> createState() => _LazyLoadingGridViewState();
}

class _LazyLoadingGridViewState extends State<LazyLoadingGridView> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || !widget.hasMoreData || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll - (widget.loadMoreThreshold * 100.0);

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0 && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      gridDelegate: widget.gridDelegate,
      itemCount: widget.itemCount + (widget.hasMoreData && _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.itemCount) {
          // Loading indicator
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        return widget.itemBuilder(context, index);
      },
    );
  }
}

/// Image preloader for better performance
class ImagePreloader {
  static final Map<String, bool> _preloadedImages = {};

  /// Preload an image
  static Future<void> preloadImage(String imageUrl) async {
    if (_preloadedImages.containsKey(imageUrl)) return;

    try {
      CachedNetworkImageProvider(imageUrl).resolve(ImageConfiguration.empty);
      _preloadedImages[imageUrl] = true;
    } catch (e) {
      _preloadedImages[imageUrl] = false;
    }
  }

  /// Preload multiple images
  static Future<void> preloadImages(List<String> imageUrls) async {
    await Future.wait(imageUrls.map((url) => preloadImage(url)));
  }

  /// Check if image is preloaded
  static bool isImagePreloaded(String imageUrl) {
    return _preloadedImages[imageUrl] ?? false;
  }

  /// Clear preloaded images cache
  static void clearCache() {
    _preloadedImages.clear();
    CachedNetworkImage.evictFromCache('');
  }
}
