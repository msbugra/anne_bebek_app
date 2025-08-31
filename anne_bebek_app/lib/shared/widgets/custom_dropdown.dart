import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool required;
  final IconData prefixIcon;
  final bool enabled;
  final Widget? suffixIcon;
  final double maxHeight;
  final bool searchable;
  final String? searchHint;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.required = false,
    this.prefixIcon = Icons.keyboard_arrow_down_rounded,
    this.enabled = true,
    this.suffixIcon,
    this.maxHeight = 250,
    this.searchable = false,
    this.searchHint,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  List<DropdownItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
      _searchController.clear();
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isOpen) {
      _closeDropdown();
    }
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_overlayEntry != null) return;

    setState(() => _isOpen = true);
    _focusNode.requestFocus();
    _searchController.clear();
    _filteredItems = widget.items;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _removeOverlay();
    setState(() => _isOpen = false);
    _focusNode.unfocus();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => item.text.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((255 * 0.1).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    if (widget.searchable) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterItems,
                          decoration: InputDecoration(
                            hintText: widget.searchHint ?? 'Ara...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                    ],

                    // Items list
                    if (_filteredItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Sonuç bulunamadı',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected = widget.value == item.value;

                            return InkWell(
                              onTap: () {
                                widget.onChanged(item.value);
                                _closeDropdown();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFF6B4EFF,
                                        ).withAlpha((255 * 0.1).round())
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    if (item.icon != null) ...[
                                      Icon(
                                        item.icon,
                                        size: 20,
                                        color: isSelected
                                            ? const Color(0xFF6B4EFF)
                                            : const Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.text,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          color: isSelected
                                              ? const Color(0xFF6B4EFF)
                                              : const Color(0xFF1A1B23),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 20,
                                        color: Color(0xFF6B4EFF),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              children: widget.required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],

        CompositedTransformTarget(
          link: _layerLink,
          child: Focus(
            focusNode: _focusNode,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: widget.enabled
                      ? _isOpen
                            ? const Color(
                                0xFF6B4EFF,
                              ).withAlpha((255 * 0.05).round())
                            : const Color(0xFFF8F9FA)
                      : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  border: Border.all(
                    color: _isOpen
                        ? const Color(0xFF6B4EFF)
                        : const Color(0xFFE5E7EB),
                    width: _isOpen ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon !=
                        Icons.keyboard_arrow_down_rounded) ...[
                      Icon(
                        widget.prefixIcon,
                        color: widget.enabled
                            ? _isOpen
                                  ? const Color(0xFF6B4EFF)
                                  : const Color(0xFF6B7280)
                            : const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _getSelectedText(),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: widget.enabled
                              ? widget.value != null
                                    ? const Color(0xFF1A1B23)
                                    : const Color(0xFF9CA3AF)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    widget.suffixIcon ??
                        AnimatedRotation(
                          duration: AppConstants.shortAnimation,
                          turns: _isOpen ? 0.5 : 0,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: widget.enabled
                                ? _isOpen
                                      ? const Color(0xFF6B4EFF)
                                      : const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                            size: 20,
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getSelectedText() {
    if (widget.value == null) {
      return widget.hint ?? 'Seçiniz';
    }

    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => DropdownItem<T>(
        value: widget.value as T,
        text: widget.value.toString(),
      ),
    );

    return selectedItem.text;
  }
}

// Dropdown item model
class DropdownItem<T> {
  final T value;
  final String text;
  final IconData? icon;
  final Widget? trailing;

  const DropdownItem({
    required this.value,
    required this.text,
    this.icon,
    this.trailing,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

// Predefined dropdowns
class CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final Function(String?) onChanged;
  final String? label;
  final bool required;

  const CityDropdown({
    super.key,
    this.selectedCity,
    required this.onChanged,
    this.label = 'Şehir',
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final cityItems = AppConstants.turkishCities
        .map(
          (city) => DropdownItem<String>(
            value: city,
            text: city,
            icon: Icons.location_city_rounded,
          ),
        )
        .toList();

    return CustomDropdown<String>(
      label: label,
      hint: 'Şehir seçiniz',
      value: selectedCity,
      items: cityItems,
      onChanged: onChanged,
      required: required,
      prefixIcon: Icons.location_on_rounded,
      searchable: true,
      searchHint: 'Şehir ara...',
    );
  }
}

class GenderDropdown extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onChanged;
  final String? label;
  final bool required;

  const GenderDropdown({
    super.key,
    this.selectedGender,
    required this.onChanged,
    this.label = 'Cinsiyet',
    this.required = false,
  });

  static const List<DropdownItem<String>> genderItems = [
    DropdownItem<String>(
      value: 'male',
      text: 'Erkek',
      icon: Icons.male_rounded,
    ),
    DropdownItem<String>(
      value: 'female',
      text: 'Kız',
      icon: Icons.female_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      label: label,
      hint: 'Cinsiyet seçiniz',
      value: selectedGender,
      items: genderItems,
      onChanged: onChanged,
      required: required,
      prefixIcon: Icons.person_rounded,
    );
  }
}

class ZodiacDropdown extends StatelessWidget {
  final String? selectedZodiac;
  final Function(String?) onChanged;
  final String? label;
  final bool required;

  const ZodiacDropdown({
    super.key,
    this.selectedZodiac,
    required this.onChanged,
    this.label = 'Burç',
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final zodiacItems = AppConstants.zodiacSigns
        .map(
          (zodiac) => DropdownItem<String>(
            value: zodiac,
            text: zodiac,
            icon: Icons.star_rounded,
          ),
        )
        .toList();

    return CustomDropdown<String>(
      label: label,
      hint: 'Burç seçiniz',
      value: selectedZodiac,
      items: zodiacItems,
      onChanged: onChanged,
      required: required,
      prefixIcon: Icons.auto_awesome_rounded,
    );
  }
}
