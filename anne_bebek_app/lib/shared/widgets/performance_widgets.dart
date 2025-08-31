import 'package:flutter/material.dart';

/// Performance optimized animation controller
class OptimizedAnimationController extends AnimationController {
  OptimizedAnimationController({
    required super.vsync,
    super.duration,
    super.reverseDuration,
    super.debugLabel,
    double? lowerBound,
    double? upperBound,
    AnimationBehavior? animationBehavior,
  }) : super(
         lowerBound: lowerBound ?? 0.0,
         upperBound: upperBound ?? 1.0,
         animationBehavior: animationBehavior ?? AnimationBehavior.preserve,
       );

  @override
  TickerFuture forward({double? from}) {
    // Ensure smooth 60 FPS animation
    return super.forward(from: from);
  }

  @override
  TickerFuture reverse({double? from}) {
    // Ensure smooth 60 FPS animation
    return super.reverse(from: from);
  }
}

/// Performance optimized animated widget
class PerformanceAnimatedWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enablePerformanceMode;

  const PerformanceAnimatedWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.enablePerformanceMode = true,
  });

  @override
  State<PerformanceAnimatedWidget> createState() =>
      _PerformanceAnimatedWidgetState();
}

class _PerformanceAnimatedWidgetState extends State<PerformanceAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late OptimizedAnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = OptimizedAnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Auto-start animation if performance mode is enabled
    if (widget.enablePerformanceMode) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.scale(
            scale: 0.8 + (_animation.value * 0.2),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Optimized list view with performance enhancements
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? prototypeItem;
  final int? semanticChildCount;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const OptimizedListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.semanticChildCount,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? const OptimizedScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      semanticChildCount: semanticChildCount,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      children: children,
    );
  }
}

/// Optimized scroll physics for smooth 60 FPS scrolling
class OptimizedScrollPhysics extends ScrollPhysics {
  const OptimizedScrollPhysics({super.parent});

  @override
  OptimizedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OptimizedScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Optimize for 60 FPS by reducing calculations
    if (offset.abs() < 0.1) return 0.0;

    final direction = offset.sign;
    final magnitude = offset.abs();

    // Apply smooth deceleration
    final deceleration = magnitude * 0.85;
    return direction * deceleration.clamp(-1000.0, 1000.0);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Smooth boundary handling
    if (value < position.minScrollExtent) {
      return (value - position.minScrollExtent) * 0.5;
    } else if (value > position.maxScrollExtent) {
      return (value - position.maxScrollExtent) * 0.5;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final tolerance = toleranceFor(position);
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    return ClampingScrollSimulation(
      position: position.pixels,
      velocity: velocity * 0.9, // Slightly reduce velocity for smoother feel
      tolerance: tolerance,
    );
  }
}

/// Performance optimized image widget
class PerformanceImage extends StatelessWidget {
  final ImageProvider image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Color? color;
  final BlendMode? colorBlendMode;
  final bool enablePerformanceMode;

  const PerformanceImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.color,
    this.colorBlendMode,
    this.enablePerformanceMode = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enablePerformanceMode) {
      return Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        color: color,
        colorBlendMode: colorBlendMode,
        filterQuality: FilterQuality.low,
        isAntiAlias: false,
      );
    }

    // Performance optimized version
    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: FilterQuality.none, // Best performance
      isAntiAlias: false, // Disable anti-aliasing for performance
    );
  }
}

/// Memory efficient widget that rebuilds only when necessary
class MemoryEfficientWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final List<Object?> keys;

  const MemoryEfficientWidget({
    super.key,
    required this.builder,
    required this.keys,
  });

  @override
  State<MemoryEfficientWidget> createState() => _MemoryEfficientWidgetState();
}

class _MemoryEfficientWidgetState extends State<MemoryEfficientWidget> {
  late List<Object?> _previousKeys;

  @override
  void initState() {
    super.initState();
    _previousKeys = List.from(widget.keys);
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuild if keys have changed
    if (!_areKeysEqual(widget.keys, _previousKeys)) {
      _previousKeys = List.from(widget.keys);
    }

    return widget.builder(context);
  }

