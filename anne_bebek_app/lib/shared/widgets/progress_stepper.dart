import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';

class ProgressStepper extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> stepTitles;
  final Color activeColor;
  final Color inactiveColor;
  final Color completedColor;
  final double height;
  final bool showLabels;

  const ProgressStepper({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.stepTitles = const [],
    this.activeColor = const Color(0xFF6B4EFF),
    this.inactiveColor = const Color(0xFFE5E7EB),
    this.completedColor = const Color(0xFF10B981),
    this.height = 4.0,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Row(
          children: List.generate(totalSteps, (index) {
            return Expanded(
              child: Container(
                height: height,
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
                decoration: BoxDecoration(
                  color: _getStepColor(index),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            );
          }),
        ),

        // Step indicators with labels
        if (showLabels) ...[
          const SizedBox(height: 16),
          Row(
            children: List.generate(totalSteps, (index) {
              return Expanded(
                child: _StepIndicator(
                  stepNumber: index + 1,
                  title: index < stepTitles.length
                      ? stepTitles[index]
                      : 'Adım ${index + 1}',
                  isActive: index == currentStep,
                  isCompleted: index < currentStep,
                  activeColor: activeColor,
                  completedColor: completedColor,
                  inactiveColor: inactiveColor,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Color _getStepColor(int stepIndex) {
    if (stepIndex < currentStep) {
      return completedColor;
    } else if (stepIndex == currentStep) {
      return activeColor;
    } else {
      return inactiveColor;
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int stepNumber;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final Color activeColor;
  final Color completedColor;
  final Color inactiveColor;

  const _StepIndicator({
    required this.stepNumber,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.activeColor,
    required this.completedColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getBackgroundColor(),
            border: Border.all(color: _getBorderColor(), width: 2),
          ),
          child: Center(child: _getStepContent()),
        ),

        const SizedBox(height: 8),

        // Step title
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: _getTextColor(),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _getStepContent() {
    if (isCompleted) {
      return Icon(Icons.check_rounded, size: 16, color: Colors.white);
    } else {
      return Text(
        stepNumber.toString(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getNumberColor(),
        ),
      );
    }
  }

  Color _getBackgroundColor() {
    if (isCompleted) return completedColor;
    if (isActive) return activeColor;
    return Colors.white;
  }

  Color _getBorderColor() {
    if (isCompleted) return completedColor;
    if (isActive) return activeColor;
    return inactiveColor;
  }

  Color _getNumberColor() {
    if (isActive) return Colors.white;
    return const Color(0xFF6B7280);
  }

  Color _getTextColor() {
    if (isCompleted) return completedColor;
    if (isActive) return activeColor;
    return const Color(0xFF6B7280);
  }
}

// Minimalist progress dots
class ProgressDots extends StatelessWidget {
  final int totalDots;
  final int activeDot;
  final Color activeColor;
  final Color inactiveColor;
  final double dotSize;
  final double spacing;

  const ProgressDots({
    super.key,
    required this.totalDots,
    required this.activeDot,
    this.activeColor = const Color(0xFF6B4EFF),
    this.inactiveColor = const Color(0xFFE5E7EB),
    this.dotSize = 8.0,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        return AnimatedContainer(
          duration: AppConstants.shortAnimation,
          width: index == activeDot ? dotSize * 2 : dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            color: index == activeDot ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}

// Circular progress indicator
class CircularStepProgress extends StatefulWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  const CircularStepProgress({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = const Color(0xFF6B4EFF),
    this.inactiveColor = const Color(0xFFE5E7EB),
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.centerChild,
  });

  @override
  State<CircularStepProgress> createState() => _CircularStepProgressState();
}

class _CircularStepProgressState extends State<CircularStepProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );
    _updateProgress();
  }

  @override
  void didUpdateWidget(CircularStepProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = widget.currentStep / widget.totalSteps;
    _progressAnimation = Tween<double>(begin: 0.0, end: progress).animate(
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
      child: Stack(
        children: [
          // Background circle
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CircularProgressPainter(
              progress: 1.0,
              color: widget.inactiveColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),

          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircularProgressPainter(
                  progress: _progressAnimation.value,
                  color: widget.activeColor,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),

          // Center content
          if (widget.centerChild != null)
            Center(child: widget.centerChild!)
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.currentStep}',
                    style: GoogleFonts.inter(
                      fontSize: widget.size * 0.2,
                      fontWeight: FontWeight.w700,
                      color: widget.activeColor,
                    ),
                  ),
                  Text(
                    '/ ${widget.totalSteps}',
                    style: GoogleFonts.inter(
                      fontSize: widget.size * 0.1,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2; // Start from top
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
