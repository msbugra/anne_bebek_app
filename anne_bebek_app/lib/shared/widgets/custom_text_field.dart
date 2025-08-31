import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool showCharacterCount;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.showCharacterCount = false,
    this.initialValue,
    this.autovalidateMode,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Text(
                widget.label!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _hasError
                      ? colorScheme.error
                      : _isFocused
                      ? colorScheme.primary
                      : const Color(0xFF6B7280),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],

        // Text Field
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                validator: (value) {
                  final error = widget.validator?.call(value);
                  setState(() {
                    _hasError = error != null;
                  });
                  return error;
                },
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                inputFormatters: widget.inputFormatters,
                initialValue: widget.initialValue,
                autovalidateMode: widget.autovalidateMode,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: widget.enabled
                      ? const Color(0xFF1A1B23)
                      : const Color(0xFF9CA3AF),
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  helperText: widget.helperText,
                  counterText: widget.showCharacterCount ? null : '',
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _hasError
                              ? colorScheme.error
                              : _isFocused
                              ? colorScheme.primary
                              : const Color(0xFF9CA3AF),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: widget.onSuffixIconTap,
                          child: Icon(
                            widget.suffixIcon,
                            color: _hasError
                                ? colorScheme.error
                                : _isFocused
                                ? colorScheme.primary
                                : const Color(0xFF9CA3AF),
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: widget.enabled
                      ? _isFocused
                            ? colorScheme.primary.withOpacity(0.05)
                            : const Color(0xFFF8F9FA)
                      : const Color(0xFFF1F3F4),
                  contentPadding:
                      widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide(
                      color: const Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide(
                      color: const Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    borderSide: BorderSide(
                      color: const Color(0xFFE5E7EB).withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 16,
                  ),
                  helperStyle: GoogleFonts.inter(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                  errorStyle: GoogleFonts.inter(
                    color: colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Özel input formatters
class TurkishNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Sadece harflere ve boşluklara izin ver
    String filtered = newValue.text.replaceAll(
      RegExp(r'[^a-zA-ZçÇğĞıİöÖşŞüÜ\s]'),
      '',
    );

    // Her kelimenin ilk harfini büyük yap
    List<String> words = filtered.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] =
            words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
    }

    String result = words.join(' ');

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class NumericFormatter extends TextInputFormatter {
  final int? maxDigits;
  final bool allowDecimal;

  NumericFormatter({this.maxDigits, this.allowDecimal = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String filtered = allowDecimal
        ? newValue.text.replaceAll(RegExp(r'[^\d.,]'), '')
        : newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Virgülü noktaya çevir
    if (allowDecimal) {
      filtered = filtered.replaceAll(',', '.');

      // Sadece bir ondalık nokta olmasını sağla
      int dotCount = '.'.allMatches(filtered).length;
      if (dotCount > 1) {
        int firstDot = filtered.indexOf('.');
        filtered =
            filtered.substring(0, firstDot + 1) +
            filtered.substring(firstDot + 1).replaceAll('.', '');
      }
    }

    // Maksimum rakam sayısını kontrol et
    if (maxDigits != null) {
      String digitsOnly = filtered.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length > maxDigits!) {
        return oldValue;
      }
    }

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// Validation helpers
class FormValidators {
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} zorunludur';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'İsim gereklidir';
    }
    if (value.trim().length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }
    if (value.trim().length > 50) {
      return 'İsim 50 karakterden uzun olamaz';
    }
    if (!RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ\s]+$').hasMatch(value.trim())) {
      return 'İsim sadece harflerden oluşabilir';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kilo gereklidir';
    }

    double? weight = double.tryParse(value.replaceAll(',', '.'));
    if (weight == null) {
      return 'Geçerli bir kilo giriniz';
    }
    if (weight < 0.5 || weight > 8.0) {
      return 'Kilo 0,5 - 8,0 kg arasında olmalıdır';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Boy gereklidir';
    }

    double? height = double.tryParse(value.replaceAll(',', '.'));
    if (height == null) {
      return 'Geçerli bir boy giriniz';
    }
    if (height < 30 || height > 70) {
      return 'Boy 30 - 70 cm arasında olmalıdır';
    }
    return null;
  }

  static String? validateHeadCircumference(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opsiyonel alan
    }

    double? circumference = double.tryParse(value.replaceAll(',', '.'));
    if (circumference == null) {
      return 'Geçerli bir değer giriniz';
    }
    if (circumference < 25 || circumference > 45) {
      return 'Baş çevresi 25 - 45 cm arasında olmalıdır';
    }
    return null;
  }
}
