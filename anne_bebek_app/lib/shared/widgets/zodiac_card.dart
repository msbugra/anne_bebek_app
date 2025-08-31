import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/astrological_profile_model.dart';
import '../models/zodiac_characteristics_model.dart';
import '../providers/astrology_provider.dart';
import '../../core/utils/zodiac_calculator.dart';

class ZodiacCard extends StatelessWidget {
  final ZodiacSign zodiacSign;
  final ZodiacCharacteristics? characteristics;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool compact;
  final bool showDescription;

  const ZodiacCard({
    super.key,
    required this.zodiacSign,
    this.characteristics,
    this.subtitle,
    this.onTap,
    this.compact = false,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: compact ? const EdgeInsets.all(16) : const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AstrologyProvider.getElementGradient(
              ZodiacCalculator.getZodiacElement(zodiacSign),
            ),
          ),
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: AstrologyProvider.getZodiacColor(
                zodiacSign,
              ).withOpacity(0.25),
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
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              AstrologyProvider.getZodiacEmoji(zodiacSign),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ZodiacCalculator.getZodiacName(zodiacSign),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    AstrologyProvider.getElementIcon(
                      ZodiacCalculator.getZodiacElement(zodiacSign),
                    ),
                    color: Colors.white.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ZodiacCalculator.getElementName(
                      ZodiacCalculator.getZodiacElement(zodiacSign),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
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
            color: Colors.white.withOpacity(0.7),
            size: 16,
          ),
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık satırı
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  AstrologyProvider.getZodiacEmoji(zodiacSign),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ZodiacCalculator.getZodiacName(zodiacSign),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ZodiacCalculator.getZodiacDateRange(zodiacSign),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Element ve Gezegen Bilgisi
        Row(
          children: [
            _buildInfoChip(
              icon: AstrologyProvider.getElementIcon(
                ZodiacCalculator.getZodiacElement(zodiacSign),
              ),
              label: ZodiacCalculator.getElementName(
                ZodiacCalculator.getZodiacElement(zodiacSign),
              ),
            ),
            const SizedBox(width: 12),
            if (characteristics != null)
              _buildInfoChip(
                icon: Icons.public_rounded,
                label: characteristics!.rulingPlanet,
              ),
          ],
        ),

        // Açıklama
        if (showDescription && characteristics != null) ...[
          const SizedBox(height: 16),
          Text(
            characteristics!.generalDescription,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],

        // Özellikler
        if (characteristics != null &&
            characteristics!.positiveTraits.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Temel Özellikler:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: characteristics!.positiveTraits
                .take(3)
                .map(
                  (trait) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trait,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],

        // Tap indicator
        if (onTap != null) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Detaylar için dokunun',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.touch_app_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Anne-Bebek Karşılaştırma Kartı
class MotherBabyZodiacCard extends StatelessWidget {
  final ZodiacSign motherSign;
  final ZodiacSign babySign;
  final int? compatibilityScore;
  final VoidCallback? onTap;

  const MotherBabyZodiacCard({
    super.key,
    required this.motherSign,
    required this.babySign,
    this.compatibilityScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24), Color(0xFFEA2027)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Anne-Bebek Uyumu',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Burç kartları
            Row(
              children: [
                Expanded(
                  child: _buildSignSection(
                    motherSign,
                    'Anne',
                    ZodiacCalculator.getZodiacName(motherSign),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSignSection(
                    babySign,
                    'Bebek',
                    ZodiacCalculator.getZodiacName(babySign),
                  ),
                ),
              ],
            ),

            if (compatibilityScore != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Uyum: ${compatibilityScore!}/10',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (onTap != null) ...[
              const SizedBox(height: 16),
              Text(
                'Detaylı analiz için dokunun',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignSection(ZodiacSign sign, String role, String name) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              AstrologyProvider.getZodiacEmoji(sign),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          role,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Mini Zodiac Card (Liste görünümü için)
class MiniZodiacCard extends StatelessWidget {
  final ZodiacSign zodiacSign;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isSelected;

  const MiniZodiacCard({
    super.key,
    required this.zodiacSign,
    this.subtitle,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AstrologyProvider.getZodiacColor(zodiacSign).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AstrologyProvider.getZodiacColor(zodiacSign),
                  width: 2,
                )
              : Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              AstrologyProvider.getZodiacEmoji(zodiacSign),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ZodiacCalculator.getZodiacName(zodiacSign),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AstrologyProvider.getZodiacColor(zodiacSign)
                          : const Color(0xFF1A1B23),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF6B7280),
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}
