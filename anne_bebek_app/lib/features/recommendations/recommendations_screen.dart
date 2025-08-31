import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/recommendations_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/daily_recommendation_model.dart';
import '../../shared/models/weekly_recommendation_model.dart';
import '../../shared/widgets/custom_switch.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  String _selectedCategory = 'Tümü';

  final List<String> _categories = [
    'Tümü',
    'Kitap',
    'Müzik',
    'Oyun',
    'Oyuncak',
    'Aktivite',
    'Gelişim',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);
      if (babyProvider.hasBabyProfile) {
        final recommendationsProvider = Provider.of<RecommendationsProvider>(
          context,
          listen: false,
        );
        recommendationsProvider.updateTodayRecommendations(babyProvider);
        recommendationsProvider.updateThisWeekRecommendations(babyProvider);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Öneriler',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1B23),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list_rounded),
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
            Tab(text: 'Bugün'),
            Tab(text: 'Bu Hafta'),
          ],
        ),
      ),
      body: Consumer2<BabyProvider, RecommendationsProvider>(
        builder: (context, babyProvider, recommendationsProvider, child) {
          if (!babyProvider.hasBabyProfile) {
            return _buildNoDataMessage();
          }

          if (recommendationsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Category Filter
              _buildCategoryFilter(),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyRecommendations(recommendationsProvider),
                    _buildWeeklyRecommendations(recommendationsProvider),
                  ],
                ),
              ),
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
              Icons.lightbulb_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Öneriler',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bebeğinizin yaşına uygun öneriler almak için\nprofil oluşturun.',
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            selectedColor: Theme.of(context).colorScheme.primary.withAlpha(26),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFF6B7280),
            ),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFFE5E7EB),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyRecommendations(
    RecommendationsProvider recommendationsProvider,
  ) {
    final recommendations = _filterRecommendations(
      recommendationsProvider.todayRecommendations,
    );

    if (recommendations.isEmpty) {
      return _buildEmptyState('Bugün için öneri bulunamadı');
    }

    return RefreshIndicator(
      onRefresh: () async {
        final babyProvider = Provider.of<BabyProvider>(context, listen: false);
        await recommendationsProvider.updateTodayRecommendations(babyProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildDailyRecommendationCard(recommendations[index]);
        },
      ),
    );
  }

  Widget _buildWeeklyRecommendations(
    RecommendationsProvider recommendationsProvider,
  ) {
    final recommendations = _filterWeeklyRecommendations(
      recommendationsProvider.thisWeekRecommendations,
    );

    if (recommendations.isEmpty) {
      return _buildEmptyState('Bu hafta için öneri bulunamadı');
    }

    return RefreshIndicator(
      onRefresh: () async {
        final babyProvider = Provider.of<BabyProvider>(context, listen: false);
        await recommendationsProvider.updateThisWeekRecommendations(
          babyProvider,
        );
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: recommendations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildWeeklyRecommendationCard(recommendations[index]);
        },
      ),
    );
  }

  List<DailyRecommendationModel> _filterRecommendations(
    List<DailyRecommendationModel> recommendations,
  ) {
    if (_selectedCategory == 'Tümü') {
      return recommendations;
    }
    return recommendations
        .where((rec) => rec.category.name == _selectedCategory)
        .toList();
  }

  List<WeeklyRecommendationModel> _filterWeeklyRecommendations(
    List<WeeklyRecommendationModel> recommendations,
  ) {
    if (_selectedCategory == 'Tümü') {
      return recommendations;
    }
    return recommendations
        .where((rec) => rec.category.name == _selectedCategory)
        .toList();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'Tümü';
                });
              },
              child: const Text('Tüm Kategorileri Göster'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRecommendationCard(
    DailyRecommendationModel recommendation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(
                recommendation.category.name,
              ).withAlpha(26),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      recommendation.category.name,
                    ).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(recommendation.category.name),
                    color: _getCategoryColor(recommendation.category.name),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.category.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(
                            recommendation.category.name,
                          ),
                        ),
                      ),
                      Text(
                        recommendation.ageGroup.name,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Gün ${recommendation.dayNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),

                // Benefits
                if (recommendation.benefits.isNotEmpty) ...[
                  Text(
                    'Faydaları:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1B23),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...recommendation.benefits.map(
                    (benefit) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _getCategoryColor(
                                recommendation.category.name,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              benefit,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Source
                if (recommendation.source != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.source_rounded,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kaynak: ${recommendation.source}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRecommendationCard(
    WeeklyRecommendationModel recommendation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(
                recommendation.category.name,
              ).withAlpha(26),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(
                      recommendation.category.name,
                    ).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(recommendation.category.name),
                    color: _getCategoryColor(recommendation.category.name),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.category.name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(
                            recommendation.category.name,
                          ),
                        ),
                      ),
                      Text(
                        '${recommendation.ageYears} yaş',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Hafta ${recommendation.weekNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 12),

                // Activities
                if (recommendation.activities.isNotEmpty) ...[
                  Text(
                    'Aktiviteler:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1B23),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...recommendation.activities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _getCategoryColor(
                                recommendation.category.name,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              activity,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Duration
                if (recommendation.estimatedDuration != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Süre: ${recommendation.estimatedDuration} dakika',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kitap':
        return Colors.blue;
      case 'müzik':
        return Colors.purple;
      case 'oyun':
      case 'oyuncak':
        return Colors.orange;
      case 'aktivite':
        return Colors.green;
      case 'gelişim':
        return Colors.teal;
      default:
        return Colors.indigo;
    }
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Kategori Filtresi',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: CustomRadioGroup<String>(
          value: _selectedCategory,
          onChanged: (String? value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
              Navigator.pop(context);
            }
          },
          options: _categories
              .map((category) => RadioOption(value: category, title: category))
              .toList(),
        ),
      ),
    );
  }
}
