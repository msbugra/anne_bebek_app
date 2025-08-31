import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// Adaptive card that adjusts its layout based on screen size
class AdaptiveCard extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? content;
  final Widget? trailing;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final VoidCallback? onTap;
  final double? elevation;

  const AdaptiveCard({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.content,
    this.trailing,
    this.actions,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = context.screenSize;

    // Responsive padding
    final defaultPadding = context.responsivePadding(
      small: 12.0,
      medium: 16.0,
      large: 20.0,
      extraLarge: 24.0,
    );

    final defaultMargin = context.responsiveMargin(
      small: 4.0,
      medium: 6.0,
      large: 8.0,
      extraLarge: 12.0,
    );

    // Responsive border radius
    final defaultBorderRadius = BorderRadius.circular(
      context.responsiveValue(
        small: 8.0,
        medium: 12.0,
        large: 16.0,
        extraLarge: 20.0,
      ),
    );

    // Responsive elevation
    final defaultElevation = context.responsiveValue(
      small: 1.0,
      medium: 2.0,
      large: 3.0,
      extraLarge: 4.0,
    );

    return Container(
      margin: margin ?? defaultMargin,
      child: Card(
        elevation: elevation ?? defaultElevation,
        color: backgroundColor ?? theme.cardTheme.color,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? defaultBorderRadius,
        ),
        shadowColor: shadow?.color ?? theme.shadowColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? defaultBorderRadius,
          child: Padding(
            padding: padding ?? defaultPadding,
            child: _buildContent(context, screenSize),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ScreenSize screenSize) {
    // For small screens, use vertical layout
    if (screenSize == ScreenSize.small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null || title != null || subtitle != null)
            Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) title!,
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        subtitle!,
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          if (content != null) ...[const SizedBox(height: 12), content!],
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildActions(context, screenSize),
          ],
        ],
      );
    }

    // For medium and larger screens, use horizontal layout
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 16)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || subtitle != null)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) title!,
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            subtitle!,
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 16),
                      trailing!,
                    ],
                  ],
                ),
              if (content != null) ...[const SizedBox(height: 12), content!],
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildActions(context, screenSize),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ScreenSize screenSize) {
    if (actions == null || actions!.isEmpty) return const SizedBox.shrink();

    // For small screens, stack actions vertically
    if (screenSize == ScreenSize.small) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions!.map((action) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: action,
          );
        }).toList(),
      );
    }

    // For larger screens, arrange actions horizontally
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions!.map((action) {
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: action,
        );
      }).toList(),
    );
  }
}

/// Compact version of AdaptiveCard for list items
class AdaptiveListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AdaptiveListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = context.screenSize;

    final defaultPadding = context.responsivePadding(
      small: 12.0,
      medium: 16.0,
      large: 20.0,
    );

    return Card(
      color: backgroundColor ?? theme.cardTheme.color,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable adaptive card
class ExpandableAdaptiveCard extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget expandedContent;
  final List<Widget>? actions;
  final bool initiallyExpanded;
  final Duration animationDuration;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ExpandableAdaptiveCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.expandedContent,
    this.actions,
    this.initiallyExpanded = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.backgroundColor,
    this.padding,
    this.margin,
  });

  @override
  State<ExpandableAdaptiveCard> createState() => _ExpandableAdaptiveCardState();
}

class _ExpandableAdaptiveCardState extends State<ExpandableAdaptiveCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = context.screenSize;

    final defaultPadding = context.responsivePadding(
      small: 16.0,
      medium: 20.0,
      large: 24.0,
    );

    final defaultMargin = context.responsiveMargin(
      small: 4.0,
      medium: 6.0,
      large: 8.0,
    );

    return Container(
      margin: widget.margin ?? defaultMargin,
      child: Card(
        color: widget.backgroundColor ?? theme.cardTheme.color,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: widget.padding ?? defaultPadding,
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.title,
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 4),
                            widget.subtitle!,
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),

            // Expandable content
            SizeTransition(
              sizeFactor: _animation,
              child: Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: widget.padding ?? defaultPadding,
                    child: widget.expandedContent,
                  ),
                  if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: widget.padding ?? defaultPadding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: widget.actions!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
