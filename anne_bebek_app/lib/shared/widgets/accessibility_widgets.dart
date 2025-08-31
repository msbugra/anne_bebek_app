import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessible button with proper touch targets and screen reader support
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String? tooltip;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool enableFeedback;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double minTouchTargetSize;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.semanticLabel,
    this.tooltip,
    this.autofocus = false,
    this.focusNode,
    this.enableFeedback = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.minTouchTargetSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          onLongPress: onLongPress,
          autofocus: autofocus,
          focusNode: focusNode,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
            elevation: elevation ?? 2,
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            enableFeedback: enableFeedback,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Accessible text with proper contrast and screen reader support
class AccessibleText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const AccessibleText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? data,
      child: Text(
        data,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      ),
    );
  }
}

/// Accessible card with proper touch targets and focus management
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Clip? clipBehavior;
  final bool semanticContainer;
  final double minTouchTargetSize;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.semanticHint,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.margin,
    this.padding,
    this.clipBehavior,
    this.semanticContainer = true,
    this.minTouchTargetSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget card = Card(
      color: color,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      elevation: elevation ?? 1,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      borderOnForeground: borderOnForeground,
      margin: margin ?? const EdgeInsets.all(4),
      clipBehavior: clipBehavior,
      semanticContainer: semanticContainer,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      enabled: onTap != null,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        child: card,
      ),
    );
  }
}

/// Accessible list item with proper focus and screen reader support
class AccessibleListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;
  final double minTouchTargetSize;

  const AccessibleListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.selected = false,
    this.enabled = true,
    this.minTouchTargetSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      selected: selected,
      enabled: enabled,
      button: onTap != null,
      child: Container(
        constraints: BoxConstraints(minHeight: minTouchTargetSize),
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
          onLongPress: onLongPress,
          selected: selected,
          enabled: enabled,
        ),
      ),
    );
  }
}

/// Accessible form field with proper labels and hints
class AccessibleTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? semanticLabel;
  final String? semanticHint;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final bool autofocus;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.semanticLabel,
    this.semanticHint,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.autovalidateMode,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? labelText,
      hint: semanticHint ?? hintText,
      textField: true,
      enabled: enabled,
      readOnly: readOnly,
      child: TextFormField(
        controller: controller,
        decoration:
            decoration ??
            InputDecoration(
              labelText: labelText,
              hintText: hintText,
              helperText: helperText,
              errorText: errorText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
        obscureText: obscureText,
        enabled: enabled,
        readOnly: readOnly,
        maxLines: maxLines,
        minLines: minLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onTap: onTap,
        validator: validator,
        autovalidateMode: autovalidateMode,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

/// Accessible switch with proper labels
class AccessibleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final FocusNode? focusNode;
  final bool autofocus;

  const AccessibleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.semanticHint,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      toggled: value,
      enabled: onChanged != null,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor,
        activeTrackColor: activeTrackColor,
        inactiveThumbColor: inactiveThumbColor,
        inactiveTrackColor: inactiveTrackColor,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

/// Accessible checkbox with proper labels
class AccessibleCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? activeColor;
  final Color? checkColor;
  final Color? fillColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final double minTouchTargetSize;

  const AccessibleCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
    this.semanticHint,
    this.activeColor,
    this.checkColor,
    this.fillColor,
    this.focusNode,
    this.autofocus = false,
    this.minTouchTargetSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      checked: value,
      enabled: onChanged != null,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        alignment: Alignment.center,
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: activeColor,
          checkColor: checkColor,
          fillColor: fillColor != null
              ? WidgetStateProperty.all(fillColor)
              : null,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
      ),
    );
  }
}

/// Accessible radio button with proper labels
class AccessibleRadio<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? activeColor;
  final Color? fillColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final double minTouchTargetSize;

  const AccessibleRadio({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.semanticLabel,
    this.semanticHint,
    this.activeColor,
    this.fillColor,
    this.focusNode,
    this.autofocus = false,
    this.minTouchTargetSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      checked: value == groupValue,
      enabled: onChanged != null,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minTouchTargetSize,
          minHeight: minTouchTargetSize,
        ),
        alignment: Alignment.center,
        child: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          activeColor: activeColor,
          fillColor: fillColor != null
              ? WidgetStateProperty.all(fillColor)
              : null,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
      ),
    );
  }
}

/// Accessible slider with proper labels and hints
class AccessibleSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final FocusNode? focusNode;
  final bool autofocus;

  const AccessibleSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.semanticLabel,
    this.semanticHint,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      value: value.toStringAsFixed(1),
      increasedValue: (value + 0.1).clamp(min, max).toStringAsFixed(1),
      decreasedValue: (value - 0.1).clamp(min, max).toStringAsFixed(1),
      enabled: onChanged != null,
      child: Slider(
        value: value,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
        thumbColor: thumbColor,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}

/// Accessible progress indicator with proper labels
class AccessibleProgressIndicator extends StatelessWidget {
  final double? value;
  final String? semanticLabel;
  final String? semanticHint;
  final Color? backgroundColor;
  final Color? color;
  final double strokeWidth;
  final double? strokeAlign;

  const AccessibleProgressIndicator({
    super.key,
    this.value,
    this.semanticLabel,
    this.semanticHint,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 4.0,
    this.strokeAlign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressValue = value ?? 0.0;

    return Semantics(
      label: semanticLabel ?? 'Progress indicator',
      hint: semanticHint,
      value: '${(progressValue * 100).round()}%',
      child: CircularProgressIndicator(
        value: value,
        backgroundColor:
            backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        color: color ?? theme.colorScheme.primary,
        strokeWidth: strokeWidth,
        strokeAlign: strokeAlign ?? CircularProgressIndicator.strokeAlignCenter,
      ),
    );
  }
}

/// Accessible image with alt text and description
class AccessibleImage extends StatelessWidget {
  final ImageProvider image;
  final String? semanticLabel;
  final String? semanticHint;
  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  final Map<String, String>? headers;
  final int? cacheWidth;
  final int? cacheHeight;

  const AccessibleImage({
    super.key,
    required this.image,
    this.semanticLabel,
    this.semanticHint,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.filterQuality = FilterQuality.low,
    this.isAntiAlias = false,
    this.headers,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      image: true,
      child: Image(
        image: image,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        isAntiAlias: isAntiAlias,
      ),
    );
  }
}

/// Utility class for accessibility helpers
class AccessibilityUtils {
  /// Check if high contrast mode is enabled
  static bool isHighContrastEnabled(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Get appropriate text color for accessibility
  static Color getAccessibleTextColor(BuildContext context, bool isOnDark) {
    final theme = Theme.of(context);
    return isOnDark ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary;
  }

  /// Ensure minimum touch target size
  static double ensureMinTouchTarget(double size, [double minSize = 48.0]) {
    return size < minSize ? minSize : size;
  }

  /// Create accessible focus node with proper traversal
  static FocusNode createAccessibleFocusNode({
    String? debugLabel,
    bool skipTraversal = false,
    bool canRequestFocus = true,
  }) {
    return FocusNode(
      debugLabel: debugLabel,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
    );
  }

  /// Announce content to screen readers
  static void announceToScreenReader(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if screen reader is enabled
  static Future<bool> isScreenReaderEnabled() async {
    try {
      await SemanticsService.announce('', TextDirection.ltr);
      return true;
    } catch (e) {
      return false;
    }
  }
}
