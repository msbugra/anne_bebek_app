import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

enum ButtonType { primary, secondary, outline, text }

enum ButtonSize { small, medium, large }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final bool loading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.iconRight = false,
    this.loading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.padding,
    this.elevation,
    this.borderRadius,
  });

  // Factory constructors for common button types
  factory CustomButton.primary({
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool iconRight = false,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      icon: icon,
      iconRight: iconRight,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  factory CustomButton.secondary({
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool iconRight = false,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      icon: icon,
      iconRight: iconRight,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  factory CustomButton.outline({
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool iconRight = false,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.outline,
      size: size,
      icon: icon,
      iconRight: iconRight,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  factory CustomButton.text({
    required String text,
    VoidCallback? onPressed,
    ButtonSize size = ButtonSize.medium,
    IconData? icon,
    bool iconRight = false,
    bool loading = false,
    bool fullWidth = false,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.text,
      size: size,
      icon: icon,
      iconRight: iconRight,
      loading: loading,
      fullWidth: fullWidth,
    );
  }

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.loading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapCancel();
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (widget.padding != null) return widget.padding!;

    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = widget.onPressed != null && !widget.loading;

    Widget buttonChild = _buildButtonContent(context);

    // Button container with gradient support
    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: widget.fullWidth ? double.infinity : null,
        decoration: _getButtonDecoration(colorScheme, isEnabled),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? widget.onPressed : null,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppConstants.borderRadius),
            child: Padding(padding: _getPadding(), child: buttonChild),
          ),
        ),
      ),
    );

    return button;
  }

  Widget _buildButtonContent(BuildContext context) {
    if (widget.loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getFontSize(),
            height: _getFontSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(Theme.of(context).colorScheme),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('Yükleniyor...', style: _getTextStyle()),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.iconRight
            ? [
                Text(widget.text, style: _getTextStyle()),
                const SizedBox(width: 8),
                Icon(
                  widget.icon,
                  size: _getFontSize() + 2,
                  color: _getTextColor(Theme.of(context).colorScheme),
                ),
              ]
            : [
                Icon(
                  widget.icon,
                  size: _getFontSize() + 2,
                  color: _getTextColor(Theme.of(context).colorScheme),
                ),
                const SizedBox(width: 8),
                Text(widget.text, style: _getTextStyle()),
              ],
      );
    }

    return Text(
      widget.text,
      style: _getTextStyle(),
      textAlign: TextAlign.center,
    );
  }

  TextStyle _getTextStyle() {
    return GoogleFonts.inter(
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w600,
      color: _getTextColor(Theme.of(context).colorScheme),
    );
  }

  Color _getTextColor(ColorScheme colorScheme) {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    final isEnabled = widget.onPressed != null && !widget.loading;

    switch (widget.type) {
      case ButtonType.primary:
        return isEnabled ? Colors.white : Colors.white.withOpacity(0.7);
      case ButtonType.secondary:
        return isEnabled
            ? colorScheme.onSurface
            : colorScheme.onSurface.withOpacity(0.5);
      case ButtonType.outline:
        return isEnabled
            ? colorScheme.primary
            : colorScheme.primary.withOpacity(0.5);
      case ButtonType.text:
        return isEnabled
            ? colorScheme.primary
            : colorScheme.primary.withOpacity(0.5);
    }
  }

  BoxDecoration _getButtonDecoration(ColorScheme colorScheme, bool isEnabled) {
    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: widget.gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors!,
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isEnabled
                      ? [const Color(0xFF6B4EFF), const Color(0xFF8B5FFF)]
                      : [
                          const Color(0xFF6B4EFF).withOpacity(0.5),
                          const Color(0xFF8B5FFF).withOpacity(0.5),
                        ],
                ),
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B4EFF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );

      case ButtonType.secondary:
        return BoxDecoration(
          color: widget.backgroundColor ?? colorScheme.surface,
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isEnabled
                ? colorScheme.outline
                : colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: isEnabled && !_isPressed
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );

      case ButtonType.outline:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isEnabled
                ? colorScheme.primary
                : colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
        );

      case ButtonType.text:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppConstants.borderRadius),
        );
    }
  }
}

// Floating Action Button benzeri özel button
class CustomFloatingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool mini;

  const CustomFloatingButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
    this.mini = false,
  });

  @override
  State<CustomFloatingButton> createState() => _CustomFloatingButtonState();
}

class _CustomFloatingButtonState extends State<CustomFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = widget.mini ? 40.0 : widget.size;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor ?? const Color(0xFF6B4EFF),
                widget.backgroundColor?.withOpacity(0.8) ??
                    const Color(0xFF8B5FFF),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: (widget.backgroundColor ?? const Color(0xFF6B4EFF))
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              borderRadius: BorderRadius.circular(size / 2),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.foregroundColor ?? Colors.white,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
