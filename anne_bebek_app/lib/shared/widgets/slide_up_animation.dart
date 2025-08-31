import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Slide up animasyonu ile child widget'ı gösteren widget
class SlideUpAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginY;
  final double endY;

  const SlideUpAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.beginY = 50.0,
    this.endY = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .slideY(
          begin: beginY / 100,
          end: endY / 100,
          duration: duration,
          curve: curve,
        )
        .fadeIn(duration: duration, curve: curve);
  }
}

/// Slide down animasyonu ile child widget'ı gösteren widget
class SlideDownAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginY;
  final double endY;

  const SlideDownAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.beginY = -50.0,
    this.endY = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .slideY(
          begin: beginY / 100,
          end: endY / 100,
          duration: duration,
          curve: curve,
        )
        .fadeIn(duration: duration, curve: curve);
  }
}

/// Slide left animasyonu ile child widget'ı gösteren widget
class SlideLeftAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginX;
  final double endX;

  const SlideLeftAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.beginX = 100.0,
    this.endX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .slideX(
          begin: beginX / 100,
          end: endX / 100,
          duration: duration,
          curve: curve,
        )
        .fadeIn(duration: duration, curve: curve);
  }
}

/// Slide right animasyonu ile child widget'ı gösteren widget
class SlideRightAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginX;
  final double endX;

  const SlideRightAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.beginX = -100.0,
    this.endX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .slideX(
          begin: beginX / 100,
          end: endX / 100,
          duration: duration,
          curve: curve,
        )
        .fadeIn(duration: duration, curve: curve);
  }
}

/// Staggered slide up animasyonu ile children listesini gösteren widget
class StaggeredSlideUpAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final double beginY;
  final double endY;

  const StaggeredSlideUpAnimation({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.staggerDelay = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
    this.beginY = 50.0,
    this.endY = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final itemDelay = delay + (staggerDelay * index);

        return SlideUpAnimation(
          delay: itemDelay,
          duration: duration,
          curve: curve,
          beginY: beginY,
          endY: endY,
          child: child,
        );
      }).toList(),
    );
  }
}
