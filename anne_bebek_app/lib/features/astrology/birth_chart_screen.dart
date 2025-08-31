import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/astrology_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/zodiac_wheel.dart';
import '../../shared/models/astrological_profile_model.dart';
import '../../core/utils/zodiac_calculator.dart';

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({super.key});

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Doğum Haritası',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1B23),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer2<BabyProvider, AstrologyProvider>(
        builder: (context, babyProvider, astrologyProvider, child) {
          if (!babyProvider.hasBabyProfile) {
            return _buildNoDataMessage();
          }

          if (astrologyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final baby = babyProvider.currentBaby!;
          final babyProfile = astrologyProvider.babyProfile;
          final characteristics = astrologyProvider.babyCharacteristics;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ana Chart Widget
                _buildBirthChartWidget(baby, babyProfile, characteristics),
                const SizedBox(height: 24),

                // Gezegen Konumları
                _buildPlanetaryPositions(baby, babyProfile),
                const SizedBox(height: 24),

                // Ev Sistemi
                _buildHouseSystem(baby, babyProfile),
                const SizedBox(height: 24),

                // Aspectler
                _buildAspects(baby, babyProfile),
                const SizedBox(height: 24),

                // Yorumlar
                if (characteristics != null)
                  _buildInterpretation(characteristics),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Doğum Haritası',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Doğum haritasını görmek için\nbebek profilinizi oluşturun.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthChartWidget(
    dynamic baby,
    AstrologicalProfile? profile,
    dynamic characteristics,
  ) {
    final zodiacSign = ZodiacCalculator.calculateZodiacSign(baby.birthDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AstrologyProvider.getElementGradient(
            ZodiacCalculator.getZodiacElement(zodiacSign),
          ),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AstrologyProvider.getZodiacColor(zodiacSign).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${baby.name} - Doğum Haritası',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${baby.birthDate.day}.${baby.birthDate.month}.${baby.birthDate.year}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withAlpha(204),
            ),
          ),
          if (baby.birthTime != null)
            Text(
              'Doğum Saati: ${baby.birthTime}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withAlpha(204),
              ),
            ),
          const SizedBox(height: 24),

          // Zodiac Wheel
          ZodiacWheel(selectedSign: zodiacSign, size: 250, interactive: false),
        ],
      ),
    );
  }

  Widget _buildPlanetaryPositions(dynamic baby, AstrologicalProfile? profile) {
    final zodiacSign = ZodiacCalculator.calculateZodiacSign(baby.birthDate);
    final ascendant = baby.birthTime != null
        ? ZodiacCalculator.calculateAscendant(baby.birthDate, baby.birthTime)
        : null;

    return DashboardCard(
      title: 'Gezegen Konumları',
      icon: Icons.public_rounded,
      iconColor: AstrologyProvider.getZodiacColor(zodiacSign),
      child: Column(
        children: [
          _buildPlanetItem(
            'Güneş (Ana Burç)',
            ZodiacCalculator.getZodiacName(zodiacSign),
            AstrologyProvider.getZodiacEmoji(zodiacSign),
            AstrologyProvider.getZodiacColor(zodiacSign),
            'Temel kişilik, ego, yaşam enerjisi',
          ),
          const Divider(),
          _buildPlanetItem(
            'Ay',
            ZodiacCalculator.getZodiacName(_getMoonSign(baby.birthDate)),
            AstrologyProvider.getZodiacEmoji(_getMoonSign(baby.birthDate)),
            AstrologyProvider.getZodiacColor(_getMoonSign(baby.birthDate)),
            'Duygular, iç dünya, annellik bağı',
          ),
          if (ascendant != null) ...[
            const Divider(),
            _buildPlanetItem(
              'Yükselen',
              ZodiacCalculator.getZodiacName(ascendant),
              AstrologyProvider.getZodiacEmoji(ascendant),
              AstrologyProvider.getZodiacColor(ascendant),
              'Dış görünüm, ilk izlenim, yaklaşım',
            ),
          ],
          const Divider(),
          _buildPlanetItem(
            'Merkür',
            ZodiacCalculator.getZodiacName(_getMercurySign(baby.birthDate)),
            '☿',
            Colors.orange,
            'İletişim, öğrenme, düşünce',
          ),
          const Divider(),
          _buildPlanetItem(
            'Venüs',
            ZodiacCalculator.getZodiacName(_getVenusSign(baby.birthDate)),
            '♀',
            Colors.pink,
            'Sevgi, estetik, sosyal ilişkiler',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetItem(
    String planet,
    String sign,
    String symbol,
    Color color,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(symbol, style: TextStyle(fontSize: 18, color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planet,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1B23),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '→',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sign,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
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

  Widget _buildHouseSystem(dynamic baby, AstrologicalProfile? profile) {
    return DashboardCard(
      title: 'Astroloji Evleri',
      icon: Icons.home_rounded,
      child: Column(
        children: [
          _buildHouseItem(
            1,
            'Kişilik Evi',
            'Dış görünüm, ilk izlenim, fiziksel yapı',
          ),
          _buildHouseItem(
            2,
            'Değerler Evi',
            'Maddi durum, değer yargıları, yetenekler',
          ),
          _buildHouseItem(3, 'İletişim Evi', 'Kardeşler, yakın çevre, öğrenme'),
          _buildHouseItem(
            4,
            'Aile Evi',
            'Anne, ev, kökenler, duygusal güvenlik',
          ),
          _buildHouseItem(
            5,
            'Yaratıcılık Evi',
            'Çocuklar, oyun, sanat, eğlence',
          ),
          _buildHouseItem(6, 'Sağlık Evi', 'Günlük rutinler, sağlık, hizmet'),
        ],
      ),
    );
  }

  Widget _buildHouseItem(
    int houseNumber,
    String houseName,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$houseNumber',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
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
                  houseName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspects(dynamic baby, AstrologicalProfile? profile) {
    final zodiacSign = ZodiacCalculator.calculateZodiacSign(baby.birthDate);
    final moonSign = _getMoonSign(baby.birthDate);

    return DashboardCard(
      title: 'Temel Aspectler',
      icon: Icons.sync_alt_rounded,
      child: Column(
        children: [
          _buildAspectItem(
            'Güneş - Ay Aspekti',
            _calculateSunMoonAspect(zodiacSign, moonSign),
            _getSunMoonAspectDescription(zodiacSign, moonSign),
            Icons.brightness_5_rounded,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildAspectItem(
            'Element Uyumu',
            _getElementHarmony(zodiacSign),
            'İç denge ve enerji akışı',
            AstrologyProvider.getElementIcon(
              ZodiacCalculator.getZodiacElement(zodiacSign),
            ),
            AstrologyProvider.getZodiacColor(zodiacSign),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectItem(
    String aspectName,
    String aspectType,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aspectName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                Text(
                  aspectType,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
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

  Widget _buildInterpretation(dynamic characteristics) {
    return DashboardCard(
      title: 'Doğum Haritası Yorumu',
      icon: Icons.psychology_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            characteristics.generalDescription,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Güçlü Potansiyeller:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            characteristics.strengthsDescription,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ebeveynlik Yaklaşımı:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            characteristics.parentingApproach,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for planetary calculations
  ZodiacSign _getMoonSign(DateTime birthDate) {
    // Basitleştirilmiş ay burcu hesabı
    final dayOfYear = birthDate
        .difference(DateTime(birthDate.year, 1, 1))
        .inDays;
    final moonSignIndex = ((dayOfYear * 0.98) % 12).floor();
    return ZodiacSign.values[moonSignIndex];
  }

  ZodiacSign _getMercurySign(DateTime birthDate) {
    // Merkür genellikle güneşe yakın olur
    final sunSign = ZodiacCalculator.calculateZodiacSign(birthDate);
    final sunIndex = ZodiacSign.values.indexOf(sunSign);
    final mercuryIndex = (sunIndex + (birthDate.day % 3 - 1)) % 12;
    return ZodiacSign.values[mercuryIndex < 0
        ? mercuryIndex + 12
        : mercuryIndex];
  }

  ZodiacSign _getVenusSign(DateTime birthDate) {
    // Venüs için basit hesaplama
    final sunSign = ZodiacCalculator.calculateZodiacSign(birthDate);
    final sunIndex = ZodiacSign.values.indexOf(sunSign);
    final venusIndex = (sunIndex + (birthDate.month % 4 - 2)) % 12;
    return ZodiacSign.values[venusIndex < 0 ? venusIndex + 12 : venusIndex];
  }

  String _calculateSunMoonAspect(ZodiacSign sunSign, ZodiacSign moonSign) {
    final sunIndex = ZodiacSign.values.indexOf(sunSign);
    final moonIndex = ZodiacSign.values.indexOf(moonSign);
    final distance = (moonIndex - sunIndex).abs();

    if (distance == 0) return 'Konjünksiyon';
    if (distance == 2 || distance == 10) return 'Sextile';
    if (distance == 3 || distance == 9) return 'Trine';
    if (distance == 4 || distance == 8) return 'Kare';
    if (distance == 6) return 'Karşıt';
    return 'Minör Aspekt';
  }

  String _getSunMoonAspectDescription(ZodiacSign sunSign, ZodiacSign moonSign) {
    final aspect = _calculateSunMoonAspect(sunSign, moonSign);
    switch (aspect) {
      case 'Konjünksiyon':
        return 'Güçlü iç uyum, kişilik ve duygular aynı yönde';
      case 'Trine':
        return 'Doğal denge, kolay adaptasyon';
      case 'Sextile':
        return 'Yaratıcı potansiyel, fırsatları değerlendirme';
      case 'Kare':
        return 'İç gerilim, büyüme için motivasyon';
      case 'Karşıt':
        return 'Denge arayışı, farklı yönler';
      default:
        return 'Benzersiz enerji karışımı';
    }
  }

  String _getElementHarmony(ZodiacSign sign) {
    final element = ZodiacCalculator.getZodiacElement(sign);
    switch (element) {
      case ZodiacElement.fire:
        return 'Yüksek enerji ve coşku';
      case ZodiacElement.earth:
        return 'İstikrar ve güvenilirlik';
      case ZodiacElement.air:
        return 'Zihinsel aktivite ve sosyallik';
      case ZodiacElement.water:
        return 'Duygusal derinlik ve sezgi';
    }
  }
}
