import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/culture_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/cultural_tradition_model.dart';
import '../../shared/widgets/tradition_card.dart';
import '../../shared/widgets/category_filter_chip.dart';
import 'favorites_screen.dart';

class CultureScreen extends StatefulWidget {
  const CultureScreen({super.key});

  @override
  State<CultureScreen> createState() => _CultureScreenState();
}

class _CultureScreenState extends State<CultureScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CultureProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<CultureProvider>(
        builder: (context, cultureProvider, child) {
          if (cultureProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              _buildSliverAppBar(context, cultureProvider),
            ],
            body: Column(
              children: [
                // Search and filters
                _buildSearchAndFilters(context, cultureProvider),

                // Tab bar
                _buildTabBar(context, cultureProvider),

                // Tab view content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTurkishTraditionsTab(cultureProvider),
                      _buildWorldTraditionsTab(cultureProvider),
                      _buildAgeBasedTab(context, cultureProvider),
                      _buildFavoritesTab(context, cultureProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    return SliverAppBar(
      title: Text(
        'Kültür & Değerler',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1B23),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      floating: true,
      snap: true,
      actions: [
        // Statistics badge
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.library_books,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${cultureProvider.totalTraditions}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: cultureProvider.searchTraditions,
              decoration: InputDecoration(
                hintText: 'Geleneklerde ara...',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          cultureProvider.clearSearch();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(
                          Icons.tune,
                          color: cultureProvider.hasActiveFilters
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFF6B7280),
                        ),
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Expandable filters
          if (_showFilters) ...[
            const SizedBox(height: 16),
            CultureFilters(
              selectedOrigin: cultureProvider.selectedOrigin,
              selectedCategory: cultureProvider.selectedCategory,
              selectedAgeRange: cultureProvider.selectedAgeRange,
              onOriginChanged: cultureProvider.filterByOrigin,
              onCategoryChanged: cultureProvider.filterByCategory,
              onAgeRangeChanged: cultureProvider.filterByAgeRange,
              onClearAll: cultureProvider.clearAllFilters,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, CultureProvider cultureProvider) {
    return Container(
      color: Colors.white,
      child: TabBar(
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
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.flag, size: 16),
                const SizedBox(width: 4),
                Text('Türk (${cultureProvider.turkishTraditionsCount})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 16),
                const SizedBox(width: 4),
                Text('Dünya (${cultureProvider.worldTraditionsCount})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.child_care, size: 16),
                const SizedBox(width: 4),
                const Text('Yaş Bazlı'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 16),
                const SizedBox(width: 4),
                Text('Favoriler (${cultureProvider.favoritesCount})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurkishTraditionsTab(CultureProvider cultureProvider) {
    final traditions = cultureProvider.searchQuery.isNotEmpty
        ? cultureProvider.filteredTraditions
              .where((t) => t.origin == CulturalOrigin.turkish)
              .toList()
        : cultureProvider.turkishTraditions;

    return _buildTraditionsList(
      traditions: traditions,
      emptyMessage: 'Türk gelenekleri bulunamadı',
      emptyIcon: Icons.flag,
    );
  }

  Widget _buildWorldTraditionsTab(CultureProvider cultureProvider) {
    final traditions = cultureProvider.searchQuery.isNotEmpty
        ? cultureProvider.filteredTraditions
              .where((t) => t.origin == CulturalOrigin.world)
              .toList()
        : cultureProvider.worldTraditions;

    return _buildTraditionsList(
      traditions: traditions,
      emptyMessage: 'Dünya gelenekleri bulunamadı',
      emptyIcon: Icons.language,
    );
  }

  Widget _buildAgeBasedTab(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    return Consumer<BabyProvider>(
      builder: (context, babyProvider, child) {
        if (babyProvider.currentBaby == null) {
          return _buildEmptyState(
            icon: Icons.child_care,
            message:
                'Yaş bazlı gelenekleri görmek için\nbebek profili oluşturun',
            actionText: 'Profil Oluştur',
            onAction: () {
              // Navigate to baby registration
            },
          );
        }

        // Get age-appropriate traditions
        final babyAgeInDays = babyProvider.babyAgeInDays ?? 0;
        final ageAppropriateTraditions =
            CulturalTraditionService.getTraditionsForBabyAge(
              cultureProvider.allTraditions,
              babyAgeInDays,
            );

        return Column(
          children: [
            // Age info header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.child_care, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${babyProvider.currentBaby!.name} için',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${babyProvider.formattedAge} - ${ageAppropriateTraditions.length} gelenek',
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
            ),

            // Traditions list
            Expanded(
              child: _buildTraditionsList(
                traditions: ageAppropriateTraditions,
                emptyMessage: 'Bu yaş için uygun gelenek bulunamadı',
                emptyIcon: Icons.child_care,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    return FavoritesScreen();
  }

  Widget _buildTraditionsList({
    required List<CulturalTraditionModel> traditions,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (traditions.isEmpty) {
      return _buildEmptyState(icon: emptyIcon, message: emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: traditions.length,
      itemBuilder: (context, index) {
        return TraditionCard(tradition: traditions[index]);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }
}
