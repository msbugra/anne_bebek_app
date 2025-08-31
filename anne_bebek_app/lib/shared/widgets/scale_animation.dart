import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Scale animasyonu ile child widget'ı gösteren widget
class ScaleAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const ScaleAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.elasticOut,
    this.beginScale = 0.8,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: Offset(endScale, endScale),
          duration: duration,
          curve: curve,
        )
        .fadeIn(duration: duration, curve: curve);
  }
}

/// Bounce scale animasyonu ile child widget'ı gösteren widget
class BounceScaleAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const BounceScaleAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.bounceOut,
    this.beginScale = 0.3,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: Offset(endScale, endScale),
          duration: duration,
          curve: curve,
        )
        .fadeIn(duration: duration, curve: curve);
  }
}

/// Pulse animasyonu ile child widget'ı gösteren widget
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
    this.beginScale = 0.8,
    this.endScale = 1.2,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    Future.delayed(widget.delay, () {
      _controller.repeat(reverse: true);
    });
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
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}

/// Staggered scale animasyonu ile children listesini gösteren widget
class StaggeredScaleAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const StaggeredScaleAnimation({
    super.key,
    required this.children,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 100),
    this.curve = Curves.elasticOut,
    this.beginScale = 0.8,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        final itemDelay = delay + (staggerDelay * index);

        return ScaleAnimation(
          delay: itemDelay,
          duration: duration,
          curve: curve,
          beginScale: beginScale,
          endScale: endScale,
          child: child,
        );
      }).toList(),
    );
  }
}

/// Hero animasyonu için özel widget
class HeroScaleAnimation extends StatelessWidget {
  final Widget child;
  final String tag;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  const HeroScaleAnimation({
    super.key,
    required this.child,
    required this.tag,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.elasticOut,
    this.beginScale = 0.8,
    this.endScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: ScaleAnimation(
        delay: delay,
        duration: duration,
        curve: curve,
        beginScale: beginScale,
        endScale: endScale,
        child: child,
      ),
    );
  }
}
