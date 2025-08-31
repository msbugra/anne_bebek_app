import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';

class DateTimePickerWidget extends StatelessWidget {
  final String? label;
  final String? hint;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final Function(DateTime) onDateChanged;
  final Function(TimeOfDay)? onTimeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showTime;
  final bool required;
  final String? Function(DateTime?)? validator;
  final IconData prefixIcon;
  final bool enabled;

  const DateTimePickerWidget({
    super.key,
    this.label,
    this.hint,
    this.selectedDate,
    this.selectedTime,
    required this.onDateChanged,
    this.onTimeChanged,
    this.firstDate,
    this.lastDate,
    this.showTime = false,
    this.required = false,
    this.validator,
    this.prefixIcon = Icons.calendar_today_rounded,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              children: required
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

        GestureDetector(
          onTap: enabled ? () => _showDatePicker(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFF8F9FA)
                  : const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  prefixIcon,
                  color: enabled
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: enabled
                          ? selectedDate != null
                                ? const Color(0xFF1A1B23)
                                : const Color(0xFF9CA3AF)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                if (enabled) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayText() {
    if (selectedDate == null) {
      return hint ?? 'Tarih seçiniz';
    }

    final dateStr = DateFormat('dd MMMM yyyy', 'tr').format(selectedDate!);

    if (showTime && selectedTime != null) {
      final timeStr = selectedTime!.format(navigatorKey.currentContext!);
      return '$dateStr, $timeStr';
    }

    return dateStr;
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF6B4EFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    onDateChanged(picked);

    if (showTime && onTimeChanged != null) {
      if (!context.mounted) return;
      _showTimePicker(context);
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF6B4EFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onTimeChanged != null) {
      onTimeChanged!(picked);
    }
  }
}

// Global navigator key for context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Cupertino-style date picker for iOS-like experience
class CupertinoDateTimePicker extends StatefulWidget {
  final String? label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateChanged;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final CupertinoDatePickerMode mode;
  final bool required;

  const CupertinoDateTimePicker({
    super.key,
    this.label,
    this.selectedDate,
    required this.onDateChanged,
    this.minimumDate,
    this.maximumDate,
    this.mode = CupertinoDatePickerMode.date,
    this.required = false,
  });

  @override
  State<CupertinoDateTimePicker> createState() =>
      _CupertinoDateTimePickerState();
}

class _CupertinoDateTimePickerState extends State<CupertinoDateTimePicker> {
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

        GestureDetector(
          onTap: () => _showCupertinoDatePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedDate != null
                        ? _formatDate(widget.selectedDate!)
                        : 'Tarih ve saat seçiniz',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: widget.selectedDate != null
                          ? const Color(0xFF1A1B23)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    switch (widget.mode) {
      case CupertinoDatePickerMode.date:
        return DateFormat('dd MMMM yyyy', 'tr').format(date);
      case CupertinoDatePickerMode.time:
        return DateFormat('HH:mm', 'tr').format(date);
      case CupertinoDatePickerMode.dateAndTime:
        return DateFormat('dd MMMM yyyy, HH:mm', 'tr').format(date);
      case CupertinoDatePickerMode.monthYear:
        return DateFormat('MMMM yyyy', 'tr').format(date);
    }
  }

  void _showCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 16),

            // Title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                  ),
                ),
                Text(
                  'Tarih ve Saat',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Tamam',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B4EFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date picker
            Expanded(
              child: CupertinoDatePicker(
                mode: widget.mode,
                initialDateTime: widget.selectedDate ?? DateTime.now(),
                minimumDate: widget.minimumDate,
                maximumDate: widget.maximumDate,
                onDateTimeChanged: widget.onDateChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Time picker widget
class TimePickerWidget extends StatelessWidget {
  final String? label;
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeChanged;
  final bool required;
  final String? hint;

  const TimePickerWidget({
    super.key,
    this.label,
    this.selectedTime,
    required this.onTimeChanged,
    this.required = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              children: required
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

        GestureDetector(
          onTap: () => _showTimePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : hint ?? 'Saat seçiniz',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: selectedTime != null
                          ? const Color(0xFF1A1B23)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF6B4EFF)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}
