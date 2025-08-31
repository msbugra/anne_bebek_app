import 'package:flutter/material.dart';

/// Custom page transition types
enum PageTransitionType {
  fade,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scale,
  rotate,
  slideAndFade,
  zoom,
}

/// Custom page transitions for smooth navigation
class CustomPageTransitions {
  /// Get custom page route with specified transition
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    PageTransitionType transitionType = PageTransitionType.slideLeft,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          transitionType,
          animation,
          secondaryAnimation,
          child,
          curve,
        );
      },
    );
  }

  /// Build transition based on type
  static Widget _buildTransition(
    PageTransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    Curve curve,
  ) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.rotate:
        return RotationTransition(
          turns: Tween<double>(begin: -0.1, end: 0.0).animate(curvedAnimation),
          child: child,
        );

      case PageTransitionType.slideAndFade:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case PageTransitionType.zoom:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );
    }
  }
}

/// Hero animation utilities for smooth transitions between screens
class HeroAnimations {
  /// Create hero tag for consistent animations
  static String createTag(String baseTag, [String? suffix]) {
    return suffix != null ? '${baseTag}_$suffix' : baseTag;
  }

  /// Hero widget with custom flight animation
  static Hero createHero({
    required String tag,
    required Widget child,
    CreateRectTween? createRectTween,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    HeroPlaceholderBuilder? placeholderBuilder,
    bool transitionOnUserGestures = false,
  }) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween,
      flightShuttleBuilder: flightShuttleBuilder,
      placeholderBuilder: placeholderBuilder,
      transitionOnUserGestures: transitionOnUserGestures,
      child: child,
    );
  }

  /// Custom rect tween for hero animations
  static RectTween createSmoothRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  /// Custom flight shuttle builder for more control
  static Widget customFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 0.1,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: flightDirection == HeroFlightDirection.push
              ? toHeroContext.widget
              : fromHeroContext.widget,
        ),
      ),
    );
  }
}

/// Custom route observer for page transition analytics
class PageTransitionObserver extends NavigatorObserver {
  final List<String> _routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      _routeStack.add(route.settings.name!);
      _logTransition(
        'Push',
        route.settings.name!,
        previousRoute?.settings.name,
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name != null) {
      _routeStack.removeLast();
      _logTransition('Pop', route.settings.name!, previousRoute?.settings.name);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null && oldRoute?.settings.name != null) {
      final index = _routeStack.lastIndexOf(oldRoute!.settings.name!);
      if (index != -1) {
        _routeStack[index] = newRoute!.settings.name!;
      }
      _logTransition(
        'Replace',
        newRoute!.settings.name!,
        oldRoute.settings.name,
      );
    }
  }

  void _logTransition(String type, String to, String? from) {
    // Log transition for analytics
    debugPrint('Page Transition: $type - From: $from -> To: $to');
  }

  /// Get current route stack
  List<String> get routeStack => List.unmodifiable(_routeStack);

  /// Get current route
  String? get currentRoute => _routeStack.isNotEmpty ? _routeStack.last : null;
}

/// Extension methods for easy page navigation with custom transitions
extension CustomNavigation on BuildContext {
  /// Navigate to page with custom transition
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    PageTransitionType transitionType = PageTransitionType.slideLeft,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.of(this).push(
      CustomPageTransitions.createRoute(
        page: page,
        transitionType: transitionType,
        duration: duration,
        curve: curve,
      ),
    );
  }

  /// Replace current page with custom transition
  Future<T?>
  pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    PageTransitionType transitionType = PageTransitionType.slideLeft,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement(
      CustomPageTransitions.createRoute(
        page: page,
        transitionType: transitionType,
        duration: duration,
        curve: curve,
      ),
      result: result,
    );
  }

  /// Push and remove until with custom transition
  Future<T?> pushAndRemoveUntilWithTransition<T extends Object?>(
    Widget page,
    RoutePredicate predicate, {
    PageTransitionType transitionType = PageTransitionType.slideLeft,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.of(this).pushAndRemoveUntil(
      CustomPageTransitions.createRoute(
        page: page,
        transitionType: transitionType,
        duration: duration,
        curve: curve,
      ),
      predicate,
    );
  }
}