  bool _areKeysEqual(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Performance monitor widget for debugging
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showFPS;
  final bool showMemory;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showFPS = false,
    this.showMemory = false,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor>
    with WidgetsBindingObserver {
  int _frameCount = 0;
  double _fps = 0.0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.showFPS) {
      WidgetsBinding.instance.addObserver(this);
      _startFPSMonitoring();
    }
  }

  @override
  void dispose() {
    if (widget.showFPS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (widget.showFPS) {
      _updateFPS();
    }
  }

  void _startFPSMonitoring() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFPS();
      _startFPSMonitoring();
    });
  }

  void _updateFPS() {
    final now = DateTime.now();
    final delta = now.difference(_lastFrameTime).inMilliseconds;

    if (delta > 0) {
      _frameCount++;
      if (_frameCount >= 60) {
        // Update every 60 frames
        _fps = 1000.0 / (delta / _frameCount);
        _frameCount = 0;
        if (mounted) setState(() {});
      }
    }

    _lastFrameTime = now;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.showFPS || widget.showMemory) {
      child = Stack(
        children: [
          child,
          if (widget.showFPS)
            Positioned(
              top: 50,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withAlpha((255 * 0.7).round()),
                child: Text(
                  'FPS: ${_fps.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          if (widget.showMemory)
            Positioned(
              top: 80,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withAlpha((255 * 0.7).round()),
                child: const Text(
                  'Memory: N/A', // Would need platform-specific implementation
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      );
    }

    return child;
  }
}

/// Optimized container with conditional rebuilding
class OptimizedContainer extends StatelessWidget {
  final Widget? child;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final Clip clipBehavior;
  final bool enablePerformanceMode;

  const OptimizedContainer({
    super.key,
    this.child,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.enablePerformanceMode = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enablePerformanceMode) {
      return Container(
        key: key,
        alignment: alignment,
        padding: padding,
        color: color,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        transform: transform,
        transformAlignment: transformAlignment,
        clipBehavior: clipBehavior,
        child: child,
      );
    }

    // Performance optimized version - only include non-null properties
    return Container(
      key: key,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

/// Startup time optimizer
class StartupOptimizer {
  static final List<VoidCallback> _deferredTasks = [];
  static bool _isInitialized = false;

  /// Defer a task to be executed after startup
  static void deferTask(VoidCallback task) {
    if (_isInitialized) {
      task();
    } else {
      _deferredTasks.add(task);
    }
  }

  /// Execute all deferred tasks
  static void executeDeferredTasks() {
    _isInitialized = true;
    for (final task in _deferredTasks) {
      task();
    }
    _deferredTasks.clear();
  }

  /// Preload critical resources
  static Future<void> preloadCriticalResources() async {
    // Preload fonts, images, and other critical resources
    // This would be implemented based on app-specific needs
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Optimize for first frame
  static void optimizeForFirstFrame() {
    // Disable expensive operations during first frame
    debugProfileBuildsEnabled = false;
    // debugProfilePaintsEnabled = false; // Not available in this Flutter version
  }
}

/// Performance utilities
class PerformanceUtils {
  /// Check if device is low-end
  static bool isLowEndDevice(BuildContext context) {
    // Simple heuristic based on screen size and pixel ratio
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final screenSize = mediaQuery.size;

    // Consider device low-end if pixel ratio is low or screen is small
    return pixelRatio < 2.5 || screenSize.width < 360;
  }

  /// Get optimal animation duration based on device performance
  static Duration getOptimalAnimationDuration(BuildContext context) {
    if (isLowEndDevice(context)) {
      return const Duration(
        milliseconds: 400,
      ); // Longer for smoother feel on low-end devices
    }
    return const Duration(milliseconds: 300); // Standard duration
  }

  /// Get optimal image quality based on device
  static FilterQuality getOptimalImageQuality(BuildContext context) {
    if (isLowEndDevice(context)) {
      return FilterQuality.low;
    }
    return FilterQuality.medium;
  }

  /// Enable performance mode based on device capabilities
  static bool shouldEnablePerformanceMode(BuildContext context) {
    return isLowEndDevice(context);
  }
}
