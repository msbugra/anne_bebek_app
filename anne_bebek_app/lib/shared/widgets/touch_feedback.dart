import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced touch feedback widget with haptic feedback and visual effects
class TouchFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration animationDuration;
  final double scaleFactor;
  final HapticFeedbackType hapticType;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final bool enableFeedback;
  final bool enableHaptic;

  const TouchFeedback({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
    this.hapticType = HapticFeedbackType.lightImpact,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.enableFeedback = true,
    this.enableHaptic = true,
  });

  @override
  State<TouchFeedback> createState() => _TouchFeedbackState();
}

class _TouchFeedbackState extends State<TouchFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableFeedback) {
      _controller.forward();
    }
    if (widget.enableHaptic) {
      _triggerHapticFeedback();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableFeedback) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enableFeedback) {
      _controller.reverse();
    }
  }

  void _triggerHapticFeedback() {
    switch (widget.hapticType) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap != null ? () {} : null,
            onLongPress: widget.onLongPress,
            splashColor: widget.splashColor ?? theme.splashColor,
            highlightColor: widget.highlightColor ?? theme.highlightColor,
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

/// Enhanced button with touch feedback
class FeedbackButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final HapticFeedbackType hapticType;
  final double scaleFactor;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final bool enableHaptic;
  final bool enableFeedback;

  const FeedbackButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.hapticType = HapticFeedbackType.lightImpact,
    this.scaleFactor = 0.95,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.enableHaptic = true,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return TouchFeedback(
      onTap: onPressed,
      onLongPress: onLongPress,
      hapticType: hapticType,
      scaleFactor: scaleFactor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      borderRadius: borderRadius,
      enableHaptic: enableHaptic,
      enableFeedback: enableFeedback,
      child: child,
    );
  }
}

/// Smooth scrolling list view with enhanced physics
class SmoothScrollView extends StatelessWidget {
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

  const SmoothScrollView({
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
      physics: physics ?? const SmoothScrollPhysics(),
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      semanticChildCount: semanticChildCount,
      // dragStartBehavior: dragStartBehavior, // Removed as it's not available in this Flutter version
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      children: children,
    );
  }
}

/// Custom scroll physics for smooth scrolling
class SmoothScrollPhysics extends ScrollPhysics {
  const SmoothScrollPhysics({super.parent});

  @override
  SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Smooth out the scrolling by applying a curve
    if (offset.abs() > 0) {
      final direction = offset.sign;
      final magnitude = offset.abs();
      final smoothedMagnitude =
          magnitude * (1 - (magnitude / 1000).clamp(0.0, 0.5));
      return direction * smoothedMagnitude;
    }
    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Smooth boundary handling
    if (value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    } else if (value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Create smoother ballistic simulation
    final tolerance = toleranceFor(position);
    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    return BouncingScrollSimulation(
      position: position.pixels,
      velocity: velocity * 0.8, // Reduce velocity for smoother feel
      leadingExtent: position.minScrollExtent,
      trailingExtent: position.maxScrollExtent,
      spring: SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 100.0,
        ratio: 1.1, // Slightly more damping for smoother stop
      ),
    );
  }
}

/// Enhanced scroll behavior for better touch experience
class EnhancedScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const SmoothScrollPhysics();
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 8.0,
      radius: const Radius.circular(4.0),
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      showLeading: true,
      showTrailing: true,
      child: child,
    );
  }
}

/// Touch ripple effect widget
class TouchRipple extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? splashColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const TouchRipple({
    super.key,
    required this.child,
    this.onTap,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor ?? theme.splashColor,
        highlightColor: highlightColor ?? theme.highlightColor,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

/// Swipe gesture detector with haptic feedback
class SwipeFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final double swipeThreshold;
  final HapticFeedbackType hapticType;

  const SwipeFeedback({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
    this.onSwipeDown,
    this.swipeThreshold = 50.0,
    this.hapticType = HapticFeedbackType.lightImpact,
  });

  @override
  State<SwipeFeedback> createState() => _SwipeFeedbackState();
}

class _SwipeFeedbackState extends State<SwipeFeedback> {
  double _startX = 0.0;
  double _startY = 0.0;

  void _onPanStart(DragStartDetails details) {
    _startX = details.globalPosition.dx;
    _startY = details.globalPosition.dy;
  }

  void _onPanEnd(DragEndDetails details) {
    final endX = details.globalPosition.dx;
    final endY = details.globalPosition.dy;

    final deltaX = endX - _startX;
    final deltaY = endY - _startY;

    if (deltaX.abs() > widget.swipeThreshold ||
        deltaY.abs() > widget.swipeThreshold) {
      _triggerHapticFeedback();

      if (deltaX.abs() > deltaY.abs()) {
        // Horizontal swipe
        if (deltaX > 0 && widget.onSwipeRight != null) {
          widget.onSwipeRight!();
        } else if (deltaX < 0 && widget.onSwipeLeft != null) {
          widget.onSwipeLeft!();
        }
      } else {
        // Vertical swipe
        if (deltaY > 0 && widget.onSwipeDown != null) {
          widget.onSwipeDown!();
        } else if (deltaY < 0 && widget.onSwipeUp != null) {
          widget.onSwipeUp!();
        }
      }
    }
  }

  void _triggerHapticFeedback() {
    switch (widget.hapticType) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}
