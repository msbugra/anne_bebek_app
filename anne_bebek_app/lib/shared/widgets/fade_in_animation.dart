import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Fade in animasyonu ile child widget'ı gösteren widget
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginOpacity;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.beginOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration, curve: curve, begin: beginOpacity);
  }
}

/// Staggered fade in animasyonu ile children listesini gösteren widget
class StaggeredFadeInAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final double beginOpacity;

  const StaggeredFadeInAnimation({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
    this.beginOpacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final itemDelay = delay + (staggerDelay * index);

        return FadeInAnimation(
          delay: itemDelay,
          duration: duration,
          curve: curve,
          beginOpacity: beginOpacity,
          child: child,
        );
      }).toList(),
    );
  }
}
