import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Custom shimmer effect widget with advanced features
class ShimmerEffect extends StatelessWidget {
  final Widget child;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;
  final double begin;
  final double end;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.ltr,
    this.begin = 0.0,
    this.end = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBaseColor = theme.brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
    final defaultHighlightColor = theme.brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[600]!;

    return Shimmer(
      period: period,
      direction: direction,
      gradient: LinearGradient(
        colors: [
          baseColor ?? defaultBaseColor,
          highlightColor ?? defaultHighlightColor,
          baseColor ?? defaultBaseColor,
        ],
        stops: [begin, 0.5, end],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      child: child,
    );
  }
}

/// Rainbow shimmer effect for special loading states
class RainbowShimmerEffect extends StatelessWidget {
  final Widget child;
  final Duration period;

  const RainbowShimmerEffect({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 2000),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      period: period,
      gradient: const LinearGradient(
        colors: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.indigo,
          Colors.purple,
          Colors.red,
        ],
        stops: [0.0, 0.14, 0.28, 0.42, 0.57, 0.71, 0.85, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      child: child,
    );
  }
}

/// Pulse shimmer effect that creates a breathing effect
class PulseShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration period;
  final Color? baseColor;
  final Color? highlightColor;

  const PulseShimmerEffect({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1200),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<PulseShimmerEffect> createState() => _PulseShimmerEffectState();
}

class _PulseShimmerEffectState extends State<PulseShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.period, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBaseColor = theme.brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
    final defaultHighlightColor = theme.brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[600]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Shimmer(
          period: widget.period,
          gradient: LinearGradient(
            colors: [
              widget.baseColor ?? defaultBaseColor,
              Color.lerp(
                widget.baseColor ?? defaultBaseColor,
                widget.highlightColor ?? defaultHighlightColor,
                _animation.value,
              )!,
              widget.baseColor ?? defaultBaseColor,
            ],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Loading shimmer for specific UI patterns
class LoadingShimmer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Widget? loadingWidget;

  const LoadingShimmer({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    return loadingWidget ?? ShimmerEffect(child: child);
  }
}

/// Shimmer effect for text with customizable appearance
class ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;
  final Duration period;

  const ShimmerText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    final textStyle = style ?? defaultStyle!;

    return ShimmerEffect(
      period: period,
      child: Text(
        text,
        style: textStyle,
        maxLines: maxLines,
        textAlign: textAlign,
      ),
    );
  }
}

/// Shimmer effect for containers with rounded corners
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Duration period;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: ShimmerEffect(
        period: period,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
