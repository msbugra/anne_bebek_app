import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/astrology_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/zodiac_card.dart';
import '../../shared/models/astrological_profile_model.dart';
import '../../shared/models/zodiac_characteristics_model.dart';
import '../../core/utils/zodiac_calculator.dart';
import 'birth_chart_screen.dart';

class ZodiacDetailScreen extends StatefulWidget {
  final ZodiacSign zodiacSign;
  final ZodiacCharacteristics? characteristics;

  const ZodiacDetailScreen({
    super.key,
    required this.zodiacSign,
    this.characteristics,
  });

  @override
  State<ZodiacDetailScreen> createState() => _ZodiacDetailScreenState();
}

class _ZodiacDetailScreenState extends State<ZodiacDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          '${ZodiacCalculator.getZodiacName(widget.zodiacSign)} Burcu',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.account_tree_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BirthChartScreen(),
                ),
              );
            },
            tooltip: 'Doğum Haritası',
          ),
        ],
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
            Tab(text: 'Genel'),
            Tab(text: 'Kişilik'),
            Tab(text: 'Yaşam'),
          ],
        ),
      ),
      body: Consumer2<BabyProvider, AstrologyProvider>(
        builder: (context, babyProvider, astrologyProvider, child) {
          final characteristics =
              widget.characteristics ??
              ZodiacCharacteristicsService.findCharacteristics(
                widget.zodiacSign,
              );

          return TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(characteristics),
              _buildPersonalityTab(characteristics),
              _buildLifeTab(characteristics, babyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGeneralTab(ZodiacCharacteristics? characteristics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana Burç Kartı
          ZodiacCard(
            zodiacSign: widget.zodiacSign,
            characteristics: characteristics,
            showDescription: true,
            compact: false,
          ),
          const SizedBox(height: 24),

          // Temel Bilgiler
          _buildBasicInfo(),
          const SizedBox(height: 24),

          // Element ve Yönetici Gezegen
          _buildElementAndPlanet(characteristics),
          const SizedBox(height: 24),

          // Ünlü İsimler
          _buildFamousPeople(),
          const SizedBox(height: 24),

          // Burç Efsanesi
          _buildZodiacMyth(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPersonalityTab(ZodiacCharacteristics? characteristics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (characteristics != null) ...[
            // Kişilik Açıklaması
            DashboardCard(
              title: 'Kişilik Analizi',
              icon: Icons.psychology_rounded,
              iconColor: AstrologyProvider.getZodiacColor(widget.zodiacSign),
              child: Text(
                characteristics.generalDescription,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Olumlu Özellikler
            _buildTraitsSection(
              'Olumlu Özellikler',
              characteristics.positiveTraits,
              Colors.green,
              Icons.thumb_up_rounded,
            ),
            const SizedBox(height: 24),

            // Gelişim Alanları
            _buildTraitsSection(
              'Gelişim Alanları',
              characteristics.challengingTraits,
              Colors.orange,
              Icons.trending_up_rounded,
            ),
            const SizedBox(height: 24),

            // Güçlü Yanlar
            DashboardCard(
              title: 'Güçlü Yanlar',
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
              child: Text(
                characteristics.strengthsDescription,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
          ] else ...[
            _buildNoDataMessage('Kişilik verileri yükleniyor...'),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLifeTab(
    ZodiacCharacteristics? characteristics,
    BabyProvider babyProvider,
  ) {
    final ageInMonths = babyProvider.babyAgeInMonths ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (characteristics != null) ...[
            // Yaşa Özel Öneriler
            if (ageInMonths > 0) ...[
              _buildAgeSpecificSection(characteristics, ageInMonths),
              const SizedBox(height: 24),
            ],

            // Çocuk Gelişimi
            DashboardCard(
              title: 'Çocuk Gelişimi Önerileri',
              icon: Icons.child_care_rounded,
              iconColor: Colors.cyan,
              child: Column(
                children: characteristics.childDevelopmentTips
                    .map((tip) => _buildTipItem(tip, Colors.cyan))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // İletişim İpuçları
            DashboardCard(
              title: 'Anne-Çocuk İletişimi',
              icon: Icons.chat_rounded,
              iconColor: Colors.purple,
              child: Column(
                children: characteristics.parentChildCommunicationTips
                    .map((tip) => _buildTipItem(tip, Colors.purple))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Ebeveynlik Yaklaşımı
            DashboardCard(
              title: 'Ebeveynlik Yaklaşımı',
              icon: Icons.family_restroom_rounded,
              iconColor: Colors.blue,
              child: Text(
                characteristics.parentingApproach,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Aylık Tahmin
            _buildMonthlyForecast(),
          ] else ...[
            _buildNoDataMessage('Yaşam önerileri yükleniyor...'),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return DashboardCard(
      title: 'Temel Bilgiler',
      icon: Icons.info_rounded,
      child: Column(
        children: [
          _buildInfoItem(
            'Burç Adı',
            ZodiacCalculator.getZodiacName(widget.zodiacSign),
          ),
          _buildInfoItem(
            'Tarih Aralığı',
            ZodiacCalculator.getZodiacDateRange(widget.zodiacSign),
          ),
          _buildInfoItem(
            'Element',
            ZodiacCalculator.getElementName(
              ZodiacCalculator.getZodiacElement(widget.zodiacSign),
            ),
          ),
          _buildInfoItem(
            'Sembol',
            AstrologyProvider.getZodiacEmoji(widget.zodiacSign),
          ),
          _buildInfoItem('Renk', _getPrimaryColor()),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
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

  Widget _buildElementAndPlanet(ZodiacCharacteristics? characteristics) {
    final element = ZodiacCalculator.getZodiacElement(widget.zodiacSign);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AstrologyProvider.getElementGradient(element),
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AstrologyProvider.getZodiacColor(
                    widget.zodiacSign,
                  ).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  AstrologyProvider.getElementIcon(element),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Element',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  ZodiacCalculator.getElementName(element),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getElementDescription(element),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
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
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.public_rounded,
                  color: AstrologyProvider.getZodiacColor(widget.zodiacSign),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Yönetici Gezegen',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  characteristics?.rulingPlanet ?? _getRulingPlanet(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getPlanetDescription(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTraitsSection(
    String title,
    List<String> traits,
    Color color,
    IconData icon,
  ) {
    return DashboardCard(
      title: title,
      icon: icon,
      iconColor: color,
      child: Column(
        children: traits.map((trait) => _buildTraitItem(trait, color)).toList(),
      ),
    );
  }

  Widget _buildTraitItem(String trait, Color color) {
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

  Widget _buildAgeSpecificSection(
    ZodiacCharacteristics characteristics,
    int ageInMonths,
  ) {
    final tips = characteristics.getTipsForAge(ageInMonths);

    return DashboardCard(
      title: 'Bu Yaş İçin Özel Öneriler ($ageInMonths Ay)',
      icon: Icons.cake_rounded,
      iconColor: Colors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tips,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamousPeople() {
    final famousPeople = _getFamousPeopleForSign(widget.zodiacSign);

    return DashboardCard(
      title:
          'Ünlü ${ZodiacCalculator.getZodiacName(widget.zodiacSign)} Burçları',
      icon: Icons.star_rounded,
      iconColor: Colors.amber,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: famousPeople
            .map(
              (name) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildZodiacMyth() {
    return DashboardCard(
      title: 'Burç Efsanesi',
      icon: Icons.auto_stories_rounded,
      iconColor: Colors.indigo,
      child: Text(
        _getZodiacMythForSign(widget.zodiacSign),
        style: GoogleFonts.inter(
          fontSize: 14,
          height: 1.6,
          color: const Color(0xFF4B5563),
        ),
      ),
    );
  }

  Widget _buildMonthlyForecast() {
    final forecast = ZodiacCalculator.getMonthlyForecast(
      widget.zodiacSign,
      DateTime.now().month,
      DateTime.now().year,
    );

    return DashboardCard(
      title: 'Bu Ay İçin Tahmin',
      icon: Icons.calendar_month_rounded,
      iconColor: Colors.indigo,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                forecast,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _getPrimaryColor() {
    final color = AstrologyProvider.getZodiacColor(widget.zodiacSign);
    if (color == Colors.red) return 'Kırmızı';
    if (color == Colors.green) return 'Yeşil';
    if (color == Colors.blue) return 'Mavi';
    if (color == Colors.orange) return 'Turuncu';
    if (color == Colors.purple) return 'Mor';
    if (color == Colors.pink) return 'Pembe';
    if (color == Colors.yellow) return 'Sarı';
    if (color == Colors.cyan) return 'Turkuaz';
    if (color == Colors.indigo) return 'İndigo';
    if (color == Colors.teal) return 'Deniz Yeşili';
    if (color == Colors.grey) return 'Gri';
    return 'Özel Renk';
  }

  String _getRulingPlanet() {
    switch (widget.zodiacSign) {
      case ZodiacSign.aries:
        return 'Mars';
      case ZodiacSign.taurus:
        return 'Venüs';
      case ZodiacSign.gemini:
        return 'Merkür';
      case ZodiacSign.cancer:
        return 'Ay';
      case ZodiacSign.leo:
        return 'Güneş';
      case ZodiacSign.virgo:
        return 'Merkür';
      case ZodiacSign.libra:
        return 'Venüs';
      case ZodiacSign.scorpio:
        return 'Mars/Pluto';
      case ZodiacSign.sagittarius:
        return 'Jüpiter';
      case ZodiacSign.capricorn:
        return 'Satürn';
      case ZodiacSign.aquarius:
        return 'Satürn/Uranüs';
      case ZodiacSign.pisces:
        return 'Jüpiter/Neptün';
    }
  }

  String _getElementDescription(ZodiacElement element) {
    switch (element) {
      case ZodiacElement.fire:
        return 'Enerji, coşku ve yaratıcılık';
      case ZodiacElement.earth:
        return 'İstikrar, güvenilirlik ve pratiklik';
      case ZodiacElement.air:
        return 'İletişim, sosyallik ve zihinsel aktivite';
      case ZodiacElement.water:
        return 'Duygusal derinlik, sezgi ve empati';
    }
  }

  String _getPlanetDescription() {
    final planet = _getRulingPlanet();
    switch (planet) {
      case 'Mars':
        return 'Enerji, cesaret ve hareket';
      case 'Venüs':
        return 'Sevgi, estetik ve uyum';
      case 'Merkür':
        return 'İletişim, zeka ve öğrenme';
      case 'Ay':
        return 'Duygular, sezgi ve koruyuculuk';
      case 'Güneş':
        return 'Yaşam enerjisi, ego ve yaratıcılık';
      case 'Jüpiter':
        return 'Büyüme, şans ve bilgelik';
      case 'Satürn':
        return 'Disiplin, sorumluluk ve yapı';
      default:
        return 'Karmaşık gezegen etkisi';
    }
  }

  List<String> _getFamousPeopleForSign(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return ['Leonardo da Vinci', 'Vincent van Gogh', 'Maya Angelou'];
      case ZodiacSign.taurus:
        return ['William Shakespeare', 'Audrey Hepburn', 'Queen Elizabeth II'];
      case ZodiacSign.gemini:
        return ['John F. Kennedy', 'Marilyn Monroe', 'Bob Dylan'];
      case ZodiacSign.cancer:
        return ['Nelson Mandela', 'Frida Kahlo', 'Princess Diana'];
      case ZodiacSign.leo:
        return ['Napoleon Bonaparte', 'Madonna', 'Barack Obama'];
      case ZodiacSign.virgo:
        return ['Mother Teresa', 'Michael Jackson', 'Warren Buffett'];
      case ZodiacSign.libra:
        return ['Mahatma Gandhi', 'John Lennon', 'Oscar Wilde'];
      case ZodiacSign.scorpio:
        return ['Pablo Picasso', 'Marie Curie', 'Theodore Roosevelt'];
      case ZodiacSign.sagittarius:
        return ['Walt Disney', 'Winston Churchill', 'Bruce Lee'];
      case ZodiacSign.capricorn:
        return ['Martin Luther King Jr.', 'Stephen Hawking', 'Muhammad Ali'];
      case ZodiacSign.aquarius:
        return ['Thomas Edison', 'Abraham Lincoln', 'Oprah Winfrey'];
      case ZodiacSign.pisces:
        return ['Albert Einstein', 'Steve Jobs', 'Rihanna'];
    }
  }

  String _getZodiacMythForSign(ZodiacSign sign) {
    switch (sign) {
      case ZodiacSign.aries:
        return 'Altın postu arayan Argonautlar\'ın hikayesinden gelen koç, cesaret ve liderlik sembolüdür.';
      case ZodiacSign.taurus:
        return 'Zeus\'un Europa\'yı kaçırmak için dönüştüğü beyaz boğa, güç ve kararlılık simgesidir.';
      case ZodiacSign.gemini:
        return 'Castor ve Pollux ikizleri, sadakat ve kardeşlik bağının gücünü temsil eder.';
      case ZodiacSign.cancer:
        return 'Hera\'nın gönderdiği yengeç, koruyuculuk ve ev sevgisinin sembolüdür.';
      case ZodiacSign.leo:
        return 'Heracles\'in yendiği Nemea aslanı, cesaret ve krali gücün simgesidir.';
      case ZodiacSign.virgo:
        return 'Adalet tanrıçası Astraea, saflık ve mükemmeliyetçiliğin temsilcisidir.';
      case ZodiacSign.libra:
        return 'Adalet tanrıçası Themis\'in terazisi, denge ve adaleti simgeler.';
      case ZodiacSign.scorpio:
        return 'Orion\'u sokarak öldüren akrep, güç ve dönüşümün sembolüdür.';
      case ZodiacSign.sagittarius:
        return 'Kentaur Chiron, bilgelik ve öğretmenliğin simgesidir.';
      case ZodiacSign.capricorn:
        return 'Keçi tanrı Pan, azim ve zirveye ulaşma iradesini temsil eder.';
      case ZodiacSign.aquarius:
        return 'Su taşıyan Ganymedes, insanlığa hizmet etme idealini simgeler.';
      case ZodiacSign.pisces:
        return 'Afrodit ve Eros\'un balığa dönüştüğü hikaye, sevgi ve merhameti temsil eder.';
    }
  }
}
