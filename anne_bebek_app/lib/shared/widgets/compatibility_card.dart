import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zodiac_compatibility_model.dart';
import '../models/astrological_profile_model.dart';
import '../providers/astrology_provider.dart';
import '../../core/utils/zodiac_calculator.dart';

class CompatibilityCard extends StatelessWidget {
  final ZodiacCompatibility compatibility;
  final VoidCallback? onTap;
  final bool compact;

  const CompatibilityCard({
    super.key,
    required this.compatibility,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: compact ? const EdgeInsets.all(16) : const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _getCompatibilityGradient(),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: _getCompatibilityColor().withAlpha(77),
              blurRadius: compact ? 8 : 12,
              offset: Offset(0, compact ? 4 : 6),
            ),
          ],
        ),
        child: compact ? _buildCompactContent() : _buildFullContent(),
      ),
    );
  }

  Widget _buildCompactContent() {
    return Row(
      children: [
        // Score circle
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${compatibility.compatibilityScore}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                compatibility.compatibilityTitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                compatibility.compatibilityLevelDisplayName,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withAlpha(204),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _getCompatibilityIcon(),
                    color: Colors.white.withAlpha(204),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '%${compatibility.compatibilityPercentage.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withAlpha(179),
            size: 16,
          ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      children: [
        // Header
        Row(
          children: [
            // Mother sign
            _buildSignAvatar(compatibility.motherSign, 'Anne'),
            const SizedBox(width: 16),
            // Heart icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Baby sign
            _buildSignAvatar(compatibility.babySign, 'Bebek'),
          ],
        ),

        const SizedBox(height: 20),

        // Score section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${compatibility.compatibilityScore}',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/10',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      compatibility.compatibilityLevelDisplayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    compatibility.compatibilityEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Description
        Text(
          compatibility.compatibilityDescription,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white.withAlpha(230),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        // Strengths preview
        if (compatibility.strengths.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Güçlü Yanlar',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...compatibility.strengths
                    .take(2)
                    .map(
                      (strength) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                strength,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],

        // Tap indicator
        if (onTap != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Detaylı analiz için dokunun',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withAlpha(179),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.touch_app_rounded,
                color: Colors.white.withAlpha(179),
                size: 16,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSignAvatar(ZodiacSign sign, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              AstrologyProvider.getZodiacEmoji(sign),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withAlpha(204),
          ),
        ),
        Text(
          ZodiacCalculator.getZodiacName(sign),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  LinearGradient _getCompatibilityGradient() {
    final score = compatibility.compatibilityScore;
    if (score >= 8) {
      return const LinearGradient(
        colors: [Color(0xFF48BB78), Color(0xFF38A169), Color(0xFF2F855A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (score >= 6) {
      return const LinearGradient(
        colors: [Color(0xFFED8936), Color(0xFFDD6B20), Color(0xFFC05621)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (score >= 4) {
      return const LinearGradient(
        colors: [Color(0xFF4299E1), Color(0xFF3182CE), Color(0xFF2B6CB0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFE53E3E), Color(0xFFC53030), Color(0xFF9B2C2C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getCompatibilityColor() {
    final score = compatibility.compatibilityScore;
    if (score >= 8) return const Color(0xFF48BB78);
    if (score >= 6) return const Color(0xFFED8936);
    if (score >= 4) return const Color(0xFF4299E1);
    return const Color(0xFFE53E3E);
  }

  IconData _getCompatibilityIcon() {
    final score = compatibility.compatibilityScore;
    if (score >= 8) return Icons.favorite_rounded;
    if (score >= 6) return Icons.thumb_up_rounded;
    if (score >= 4) return Icons.handshake_rounded;
    return Icons.warning_rounded;
  }
}

// Compatibility Score Indicator
class CompatibilityScoreIndicator extends StatelessWidget {
  final int score;
  final double size;
  final bool showLabel;

  const CompatibilityScoreIndicator({
    super.key,
    required this.score,
    this.size = 60,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getScoreColor(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getScoreColor().withAlpha(77),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$score',
              style: GoogleFonts.inter(
                fontSize: size * 0.3,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            _getScoreLabel(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getScoreColor(),
            ),
          ),
        ],
      ],
    );
  }

  Color _getScoreColor() {
    if (score >= 8) return const Color(0xFF48BB78);
    if (score >= 6) return const Color(0xFFED8936);
    if (score >= 4) return const Color(0xFF4299E1);
    return const Color(0xFFE53E3E);
  }

  String _getScoreLabel() {
    if (score >= 8) return 'Mükemmel';
    if (score >= 6) return 'İyi';
    if (score >= 4) return 'Orta';
    return 'Zorlu';
  }
}

// Compatibility Progress Bar
class CompatibilityProgressBar extends StatelessWidget {
  final int score;
  final String? label;
  final double height;

  const CompatibilityProgressBar({
    super.key,
    required this.score,
    this.label,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(51),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: score / 10.0,
            child: Container(
              decoration: BoxDecoration(
                color: _getScoreColor(),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$score/10',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getScoreColor(),
              ),
            ),
            Text(
              _getScoreLabel(),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getScoreColor() {
    if (score >= 8) return const Color(0xFF48BB78);
    if (score >= 6) return const Color(0xFFED8936);
    if (score >= 4) return const Color(0xFF4299E1);
    return const Color(0xFFE53E3E);
  }

  String _getScoreLabel() {
    if (score >= 8) return 'Mükemmel';
    if (score >= 6) return 'İyi';
    if (score >= 4) return 'Orta';
    return 'Zorlu';
  }
}

// Compatibility Tips Card
class CompatibilityTipsCard extends StatelessWidget {
  final String title;
  final List<String> tips;
  final IconData icon;
  final Color color;

  const CompatibilityTipsCard({
    super.key,
    required this.title,
    required this.tips,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => _buildTipItem(tip)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
