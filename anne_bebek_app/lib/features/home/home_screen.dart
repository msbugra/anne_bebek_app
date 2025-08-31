import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/recommendations_provider.dart';
import '../../shared/providers/ad_provider.dart';
import '../../features/ads/ad_placement_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/ad_constants.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/stat_card.dart';
import '../../core/utils/age_calculator.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final recommendationsProvider = Provider.of<RecommendationsProvider>(
      context,
      listen: false,
    );

    if (babyProvider.currentBaby != null) {
      await recommendationsProvider.updateTodayRecommendations(babyProvider);
      await recommendationsProvider.updateThisWeekRecommendations(babyProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Consumer3<BabyProvider, RecommendationsProvider, AdProvider>(
          builder:
              (
                context,
                babyProvider,
                recommendationsProvider,
                adProvider,
                child,
              ) {
                // Loading state
                if (babyProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Bebek profili yoksa mesaj göster
                if (!babyProvider.hasBabyProfile ||
                    babyProvider.currentBaby == null) {
                  return _buildWelcomeMessage();
                }

                final baby = babyProvider.currentBaby!;
                final formattedAge = babyProvider.formattedAge ?? '';
                final todayRecommendations =
                    recommendationsProvider.todayRecommendations;
                final thisWeekRecommendations =
                    recommendationsProvider.thisWeekRecommendations;

                return CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 120,
                      floating: true,
                      pinned: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildHeader(baby, formattedAge),
                      ),
                    ),

                    // Main Content
                    SliverPadding(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Günün Öne Çıkanları
                          _buildTodayHighlights(
                            baby,
                            todayRecommendations,
                            thisWeekRecommendations,
                          ),
                          const SizedBox(height: 24),

                          // Quick Stats
                          _buildQuickStats(baby),
                          const SizedBox(height: 24),

                          // Action Buttons
                          _buildActionButtons(context),
                          const SizedBox(height: 24),

                          // Recent Recommendations
                          _buildRecentRecommendations(
                            todayRecommendations,
                            thisWeekRecommendations,
                          ),
                          const SizedBox(height: 24),

                          // Banner Ad
                          _buildBannerAd(adProvider),
                          const SizedBox(
                            height: 100,
                          ), // Bottom padding for navigation
                        ]),
                      ),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.baby_changing_station_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Hoş Geldiniz!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bebeğinizin gelişimini takip etmek için\nprofil oluşturmanız gerekiyor.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to profile creation
              },
              child: const Text('Profil Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(baby, String formattedAge) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: SafeArea(
        child: Row(
          children: [
            // Baby Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.baby_changing_station_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),

            // Baby Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    baby.name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1B23),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedAge,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Settings Button
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.settings_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHighlights(
    baby,
    todayRecommendations,
    thisWeekRecommendations,
  ) {
    return DashboardCard(
      title: 'Günün Öne Çıkanları',
      icon: Icons.star_rounded,
      child: Column(
        children: [
          // Gelişimsel Bilgi
          _buildHighlightItem(
            icon: Icons.psychology_rounded,
            title: 'Gelişimsel Dönem',
            subtitle:
                AgeCalculator.getDevelopmentalStage(baby.birthDate) ??
                'Bilinmiyor',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),

          // Sonraki Doğum Günü
          _buildNextBirthdayItem(baby),
          const SizedBox(height: 16),

          // Günün Önerisi
          if (todayRecommendations.isNotEmpty)
            _buildHighlightItem(
              icon: Icons.lightbulb_rounded,
              title: 'Bugünün Önerisi',
              subtitle: todayRecommendations.first.title,
              color: Colors.amber,
            )
          else if (thisWeekRecommendations.isNotEmpty)
            _buildHighlightItem(
              icon: Icons.lightbulb_rounded,
              title: 'Bu Haftanın Önerisi',
              subtitle: thisWeekRecommendations.first.title,
              color: Colors.amber,
            ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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

  Widget _buildNextBirthdayItem(baby) {
    final timeUntilBirthday = AgeCalculator.timeUntilNextBirthday(
      baby.birthDate,
    );

    final daysLeft = timeUntilBirthday.inDays;

    return _buildHighlightItem(
      icon: Icons.cake_rounded,
      title: 'Sonraki Doğum Günü',
      subtitle: daysLeft > 0 ? '$daysLeft gün kaldı' : 'Bugün doğum günü! 🎉',
      color: Colors.pink,
    );
  }

  Widget _buildQuickStats(baby) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İstatistikler',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1B23),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Yaş',
                value: '${baby.ageInDays} gün',
                subtitle: '${baby.ageInWeeks} hafta',
                icon: Icons.schedule_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Gelişim',
                value: baby.ageGroup ?? '',
                subtitle: 'Dönem',
                icon: Icons.trending_up_rounded,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (baby.birthWeight != null)
              Expanded(
                child: StatCard(
                  title: 'Doğum Kilosu',
                  value: '${baby.birthWeight!.toStringAsFixed(1)} kg',
                  subtitle: 'İlk ölçüm',
                  icon: Icons.monitor_weight_rounded,
                  color: Colors.orange,
                ),
              ),
            if (baby.birthWeight != null && baby.birthHeight != null)
              const SizedBox(width: 12),
            if (baby.birthHeight != null)
              Expanded(
                child: StatCard(
                  title: 'Doğum Boyu',
                  value: '${baby.birthHeight!.toStringAsFixed(1)} cm',
                  subtitle: 'İlk ölçüm',
                  icon: Icons.height_rounded,
                  color: Colors.purple,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı İşlemler',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1B23),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_chart_rounded,
                label: 'Ölçüm Ekle',
                color: Colors.blue,
                onTap: () {
                  // Navigate to growth tracking
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.restaurant_rounded,
                label: 'Beslenme',
                color: Colors.orange,
                onTap: () {
                  // Navigate to feeding tracking
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bedtime_rounded,
                label: 'Uyku',
                color: Colors.indigo,
                onTap: () {
                  // Navigate to sleep tracking
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1B23),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecommendations(
    todayRecommendations,
    thisWeekRecommendations,
  ) {
    final hasRecommendations =
        todayRecommendations.isNotEmpty || thisWeekRecommendations.isNotEmpty;

    if (!hasRecommendations) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Öneriler',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to recommendations tab
                // BottomNavHelper.navigateToTab(context, 2);
              },
              child: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayRecommendations.isNotEmpty)
          ...todayRecommendations
              .take(2)
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRecommendationItem(
                    rec.title,
                    rec.category.name,
                    rec.ageGroup.name,
                  ),
                ),
              )
        else if (thisWeekRecommendations.isNotEmpty)
          ...thisWeekRecommendations
              .take(2)
              .map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRecommendationItem(
                    rec.title,
                    rec.category.name,
                    '${rec.ageYears} yaş',
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildRecommendationItem(
    String title,
    String category,
    String ageInfo,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                Text(
                  '$category • $ageInfo',
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kitap':
        return Icons.menu_book_rounded;
      case 'müzik':
        return Icons.music_note_rounded;
      case 'oyun':
      case 'oyuncak':
        return Icons.toys_rounded;
      case 'aktivite':
        return Icons.directions_run_rounded;
      case 'gelişim':
        return Icons.psychology_rounded;
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Widget _buildBannerAd(AdProvider adProvider) {
    final adPlacementManager = AdPlacementManager(adProvider);
    return adPlacementManager.getHomeScreenBannerAd(
          onAdStatusChanged: (status) {
            if (AdConstants.enableAdLogging) {
              debugPrint('🏠 Home screen banner ad status: $status');
            }
          },
        ) ??
        const SizedBox.shrink();
  }
}
