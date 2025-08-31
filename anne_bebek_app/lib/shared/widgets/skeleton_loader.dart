import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader widget for loading states
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 16.0,
    this.borderRadius,
    this.margin,
    this.baseColor,
    this.highlightColor,
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

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: baseColor ?? defaultBaseColor,
        highlightColor: highlightColor ?? defaultHighlightColor,
        child: Container(
          decoration: BoxDecoration(
            color: baseColor ?? defaultBaseColor,
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader for text lines
class SkeletonText extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final EdgeInsetsGeometry? margin;

  const SkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight = 16.0,
    this.spacing = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          final isLastLine = index == lines - 1;
          return Container(
            margin: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
            child: SkeletonLoader(
              width: isLastLine
                  ? MediaQuery.of(context).size.width * 0.7
                  : double.infinity,
              height: lineHeight,
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }),
      ),
    );
  }
}

/// Skeleton loader for cards
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 120.0,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      child: SkeletonLoader(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}

/// Skeleton loader for list items
class SkeletonListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final EdgeInsetsGeometry? margin;

  const SkeletonListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (hasLeading) ...[
            const SkeletonLoader(
              width: 40.0,
              height: 40.0,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            const SizedBox(width: 16.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 16.0,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                const SizedBox(height: 8.0),
                SkeletonLoader(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 12.0,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: 16.0),
            const SkeletonLoader(
              width: 24.0,
              height: 24.0,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loader for profile/avatar
class SkeletonAvatar extends StatelessWidget {
  final double radius;
  final EdgeInsetsGeometry? margin;

  const SkeletonAvatar({super.key, this.radius = 30.0, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: SkeletonLoader(
        width: radius * 2,
        height: radius * 2,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Skeleton loader for buttons
class SkeletonButton extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonButton({
    super.key,
    this.width,
    this.height = 48.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: SkeletonLoader(
        width: width ?? double.infinity,
        height: height,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}

/// Skeleton loader for images
class SkeletonImage extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonImage({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: SkeletonLoader(
        width: width ?? double.infinity,
        height: height ?? 200.0,
        borderRadius: borderRadius ?? BorderRadius.circular(8.0),
      ),
    );
  }
}
