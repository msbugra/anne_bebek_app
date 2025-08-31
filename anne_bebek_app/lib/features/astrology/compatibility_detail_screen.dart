import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/astrology_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/compatibility_card.dart';
import '../../shared/models/zodiac_compatibility_model.dart';
import '../../shared/models/astrological_profile_model.dart';
import '../../core/utils/zodiac_calculator.dart';

class CompatibilityDetailScreen extends StatefulWidget {
  final ZodiacCompatibility? compatibility;

  const CompatibilityDetailScreen({super.key, this.compatibility});

  @override
  State<CompatibilityDetailScreen> createState() =>
      _CompatibilityDetailScreenState();
}

class _CompatibilityDetailScreenState extends State<CompatibilityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'Uyumluluk Analizi',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: Theme.of(context).colorScheme.primary,
          isScrollable: true,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Genel Bakış'),
            Tab(text: 'Güçlü Yanlar'),
            Tab(text: 'Zorlu Yanlar'),
            Tab(text: 'Öneriler'),
          ],
        ),
      ),
      body: Consumer2<BabyProvider, AstrologyProvider>(
        builder: (context, babyProvider, astrologyProvider, child) {
          final compatibility =
              widget.compatibility ?? astrologyProvider.currentCompatibility;

          if (compatibility == null) {
            return _buildNoDataMessage();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(compatibility, babyProvider),
              _buildStrengthsTab(compatibility),
              _buildChallengesTab(compatibility),
              _buildTipsTab(compatibility, babyProvider),
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
            Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: Colors.pink.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Uyumluluk Verisi Bulunamadı',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Anne-bebek uyumluluk analizini görmek için\nprofilleri oluşturun.',
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

  Widget _buildOverviewTab(
    ZodiacCompatibility compatibility,
    BabyProvider babyProvider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ana Uyumluluk Kartı
          CompatibilityCard(compatibility: compatibility, compact: false),
          const SizedBox(height: 24),

          // Detaylı Skor Analizi
          _buildDetailedScoreAnalysis(compatibility),
          const SizedBox(height: 24),

          // Element Uyumluluğu
          _buildElementCompatibility(compatibility),
          const SizedBox(height: 24),

          // Aylık Tahmin
          if (compatibility.monthlyForecast != null)
            _buildMonthlyForecast(compatibility),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStrengthsTab(ZodiacCompatibility compatibility) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compatibility.strengths.isNotEmpty) ...[
            _buildSectionHeader(
              'Güçlü Yanlarınız',
              'Bu alanlar sizin avantajlarınız',
              Icons.thumb_up_rounded,
              Colors.green,
            ),
            const SizedBox(height: 16),
            ...compatibility.strengths.asMap().entries.map(
              (entry) => _buildStrengthItem(entry.key + 1, entry.value),
            ),
          ] else ...[
            _buildEmptyState(
              'Henüz Güçlü Yan Tespit Edilemedi',
              'Uyumluluk analizi geliştirildikçe güçlü yanlarınız belirlenecek.',
              Icons.psychology_rounded,
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildChallengesTab(ZodiacCompatibility compatibility) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compatibility.challenges.isNotEmpty) ...[
            _buildSectionHeader(
              'Dikkat Edilecek Noktalar',
              'Bu alanlar gelişime açık konular',
              Icons.warning_rounded,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            ...compatibility.challenges.asMap().entries.map(
              (entry) => _buildChallengeItem(entry.key + 1, entry.value),
            ),
          ] else ...[
            _buildEmptyState(
              'Önemli Zorluk Tespit Edilmedi',
              'Bu uyumlulukta belirgin zorluklar bulunmuyor.',
              Icons.check_circle_rounded,
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTipsTab(
    ZodiacCompatibility compatibility,
    BabyProvider babyProvider,
  ) {
    final ageInMonths = babyProvider.babyAgeInMonths ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ebeveynlik Önerileri
          if (compatibility.parentingTips.isNotEmpty) ...[
            CompatibilityTipsCard(
              title: 'Ebeveynlik Önerileri',
              tips: compatibility.parentingTips,
              icon: Icons.family_restroom_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
          ],

          // İletişim İpuçları
          if (compatibility.communicationTips.isNotEmpty) ...[
            CompatibilityTipsCard(
              title: 'İletişim İpuçları',
              tips: compatibility.communicationTips,
              icon: Icons.chat_rounded,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
          ],

          // Yaşa Özel Öneriler
          _buildAgeSpecificTips(compatibility, ageInMonths),
          const SizedBox(height: 24),

          // Günlük Tavsiye
          if (compatibility.dailyAdvice != null) ...[
            _buildDailyAdvice(compatibility.dailyAdvice!),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDetailedScoreAnalysis(ZodiacCompatibility compatibility) {
    return DashboardCard(
      title: 'Detaylı Skor Analizi',
      icon: Icons.analytics_rounded,
      child: Column(
        children: [
          // Ana skor
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    CompatibilityScoreIndicator(
                      score: compatibility.compatibilityScore,
                      size: 80,
                      showLabel: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${compatibility.compatibilityScore}/10',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1B23),
                      ),
                    ),
                    Text(
                      compatibility.compatibilityLevelDisplayName,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    CompatibilityProgressBar(
                      score: compatibility.compatibilityScore,
                      label: 'Genel Uyumluluk',
                    ),
                    const SizedBox(height: 16),
                    CompatibilityProgressBar(
                      score: _calculateEmotionalCompatibility(compatibility),
                      label: 'Duygusal Uyum',
                    ),
                    const SizedBox(height: 16),
                    CompatibilityProgressBar(
                      score: _calculateCommunicationCompatibility(
                        compatibility,
                      ),
                      label: 'İletişim Uyumu',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            compatibility.compatibilityDescription,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF4B5563),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildElementCompatibility(ZodiacCompatibility compatibility) {
    final motherElement = ZodiacCalculator.getZodiacElement(
      compatibility.motherSign,
    );
    final babyElement = ZodiacCalculator.getZodiacElement(
      compatibility.babySign,
    );

    return DashboardCard(
      title: 'Element Uyumluluğu',
      icon: Icons.nature_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildElementInfo(
                  'Anne',
                  motherElement,
                  ZodiacCalculator.getElementName(motherElement),
                  AstrologyProvider.getZodiacColor(compatibility.motherSign),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                _getElementCompatibilityIcon(motherElement, babyElement),
                color: _getElementCompatibilityColor(
                  motherElement,
                  babyElement,
                ),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildElementInfo(
                  'Bebek',
                  babyElement,
                  ZodiacCalculator.getElementName(babyElement),
                  AstrologyProvider.getZodiacColor(compatibility.babySign),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getElementCompatibilityColor(
                motherElement,
                babyElement,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getElementCompatibilityDescription(motherElement, babyElement),
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF4B5563),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementInfo(
    String role,
    ZodiacElement element,
    String elementName,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            AstrologyProvider.getElementIcon(element),
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          role,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          elementName,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyForecast(ZodiacCompatibility compatibility) {
    return DashboardCard(
      title: 'Bu Ay İçin Tahmin',
      icon: Icons.calendar_month_rounded,
      iconColor: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    compatibility.monthlyForecast!,
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

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1B23),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthItem(int index, String strength) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strength,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF1A1B23),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(int index, String challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              challenge,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF1A1B23),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSpecificTips(
    ZodiacCompatibility compatibility,
    int ageInMonths,
  ) {
    final tips = _getAgeSpecificCompatibilityTips(
      compatibility.motherSign,
      compatibility.babySign,
      ageInMonths,
    );

    return CompatibilityTipsCard(
      title: 'Bu Yaş İçin Özel Öneriler ($ageInMonths Ay)',
      tips: tips,
      icon: Icons.child_care_rounded,
      color: Colors.cyan,
    );
  }

  Widget _buildDailyAdvice(String advice) {
    return DashboardCard(
      title: 'Günün Tavsiyesi',
      icon: Icons.lightbulb_rounded,
      iconColor: Colors.amber,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                advice,
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

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 60, color: const Color(0xFF6B7280)),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1B23),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  int _calculateEmotionalCompatibility(ZodiacCompatibility compatibility) {
    // Duygusal uyumluluk hesaplama (basitleştirilmiş)
    return (compatibility.compatibilityScore * 0.9).round();
  }

  int _calculateCommunicationCompatibility(ZodiacCompatibility compatibility) {
    // İletişim uyumluluğu hesaplama (basitleştirilmiş)
    return (compatibility.compatibilityScore * 1.1).clamp(0, 10).round();
  }

  IconData _getElementCompatibilityIcon(
    ZodiacElement element1,
    ZodiacElement element2,
  ) {
    if (element1 == element2) return Icons.favorite_rounded;
    if (_areElementsCompatible(element1, element2)) {
      return Icons.handshake_rounded;
    }
    return Icons.balance_rounded;
  }

  Color _getElementCompatibilityColor(
    ZodiacElement element1,
    ZodiacElement element2,
  ) {
    if (element1 == element2) return Colors.green;
    if (_areElementsCompatible(element1, element2)) return Colors.blue;
    return Colors.orange;
  }

  String _getElementCompatibilityDescription(
    ZodiacElement element1,
    ZodiacElement element2,
  ) {
    if (element1 == element2) {
      return 'Aynı element: Doğal uyum ve karşılıklı anlayış var.';
    }
    if (_areElementsCompatible(element1, element2)) {
      return 'Uyumlu elementler: Birbirini destekleyici enerji akışı.';
    }
    return 'Farklı elementler: Dengeli yaklaşım ile güzel uyum sağlanabilir.';
  }

  bool _areElementsCompatible(ZodiacElement element1, ZodiacElement element2) {
    return (element1 == ZodiacElement.fire && element2 == ZodiacElement.air) ||
        (element1 == ZodiacElement.air && element2 == ZodiacElement.fire) ||
        (element1 == ZodiacElement.earth && element2 == ZodiacElement.water) ||
        (element1 == ZodiacElement.water && element2 == ZodiacElement.earth);
  }

  List<String> _getAgeSpecificCompatibilityTips(
    ZodiacSign motherSign,
    ZodiacSign babySign,
    int ageInMonths,
  ) {
    if (ageInMonths <= 6) {
      return [
        'Bu yaşta anne-bebek bağı çok önemli, fiziksel temas artırın',
        'Sakin ortam ve düzenli rutinler oluşturun',
        'Bebeğinizin doğal ritmini gözlemleyin',
      ];
    } else if (ageInMonths <= 12) {
      return [
        'Keşfetme isteğini destekleyin ama güvenli sınırlar koyun',
        'İletişim becerilerinin gelişimini teşvik edin',
        'Oyun yoluyla öğrenme fırsatları yaratın',
      ];
    } else {
      return [
        'Bağımsızlık isteğine saygı gösterin',
        'Duygusal ifade becerilerini destekleyin',
        'Sosyal etkileşimlere fırsat verin',
      ];
    }
  }
}
