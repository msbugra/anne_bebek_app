import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final String? title;
  final String? subtitle;
  final Color activeColor;
  final Color inactiveColor;
  final bool enabled;
  final Widget? leading;
  final Widget? trailing;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor = const Color(0xFF6B4EFF),
    this.inactiveColor = const Color(0xFFE5E7EB),
    this.enabled = true,
    this.leading,
    this.trailing,
  });

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    _colorAnimation =
        ColorTween(
          begin: widget.inactiveColor,
          end: widget.activeColor,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget switchWidget = GestureDetector(
      onTap: widget.enabled ? () => widget.onChanged(!widget.value) : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _colorAnimation.value,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: AppConstants.shortAnimation,
                  curve: Curves.easeInOut,
                  left: widget.value ? 26 : 2,
                  top: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (widget.title == null && widget.subtitle == null) {
      return switchWidget;
    }

    return InkWell(
      onTap: widget.enabled ? () => widget.onChanged(!widget.value) : null,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  if (widget.title != null)
                    Text(
                      widget.title!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: widget.enabled
                            ? const Color(0xFF1A1B23)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: widget.enabled
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            switchWidget,
            if (widget.trailing != null) ...[
              const SizedBox(width: 12),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// Custom Checkbox
class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;
  final String? title;
  final String? subtitle;
  final Color activeColor;
  final Color checkColor;
  final bool enabled;
  final Widget? leading;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.activeColor = const Color(0xFF6B4EFF),
    this.checkColor = Colors.white,
    this.enabled = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    Widget checkbox = AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: value ? activeColor : Colors.transparent,
        border: Border.all(
          color: value ? activeColor : const Color(0xFFD1D5DB),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: value
          ? Icon(Icons.check_rounded, size: 16, color: checkColor)
          : null,
    );

    if (title == null && subtitle == null) {
      return GestureDetector(
        onTap: enabled ? () => onChanged(!value) : null,
        child: checkbox,
      );
    }

    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            checkbox,
            const SizedBox(width: 12),
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: enabled
                            ? const Color(0xFF1A1B23)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: enabled
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
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

// Radio Button Group
class CustomRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<RadioOption<T>> options;
  final Function(T?) onChanged;
  final String? title;
  final Axis direction;
  final Color activeColor;
  final bool enabled;

  const CustomRadioGroup({
    super.key,
    this.value,
    required this.options,
    required this.onChanged,
    this.title,
    this.direction = Axis.vertical,
    this.activeColor = const Color(0xFF6B4EFF),
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (direction == Axis.vertical)
          Column(
            children: options.map((option) => _buildRadioItem(option)).toList(),
          )
        else
          Row(
            children: options
                .map((option) => Expanded(child: _buildRadioItem(option)))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildRadioItem(RadioOption<T> option) {
    final isSelected = value == option.value;

    return InkWell(
      onTap: enabled ? () => onChanged(option.value) : null,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppConstants.shortAnimation,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 20,
                color: isSelected ? activeColor : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: enabled
                          ? isSelected
                                ? activeColor
                                : const Color(0xFF1A1B23)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (option.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: enabled
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
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

class RadioOption<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const RadioOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}
