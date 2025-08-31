import 'package:flutter/material.dart';

/// Screen size breakpoints for responsive design
enum ScreenSize {
  small(320, 'Small Phone'),
  medium(480, 'Medium Phone'),
  large(768, 'Large Phone/Small Tablet'),
  extraLarge(1024, 'Tablet'),
  ultraLarge(1440, 'Desktop');

  const ScreenSize(this.minWidth, this.description);
  final double minWidth;
  final String description;
}

/// Extension methods for responsive design
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get screen size category
  ScreenSize get screenSize {
    final width = screenWidth;
    if (width >= ScreenSize.ultraLarge.minWidth) return ScreenSize.ultraLarge;
    if (width >= ScreenSize.extraLarge.minWidth) return ScreenSize.extraLarge;
    if (width >= ScreenSize.large.minWidth) return ScreenSize.large;
    if (width >= ScreenSize.medium.minWidth) return ScreenSize.medium;
    return ScreenSize.small;
  }

  /// Check if screen is small
  bool get isSmallScreen => screenSize == ScreenSize.small;

  /// Check if screen is medium
  bool get isMediumScreen => screenSize == ScreenSize.medium;

  /// Check if screen is large
  bool get isLargeScreen => screenSize == ScreenSize.large;

  /// Check if screen is extra large
  bool get isExtraLargeScreen => screenSize == ScreenSize.extraLarge;

  /// Check if screen is ultra large
  bool get isUltraLargeScreen => screenSize == ScreenSize.ultraLarge;

  /// Check if device is tablet or larger
  bool get isTabletOrLarger => screenWidth >= ScreenSize.large.minWidth;

  /// Check if device is desktop
  bool get isDesktop => screenWidth >= ScreenSize.ultraLarge.minWidth;

  /// Get responsive value based on screen size
  T responsiveValue<T>({
    required T small,
    required T medium,
    required T large,
    T? extraLarge,
    T? ultraLarge,
  }) {
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium;
      case ScreenSize.large:
        return large;
      case ScreenSize.extraLarge:
        return extraLarge ?? large;
      case ScreenSize.ultraLarge:
        return ultraLarge ?? extraLarge ?? large;
    }
  }

  /// Get responsive padding
  EdgeInsets responsivePadding({
    double small = 16.0,
    double medium = 20.0,
    double large = 24.0,
    double? extraLarge,
    double? ultraLarge,
  }) {
    final value = responsiveValue(
      small: small,
      medium: medium,
      large: large,
      extraLarge: extraLarge,
      ultraLarge: ultraLarge,
    );
    return EdgeInsets.all(value);
  }

  /// Get responsive margin
  EdgeInsets responsiveMargin({
    double small = 8.0,
    double medium = 12.0,
    double large = 16.0,
    double? extraLarge,
    double? ultraLarge,
  }) {
    final value = responsiveValue(
      small: small,
      medium: medium,
      large: large,
      extraLarge: extraLarge,
      ultraLarge: ultraLarge,
    );
    return EdgeInsets.all(value);
  }

  /// Get responsive font size
  double responsiveFontSize({
    required double small,
    required double medium,
    required double large,
    double? extraLarge,
    double? ultraLarge,
  }) {
    return responsiveValue(
      small: small,
      medium: medium,
      large: large,
      extraLarge: extraLarge,
      ultraLarge: ultraLarge,
    );
  }
}

/// Responsive layout builder widget
class ResponsiveLayout extends StatelessWidget {
  final Widget small;
  final Widget? medium;
  final Widget? large;
  final Widget? extraLarge;
  final Widget? ultraLarge;

  const ResponsiveLayout({
    super.key,
    required this.small,
    this.medium,
    this.large,
    this.extraLarge,
    this.ultraLarge,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? medium ?? small;
      case ScreenSize.ultraLarge:
        return ultraLarge ?? extraLarge ?? large ?? medium ?? small;
    }
  }
}

/// Breakpoint builder for more granular control
class BreakpointBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const BreakpointBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;
    return builder(context, screenSize);
  }
}

/// Adaptive container that adjusts its size based on screen size
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double? smallWidth;
  final double? mediumWidth;
  final double? largeWidth;
  final double? extraLargeWidth;
  final double? ultraLargeWidth;
  final double? smallHeight;
  final double? mediumHeight;
  final double? largeHeight;
  final double? extraLargeHeight;
  final double? ultraLargeHeight;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.smallWidth,
    this.mediumWidth,
    this.largeWidth,
    this.extraLargeWidth,
    this.ultraLargeWidth,
    this.smallHeight,
    this.mediumHeight,
    this.largeHeight,
    this.extraLargeHeight,
    this.ultraLargeHeight,
    this.margin,
    this.padding,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    double? width;
    double? height;

    switch (screenSize) {
      case ScreenSize.small:
        width = smallWidth;
        height = smallHeight;
        break;
      case ScreenSize.medium:
        width = mediumWidth ?? smallWidth;
        height = mediumHeight ?? smallHeight;
        break;
      case ScreenSize.large:
        width = largeWidth ?? mediumWidth ?? smallWidth;
        height = largeHeight ?? mediumHeight ?? smallHeight;
        break;
      case ScreenSize.extraLarge:
        width = extraLargeWidth ?? largeWidth ?? mediumWidth ?? smallWidth;
        height = extraLargeHeight ?? largeHeight ?? mediumHeight ?? smallHeight;
        break;
      case ScreenSize.ultraLarge:
        width =
            ultraLargeWidth ??
            extraLargeWidth ??
            largeWidth ??
            mediumWidth ??
            smallWidth;
        height =
            ultraLargeHeight ??
            extraLargeHeight ??
            largeHeight ??
            mediumHeight ??
            smallHeight;
        break;
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int smallCrossAxisCount;
  final int mediumCrossAxisCount;
  final int largeCrossAxisCount;
  final int extraLargeCrossAxisCount;
  final int ultraLargeCrossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.smallCrossAxisCount = 2,
    this.mediumCrossAxisCount = 3,
    this.largeCrossAxisCount = 4,
    this.extraLargeCrossAxisCount = 5,
    this.ultraLargeCrossAxisCount = 6,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    int crossAxisCount;
    switch (screenSize) {
      case ScreenSize.small:
        crossAxisCount = smallCrossAxisCount;
        break;
      case ScreenSize.medium:
        crossAxisCount = mediumCrossAxisCount;
        break;
      case ScreenSize.large:
        crossAxisCount = largeCrossAxisCount;
        break;
      case ScreenSize.extraLarge:
        crossAxisCount = extraLargeCrossAxisCount;
        break;
      case ScreenSize.ultraLarge:
        crossAxisCount = ultraLargeCrossAxisCount;
        break;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      children: children,
    );
  }
}

/// Responsive flex layout
class ResponsiveFlex extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;

  const ResponsiveFlex({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = context.screenSize;

    // Adjust direction based on screen size for better UX
    Axis responsiveDirection = direction;
    if (screenSize == ScreenSize.small && direction == Axis.horizontal) {
      // On small screens, consider vertical layout for better space usage
      responsiveDirection = Axis.vertical;
    }

    return Flex(
      direction: responsiveDirection,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      children: children,
    );
  }
}
