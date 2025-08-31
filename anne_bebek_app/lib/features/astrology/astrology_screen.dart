import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/astrology_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../core/utils/zodiac_calculator.dart';
import '../../shared/models/astrological_profile_model.dart';
import '../../shared/models/zodiac_compatibility_model.dart';
import '../../shared/models/zodiac_characteristics_model.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAstrologyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeAstrologyData() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final astrologyProvider = Provider.of<AstrologyProvider>(
      context,
      listen: false,
    );

    if (babyProvider.hasBabyProfile && babyProvider.currentBaby != null) {
      final baby = babyProvider.currentBaby!;
      await astrologyProvider.createBabyProfile(
        babyId: baby.id!,
        birthDate: baby.birthDate,
        birthCity: baby.birthCity,
        birthCountry: 'Türkiye',
      );

      if (babyProvider.currentMother != null) {
        final mother = babyProvider.currentMother!;
        if (mother.birthDate != null) {
          await astrologyProvider.createMotherProfile(
            motherId: mother.id!,
            birthDate: mother.birthDate!,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Astroloji',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1B23),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Burç Profili'),
            Tab(text: 'Uyumluluk'),
            Tab(text: 'Kişilik'),
          ],
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildZodiacProfileTab(babyProvider, astrologyProvider),
              _buildCompatibilityTab(babyProvider, astrologyProvider),
              _buildPersonalityTab(babyProvider, astrologyProvider),
            ],
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
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stars_rounded,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Astroloji Profili',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bebeğinizin burç analizini ve anne-bebek\nuyumluluğunu görmek için profil oluşturun.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/baby-profile');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Profil Oluştur'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacProfileTab(
    BabyProvider babyProvider,
    AstrologyProvider astrologyProvider,
  ) {
    final baby = babyProvider.currentBaby!;
    final zodiacSign = ZodiacCalculator.calculateZodiacSign(baby.birthDate);
    final characteristics = astrologyProvider.babyCharacteristics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana Burç Kartı
          _buildMainZodiacCard(zodiacSign, characteristics),
          const SizedBox(height: 24),

          // Element ve Gezegen Bilgisi
          _buildElementPlanetRow(zodiacSign, characteristics),
          const SizedBox(height: 24),

          // Temel Özellikler
          if (characteristics != null) ...[
            _buildCharacteristicsCard(characteristics),
            const SizedBox(height: 24),
          ],

          // Doğum Haritası Özeti
          _buildBirthChartSummary(zodiacSign, baby.birthDate),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCompatibilityTab(
    BabyProvider babyProvider,
    AstrologyProvider astrologyProvider,
  ) {
    final compatibility = astrologyProvider.currentCompatibility;
    final baby = babyProvider.currentBaby!;
    final mother = babyProvider.currentMother;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compatibility != null && mother != null) ...[
            // Uyumluluk Skoru
            _buildCompatibilityScoreCard(compatibility),
            const SizedBox(height: 24),

            // Güçlü Yanlar ve Zorlu Yanlar
            _buildCompatibilityDetails(compatibility),
            const SizedBox(height: 24),

            // Ebeveynlik Önerileri
            _buildParentingTipsCard(compatibility),
            const SizedBox(height: 24),

            // İletişim İpuçları
            _buildCommunicationTipsCard(compatibility),
          ] else ...[
            _buildNoMotherProfileMessage(),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPersonalityTab(
    BabyProvider babyProvider,
    AstrologyProvider astrologyProvider,
  ) {
    final baby = babyProvider.currentBaby!;
    final characteristics = astrologyProvider.babyCharacteristics;
    final ageInMonths = babyProvider.babyAgeInMonths ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (characteristics != null) ...[
            // Kişilik Açıklaması
            _buildPersonalityDescriptionCard(characteristics),
            const SizedBox(height: 24),

            // Olumlu ve Gelişim Özellikleri
            _buildTraitsRow(characteristics),
            const SizedBox(height: 24),

            // Yaş Bazlı Öneriler
            _buildAgeBasedRecommendations(characteristics, ageInMonths),
            const SizedBox(height: 24),

            // Gelişim İpuçları
            _buildDevelopmentTips(characteristics),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMainZodiacCard(
    ZodiacSign zodiacSign,
    ZodiacCharacteristics? characteristics,
  ) {
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
            color: AstrologyProvider.getZodiacColor(
              zodiacSign,
            ).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    AstrologyProvider.getZodiacEmoji(zodiacSign),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ZodiacCalculator.getZodiacName(zodiacSign),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      ZodiacCalculator.getZodiacDateRange(zodiacSign),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ZodiacCalculator.getElementName(
                          ZodiacCalculator.getZodiacElement(zodiacSign),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (characteristics != null) ...[
            const SizedBox(height: 20),
            Text(
              characteristics.generalDescription,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildElementPlanetRow(
    ZodiacSign zodiacSign,
    ZodiacCharacteristics? characteristics,
  ) {
    final element = ZodiacCalculator.getZodiacElement(zodiacSign);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  AstrologyProvider.getElementIcon(element),
                  color: AstrologyProvider.getZodiacColor(zodiacSign),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Element',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ZodiacCalculator.getElementName(element),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.public_rounded,
                  color: AstrologyProvider.getZodiacColor(zodiacSign),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Yönetici Gezegen',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  characteristics?.rulingPlanet ?? 'Bilinmiyor',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCharacteristicsCard(ZodiacCharacteristics characteristics) {
    return DashboardCard(
      title: 'Temel Özellikler',
      icon: Icons.psychology_rounded,
      iconColor: AstrologyProvider.getZodiacColor(characteristics.zodiacSign),
      child: Column(
        children: characteristics.positiveTraits
            .map(
              (trait) => _buildTraitItem(
                trait,
                AstrologyProvider.getZodiacColor(characteristics.zodiacSign),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTraitItem(String trait, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              trait,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthChartSummary(ZodiacSign zodiacSign, DateTime birthDate) {
    return DashboardCard(
      title: 'Doğum Haritası Özeti',
      icon: Icons.account_tree_rounded,
      child: Column(
        children: [
          _buildChartItem(
            'Güneş Burcu',
            ZodiacCalculator.getZodiacName(zodiacSign),
          ),
          _buildChartItem(
            'Doğum Tarihi',
            '${birthDate.day}.${birthDate.month}.${birthDate.year}',
          ),
          _buildChartItem(
            'Element',
            ZodiacCalculator.getElementName(
              ZodiacCalculator.getZodiacElement(zodiacSign),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1B23),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityScoreCard(ZodiacCompatibility compatibility) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
        ),
        borderRadius: BorderRadius.circular(20),
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
            compatibility.compatibilityTitle,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${compatibility.compatibilityScore}',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '/10',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              compatibility.compatibilityLevelDisplayName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            compatibility.compatibilityDescription,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityDetails(ZodiacCompatibility compatibility) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DashboardCard(
            title: 'Güçlü Yanlar',
            icon: Icons.thumb_up_rounded,
            iconColor: Colors.green,
            child: Column(
              children: compatibility.strengths
                  .map((strength) => _buildTraitItem(strength, Colors.green))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardCard(
            title: 'Zorlu Yanlar',
            icon: Icons.warning_rounded,
            iconColor: Colors.orange,
            child: Column(
              children: compatibility.challenges
                  .map((challenge) => _buildTraitItem(challenge, Colors.orange))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentingTipsCard(ZodiacCompatibility compatibility) {
    return DashboardCard(
      title: 'Ebeveynlik Önerileri',
      icon: Icons.family_restroom_rounded,
      iconColor: Colors.blue,
      child: Column(
        children: compatibility.parentingTips
            .map((tip) => _buildTipItem(tip, Colors.blue))
            .toList(),
      ),
    );
  }

  Widget _buildCommunicationTipsCard(ZodiacCompatibility compatibility) {
    return DashboardCard(
      title: 'İletişim İpuçları',
      icon: Icons.chat_rounded,
      iconColor: Colors.purple,
      child: Column(
        children: compatibility.communicationTips
            .map((tip) => _buildTipItem(tip, Colors.purple))
            .toList(),
      ),
    );
  }

  Widget _buildTipItem(String tip, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        tip,
        style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.4,
          color: const Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildNoMotherProfileMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 60,
            color: Colors.pink.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Anne-Bebek Uyumluluğu',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Anne-bebek uyumluluğunu görmek için anne profilinizi oluşturun.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalityDescriptionCard(
    ZodiacCharacteristics characteristics,
  ) {
    return DashboardCard(
      title: 'Kişilik Açıklaması',
      icon: Icons.person_rounded,
      iconColor: AstrologyProvider.getZodiacColor(characteristics.zodiacSign),
      child: Text(
        characteristics.generalDescription,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: const Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildTraitsRow(ZodiacCharacteristics characteristics) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DashboardCard(
            title: 'Olumlu Özellikler',
            icon: Icons.thumb_up_rounded,
            iconColor: Colors.green,
            child: Column(
              children: characteristics.positiveTraits
                  .map((trait) => _buildTraitItem(trait, Colors.green))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardCard(
            title: 'Gelişim Alanları',
            icon: Icons.trending_up_rounded,
            iconColor: Colors.orange,
            child: Column(
              children: characteristics.challengingTraits
                  .map((trait) => _buildTraitItem(trait, Colors.orange))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeBasedRecommendations(
    ZodiacCharacteristics characteristics,
    int ageInMonths,
  ) {
    final tips = characteristics.getTipsForAge(ageInMonths);

    return DashboardCard(
      title: 'Bu Yaş İçin Öneriler ($ageInMonths Ay)',
      icon: Icons.child_care_rounded,
      iconColor: Colors.cyan,
      child: Text(
        tips,
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: const Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildDevelopmentTips(ZodiacCharacteristics characteristics) {
    return DashboardCard(
      title: 'Çocuk Gelişimi İpuçları',
      icon: Icons.lightbulb_rounded,
      iconColor: Colors.amber,
      child: Column(
        children: characteristics.childDevelopmentTips
            .map((tip) => _buildTipItem(tip, Colors.amber))
            .toList(),
      ),
    );
  }
}
