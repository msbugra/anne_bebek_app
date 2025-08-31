import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Custom circular progress indicator with animation
class AnimatedCircularProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? color;
  final double strokeWidth;
  final Duration animationDuration;
  final Curve curve;

  const AnimatedCircularProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 4.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.primary;
    final defaultBackgroundColor = theme.colorScheme.surfaceContainerHighest;

    return CircularProgressIndicator(
          value: value,
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          color: color ?? defaultColor,
          strokeWidth: strokeWidth,
        )
        .animate()
        .scale(
          duration: animationDuration,
          curve: curve,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        )
        .fadeIn(duration: animationDuration, curve: curve);
  }
}

/// Custom linear progress indicator with animation
class AnimatedLinearProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? color;
  final double minHeight;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final Curve curve;

  const AnimatedLinearProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.minHeight = 4.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = theme.colorScheme.primary;
    final defaultBackgroundColor = theme.colorScheme.surfaceContainerHighest;

    return LinearProgressIndicator(
          value: value,
          backgroundColor: backgroundColor ?? defaultBackgroundColor,
          color: color ?? defaultColor,
          minHeight: minHeight,
          borderRadius: borderRadius,
        )
        .animate()
        .slideX(
          duration: animationDuration,
          curve: curve,
          begin: -1.0,
          end: 0.0,
        )
        .fadeIn(duration: animationDuration, curve: curve);
  }
}

/// Custom progress indicator with dots animation
class DotsProgressIndicator extends StatefulWidget {
  final int numberOfDots;
  final double dotSize;
  final Color? dotColor;
  final Duration animationDuration;
  final Curve curve;

  const DotsProgressIndicator({
    super.key,
    this.numberOfDots = 3,
    this.dotSize = 8.0,
    this.dotColor,
    this.animationDuration = const Duration(milliseconds: 800),
    this.curve = Curves.easeInOut,
  });

  @override
  State<DotsProgressIndicator> createState() => _DotsProgressIndicatorState();
}

class _DotsProgressIndicatorState extends State<DotsProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _animations = List.generate(widget.numberOfDots, (index) {
      final start = index / widget.numberOfDots;
      final end = (index + 1) / widget.numberOfDots;
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: widget.curve),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultColor = widget.dotColor ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.numberOfDots, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.dotSize,
              height: widget.dotSize,
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize / 2),
              decoration: BoxDecoration(
                color: defaultColor.withOpacity(_animations[index].value),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

/// Pulse progress indicator
class PulseProgressIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const PulseProgressIndicator({
    super.key,
    this.color,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulseProgressIndicator> createState() => _PulseProgressIndicatorState();
}

class _PulseProgressIndicatorState extends State<PulseProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
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
    final defaultColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: defaultColor.withOpacity(_animation.value * 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                color: defaultColor.withOpacity(_animation.value),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom progress bar with percentage and animation
class CustomProgressBar extends StatelessWidget {
  final double value;
  final double maxValue;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const CustomProgressBar({
    super.key,
    required this.value,
    required this.maxValue,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = theme.colorScheme.surfaceContainerHighest;
    final defaultProgressColor = theme.colorScheme.primary;
    final progressValue = (value / maxValue).clamp(0.0, 1.0);
    final percentage = (progressValue * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? defaultBackgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            child:
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.transparent,
                  color: progressColor ?? defaultProgressColor,
                ).animate().slideX(
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  begin: -1.0,
                  end: 0.0,
                ),
          ),
        ),
        if (showPercentage) ...[
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style:
                percentageStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

/// Loading overlay with progress indicator
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? overlayColor;
  final Widget? customIndicator;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.overlayColor,
    this.customIndicator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultOverlayColor = theme.colorScheme.surface.withOpacity(0.8);

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? defaultOverlayColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  customIndicator ?? const AnimatedCircularProgressIndicator(),
                  if (loadingText != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      loadingText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(duration: const Duration(milliseconds: 200)),
      ],
    );
  }
}
