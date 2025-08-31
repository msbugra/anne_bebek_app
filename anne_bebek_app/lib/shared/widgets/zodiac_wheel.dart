import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import '../models/astrological_profile_model.dart';
import '../providers/astrology_provider.dart';
import '../../core/utils/zodiac_calculator.dart';

class ZodiacWheel extends StatefulWidget {
  final ZodiacSign? selectedSign;
  final Function(ZodiacSign)? onSignSelected;
  final double size;
  final bool interactive;

  const ZodiacWheel({
    super.key,
    this.selectedSign,
    this.onSignSelected,
    this.size = 300.0,
    this.interactive = true,
  });

  @override
  State<ZodiacWheel> createState() => _ZodiacWheelState();
}

class _ZodiacWheelState extends State<ZodiacWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  ZodiacSign? _hoveredSign;

  // Burç sırası (saat yönünde)
  static const List<ZodiacSign> _zodiacOrder = [
    ZodiacSign.aries, // 0° (12 o'clock)
    ZodiacSign.taurus, // 30°
    ZodiacSign.gemini, // 60°
    ZodiacSign.cancer, // 90° (3 o'clock)
    ZodiacSign.leo, // 120°
    ZodiacSign.virgo, // 150°
    ZodiacSign.libra, // 180° (6 o'clock)
    ZodiacSign.scorpio, // 210°
    ZodiacSign.sagittarius, // 240°
    ZodiacSign.capricorn, // 270° (9 o'clock)
    ZodiacSign.aquarius, // 300°
    ZodiacSign.pisces, // 330°
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ZodiacWheelPainter(
              selectedSign: widget.selectedSign,
              hoveredSign: _hoveredSign,
              animationValue: _rotationAnimation.value,
            ),
            child: widget.interactive
                ? GestureDetector(
                    onTapUp: _handleTap,
                    onPanUpdate: _handlePanUpdate,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      color: Colors.transparent,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _handleTap(TapUpDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(
      details.globalPosition,
    );
    final ZodiacSign? tappedSign = _getSignFromPosition(localPosition);

    if (tappedSign != null && widget.onSignSelected != null) {
      widget.onSignSelected!(tappedSign);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.interactive) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(
      details.globalPosition,
    );
    final ZodiacSign? hoveredSign = _getSignFromPosition(localPosition);

    if (hoveredSign != _hoveredSign) {
      setState(() {
        _hoveredSign = hoveredSign;
      });
    }
  }

  ZodiacSign? _getSignFromPosition(Offset position) {
    final double centerX = widget.size / 2;
    final double centerY = widget.size / 2;
    final double dx = position.dx - centerX;
    final double dy = position.dy - centerY;
    final double distance = math.sqrt(dx * dx + dy * dy);

    // Sadece çark içindeyse hesapla
    final double innerRadius = widget.size * 0.3;
    final double outerRadius = widget.size * 0.45;

    if (distance < innerRadius || distance > outerRadius) {
      return null;
    }

    // Açıyı hesapla (saat 12'den başlayarak)
    double angle = math.atan2(dx, -dy) * 180 / math.pi;
    if (angle < 0) angle += 360;

    // Burcu belirle (her burç 30 derece)
    final int signIndex = ((angle + 15) / 30).floor() % 12;
    return _zodiacOrder[signIndex];
  }
}

class ZodiacWheelPainter extends CustomPainter {
  final ZodiacSign? selectedSign;
  final ZodiacSign? hoveredSign;
  final double animationValue;

  ZodiacWheelPainter({
    this.selectedSign,
    this.hoveredSign,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double outerRadius = size.width * 0.45;
    final double innerRadius = size.width * 0.3;
    final double middleRadius = (outerRadius + innerRadius) / 2;

    // Arka plan çember
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, paint);

    // Gölge
    paint.color = Colors.black.withAlpha((255 * 0.1).round());
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, paint);
    paint.maskFilter = null;

    // Her burç için segment çiz
    for (int i = 0; i < 12; i++) {
      final ZodiacSign sign = ZodiacWheelPainter._zodiacOrder[i];
      final double startAngle =
          (i * 30 - 90) * math.pi / 180; // -90 saat 12'den başlamak için
      final double sweepAngle = 30 * math.pi / 180;

      // Animasyon etkisi
      final double currentRadius =
          innerRadius +
          (outerRadius - innerRadius) *
              math.min(1.0, animationValue * 2 - i * 0.1);

      // Renk belirleme
      Color signColor = AstrologyProvider.getZodiacColor(sign);
      if (sign == selectedSign) {
        signColor = signColor.withAlpha((255 * 1.0).round());
      } else if (sign == hoveredSign) {
        signColor = signColor.withAlpha((255 * 0.8).round());
      } else {
        signColor = signColor.withAlpha((255 * 0.6).round());
      }

      // Segment çiz
      paint.color = signColor;
      paint.style = PaintingStyle.fill;
      final Path segmentPath = Path();

      segmentPath.moveTo(centerX, centerY);
      segmentPath.arcTo(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: currentRadius,
        ),
        startAngle,
        sweepAngle,
        false,
      );
      segmentPath.arcTo(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: innerRadius),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      segmentPath.close();

      canvas.drawPath(segmentPath, paint);

      // Burç sembolü
      final double symbolAngle = startAngle + sweepAngle / 2;
      final double symbolX = centerX + math.cos(symbolAngle) * middleRadius;
      final double symbolY = centerY + math.sin(symbolAngle) * middleRadius;

      _drawZodiacSymbol(
        canvas,
        sign,
        Offset(symbolX, symbolY),
        sign == selectedSign || sign == hoveredSign,
      );
    }

    // İç çember (merkez)
    paint.color = const Color(0xFF1A1B23);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), innerRadius, paint);

    // Merkez sembol
    _drawCenterSymbol(canvas, Offset(centerX, centerY), innerRadius);

    // Dış çember çizgisi
    paint.color = const Color(0xFF1A1B23);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawCircle(Offset(centerX, centerY), outerRadius, paint);
  }

  void _drawZodiacSymbol(
    Canvas canvas,
    ZodiacSign sign,
    Offset position,
    bool highlighted,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: AstrologyProvider.getZodiacEmoji(sign),
        style: TextStyle(
          fontSize: highlighted ? 24 : 20,
          color: highlighted
              ? Colors.white
              : Colors.white.withAlpha((255 * 0.9).round()),
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final Offset textOffset = Offset(
      position.dx - textPainter.width / 2,
      position.dy - textPainter.height / 2,
    );

    // Arka plan çember (vurgu için)
    if (highlighted) {
      final Paint backgroundPaint = Paint()
        ..color = Colors.white.withAlpha((255 * 0.2).round())
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, 16, backgroundPaint);
    }

    textPainter.paint(canvas, textOffset);
  }

  void _drawCenterSymbol(Canvas canvas, Offset center, double radius) {
    // Merkez yıldız sembolü
    final Paint starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path starPath = Path();
    const int points = 8;
    const double outerRadius = 20.0;
    const double innerRadius = 12.0;

    for (int i = 0; i < points * 2; i++) {
      final double angle = i * math.pi / points;
      final double r = i.isEven ? outerRadius : innerRadius;
      final double x = center.dx + r * math.cos(angle - math.pi / 2);
      final double y = center.dy + r * math.sin(angle - math.pi / 2);

      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);
  }

  // Burç sırası (static olarak tanımla)
  static const List<ZodiacSign> _zodiacOrder = [
    ZodiacSign.aries,
    ZodiacSign.taurus,
    ZodiacSign.gemini,
    ZodiacSign.cancer,
    ZodiacSign.leo,
    ZodiacSign.virgo,
    ZodiacSign.libra,
    ZodiacSign.scorpio,
    ZodiacSign.sagittarius,
    ZodiacSign.capricorn,
    ZodiacSign.aquarius,
    ZodiacSign.pisces,
  ];

  @override
  bool shouldRepaint(covariant ZodiacWheelPainter oldDelegate) {
    return oldDelegate.selectedSign != selectedSign ||
        oldDelegate.hoveredSign != hoveredSign ||
        oldDelegate.animationValue != animationValue;
  }
}

// Zodiac Wheel Legend Widget
class ZodiacWheelLegend extends StatelessWidget {
  final ZodiacSign? selectedSign;

  const ZodiacWheelLegend({super.key, this.selectedSign});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Burçlar',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ZodiacSign.values
                .map((sign) => _buildLegendItem(sign))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ZodiacSign sign) {
    final bool isSelected = sign == selectedSign;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AstrologyProvider.getZodiacColor(
                sign,
              ).withAlpha((255 * 0.1).round())
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AstrologyProvider.getZodiacColor(sign))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AstrologyProvider.getZodiacEmoji(sign),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            ZodiacCalculator.getZodiacName(sign),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AstrologyProvider.getZodiacColor(sign)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
