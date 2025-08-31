import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/enums/sort_option.dart';
import '../../shared/providers/culture_provider.dart';
import '../../shared/models/cultural_tradition_model.dart';
import '../../shared/widgets/tradition_card.dart';
import '../../shared/widgets/category_filter_chip.dart';

class TraditionListScreen extends StatefulWidget {
  final CulturalOrigin? initialOrigin;
  final TraditionCategory? initialCategory;
  final AgeRange? initialAgeRange;
  final String? title;

  const TraditionListScreen({
    super.key,
    this.initialOrigin,
    this.initialCategory,
    this.initialAgeRange,
    this.title,
  });

  @override
  State<TraditionListScreen> createState() => _TraditionListScreenState();
}

class _TraditionListScreenState extends State<TraditionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();

    // Set initial filters if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cultureProvider = Provider.of<CultureProvider>(
        context,
        listen: false,
      );

      if (widget.initialOrigin != null) {
        cultureProvider.filterByOrigin(widget.initialOrigin);
      }
      if (widget.initialCategory != null) {
        cultureProvider.filterByCategory(widget.initialCategory);
      }
      if (widget.initialAgeRange != null) {
        cultureProvider.filterByAgeRange(widget.initialAgeRange);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: Consumer<CultureProvider>(
        builder: (context, cultureProvider, child) {
          return Column(
            children: [
              // Search and filters
              _buildSearchAndFilters(context, cultureProvider),

              // Results count
              _buildResultsCount(context, cultureProvider),

              // Traditions list
              Expanded(child: _buildTraditionsList(context, cultureProvider)),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title ?? 'Gelenekler',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1B23),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Color(0xFF1A1B23)),
      actions: [
        Consumer<CultureProvider>(
          builder: (context, cultureProvider, child) {
            return IconButton(
              onPressed: () {
                _showSortBottomSheet(context, cultureProvider);
              },
              icon: const Icon(Icons.sort),
            );
          },
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

  Widget _buildResultsCount(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    final filteredCount = cultureProvider.filteredTraditions.length;
    final totalCount = cultureProvider.totalTraditions;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFF8F9FA),
      child: Text(
        cultureProvider.hasActiveFilters ||
                cultureProvider.searchQuery.isNotEmpty
            ? '$filteredCount gelenek bulundu (toplam $totalCount)'
            : '$totalCount gelenek',
        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
      ),
    );
  }

  Widget _buildTraditionsList(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    final traditions = cultureProvider.filteredTraditions;

    if (cultureProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (traditions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: traditions.length,
      itemBuilder: (context, index) {
        return TraditionCard(tradition: traditions[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gelenek Bulunamadı',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aradığınız kriterlere uygun gelenek\nbulunamadı. Filtreleri değiştirmeyi deneyin.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<CultureProvider>(
              builder: (context, cultureProvider, child) {
                if (cultureProvider.hasActiveFilters) {
                  return ElevatedButton.icon(
                    onPressed: cultureProvider.clearAllFilters,
                    icon: const Icon(Icons.clear),
                    label: const Text('Filtreleri Temizle'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(
    BuildContext context,
    CultureProvider cultureProvider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sıralama',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                ),
              ),
              const SizedBox(height: 16),

              _buildSortOption(
                'Alfabetik (A-Z)',
                Icons.sort_by_alpha,
                SortOption.alphabeticalAZ,
                cultureProvider,
              ),
              _buildSortOption(
                'Alfabetik (Z-A)',
                Icons.sort_by_alpha,
                SortOption.alphabeticalZA,
                cultureProvider,
              ),
              _buildSortOption(
                'Kategoriye Göre',
                Icons.category,
                SortOption.byCategory,
                cultureProvider,
              ),
              _buildSortOption(
                'Yaş Aralığına Göre',
                Icons.child_care,
                SortOption.byAgeRange,
                cultureProvider,
              ),
              _buildSortOption(
                'Kökene Göre',
                Icons.public,
                SortOption.byOrigin,
                cultureProvider,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    String title,
    IconData icon,
    SortOption option,
    CultureProvider provider,
  ) {
    final bool isSelected = provider.sortOption == option;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : const Color(0xFF6B7280),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFF1A1B23),
        ),
      ),
      onTap: () {
        provider.sortTraditions(option);
        Navigator.pop(context);
      },
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      contentPadding: EdgeInsets.zero,
    );
  }
}
