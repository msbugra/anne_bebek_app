import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cultural_tradition_model.dart';

class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? effectiveColor : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? effectiveColor : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? effectiveColor : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OriginFilterChips extends StatelessWidget {
  final CulturalOrigin? selectedOrigin;
  final Function(CulturalOrigin?) onOriginChanged;

  const OriginFilterChips({
    super.key,
    this.selectedOrigin,
    required this.onOriginChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CategoryFilterChip(
          label: 'Tümü',
          isSelected: selectedOrigin == null,
          onTap: () => onOriginChanged(null),
          icon: Icons.public,
        ),
        CategoryFilterChip(
          label: 'Türk Kültürü',
          isSelected: selectedOrigin == CulturalOrigin.turkish,
          onTap: () => onOriginChanged(CulturalOrigin.turkish),
          icon: Icons.flag,
          color: Colors.red,
        ),
        CategoryFilterChip(
          label: 'Dünya Kültürleri',
          isSelected: selectedOrigin == CulturalOrigin.world,
          onTap: () => onOriginChanged(CulturalOrigin.world),
          icon: Icons.language,
          color: Colors.blue,
        ),
      ],
    );
  }
}

class CategoryFilterChips extends StatelessWidget {
  final TraditionCategory? selectedCategory;
  final Function(TraditionCategory?) onCategoryChanged;

  const CategoryFilterChips({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CategoryFilterChip(
          label: 'Tümü',
          isSelected: selectedCategory == null,
          onTap: () => onCategoryChanged(null),
          icon: Icons.category,
        ),
        ...TraditionCategory.values.map((category) {
          return CategoryFilterChip(
            label: _getCategoryDisplayName(category),
            isSelected: selectedCategory == category,
            onTap: () => onCategoryChanged(category),
            icon: _getCategoryIcon(category),
            color: _getCategoryColor(category),
          );
        }),
      ],
    );
  }

  String _getCategoryDisplayName(TraditionCategory category) {
    switch (category) {
      case TraditionCategory.birthTraditions:
        return 'Doğum';
      case TraditionCategory.namingCeremonies:
        return 'İsim Koyma';
      case TraditionCategory.nutritionTraditions:
        return 'Beslenme';
      case TraditionCategory.educationTeaching:
        return 'Eğitim';
      case TraditionCategory.gamesEntertainment:
        return 'Oyun & Eğlence';
      case TraditionCategory.religiousSpiritual:
        return 'Manevi';
    }
  }

  IconData _getCategoryIcon(TraditionCategory category) {
    switch (category) {
      case TraditionCategory.birthTraditions:
        return Icons.child_care;
      case TraditionCategory.namingCeremonies:
        return Icons.badge;
      case TraditionCategory.nutritionTraditions:
        return Icons.restaurant;
      case TraditionCategory.educationTeaching:
        return Icons.school;
      case TraditionCategory.gamesEntertainment:
        return Icons.toys;
      case TraditionCategory.religiousSpiritual:
        return Icons.mosque;
    }
  }

  Color _getCategoryColor(TraditionCategory category) {
    switch (category) {
      case TraditionCategory.birthTraditions:
        return Colors.pink;
      case TraditionCategory.namingCeremonies:
        return Colors.purple;
      case TraditionCategory.nutritionTraditions:
        return Colors.orange;
      case TraditionCategory.educationTeaching:
        return Colors.blue;
      case TraditionCategory.gamesEntertainment:
        return Colors.green;
      case TraditionCategory.religiousSpiritual:
        return Colors.indigo;
    }
  }
}

class AgeRangeFilterChips extends StatelessWidget {
  final AgeRange? selectedAgeRange;
  final Function(AgeRange?) onAgeRangeChanged;

  const AgeRangeFilterChips({
    super.key,
    this.selectedAgeRange,
    required this.onAgeRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        CategoryFilterChip(
          label: 'Tümü',
          isSelected: selectedAgeRange == null,
          onTap: () => onAgeRangeChanged(null),
          icon: Icons.all_inclusive,
        ),
        ...AgeRange.values.map((ageRange) {
          return CategoryFilterChip(
            label: _getAgeRangeDisplayName(ageRange),
            isSelected: selectedAgeRange == ageRange,
            onTap: () => onAgeRangeChanged(ageRange),
            icon: _getAgeRangeIcon(ageRange),
            color: _getAgeRangeColor(ageRange),
          );
        }),
      ],
    );
  }

  String _getAgeRangeDisplayName(AgeRange ageRange) {
    switch (ageRange) {
      case AgeRange.pregnancy:
        return 'Hamilelik';
      case AgeRange.newborn:
        return 'Yenidoğan';
      case AgeRange.infant:
        return 'Bebek';
      case AgeRange.toddler:
        return 'Küçük Çocuk';
      case AgeRange.preschool:
        return 'Okul Öncesi';
      case AgeRange.allAges:
        return 'Tüm Yaşlar';
    }
  }

  IconData _getAgeRangeIcon(AgeRange ageRange) {
    switch (ageRange) {
      case AgeRange.pregnancy:
        return Icons.pregnant_woman;
      case AgeRange.newborn:
        return Icons.baby_changing_station;
      case AgeRange.infant:
        return Icons.child_care;
      case AgeRange.toddler:
        return Icons.child_friendly;
      case AgeRange.preschool:
        return Icons.school;
      case AgeRange.allAges:
        return Icons.family_restroom;
    }
  }

  Color _getAgeRangeColor(AgeRange ageRange) {
    switch (ageRange) {
      case AgeRange.pregnancy:
        return Colors.purple;
      case AgeRange.newborn:
        return Colors.pink;
      case AgeRange.infant:
        return Colors.blue;
      case AgeRange.toddler:
        return Colors.green;
      case AgeRange.preschool:
        return Colors.orange;
      case AgeRange.allAges:
        return Colors.grey;
    }
  }
}

// Combined filter widget
class CultureFilters extends StatelessWidget {
  final CulturalOrigin? selectedOrigin;
  final TraditionCategory? selectedCategory;
  final AgeRange? selectedAgeRange;
  final Function(CulturalOrigin?) onOriginChanged;
  final Function(TraditionCategory?) onCategoryChanged;
  final Function(AgeRange?) onAgeRangeChanged;
  final VoidCallback? onClearAll;
  final bool showClearButton;

  const CultureFilters({
    super.key,
    this.selectedOrigin,
    this.selectedCategory,
    this.selectedAgeRange,
    required this.onOriginChanged,
    required this.onCategoryChanged,
    required this.onAgeRangeChanged,
    this.onClearAll,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        selectedOrigin != null ||
        selectedCategory != null ||
        selectedAgeRange != null;

    return Container(
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
          // Header
          Row(
            children: [
              Icon(
                Icons.filter_list,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtreler',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                ),
              ),
              const Spacer(),
              if (showClearButton && hasActiveFilters)
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    'Temizle',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Origin filters
          Text(
            'Kültürel Köken',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          OriginFilterChips(
            selectedOrigin: selectedOrigin,
            onOriginChanged: onOriginChanged,
          ),

          const SizedBox(height: 16),

          // Category filters
          Text(
            'Kategori',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          CategoryFilterChips(
            selectedCategory: selectedCategory,
            onCategoryChanged: onCategoryChanged,
          ),

          const SizedBox(height: 16),

          // Age range filters
          Text(
            'Yaş Aralığı',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          AgeRangeFilterChips(
            selectedAgeRange: selectedAgeRange,
            onAgeRangeChanged: onAgeRangeChanged,
          ),
        ],
      ),
    );
  }
}

// Quick filter buttons for top bar
class QuickFilterBar extends StatelessWidget {
  final CulturalOrigin? selectedOrigin;
  final Function(CulturalOrigin?) onOriginChanged;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;

  const QuickFilterBar({
    super.key,
    this.selectedOrigin,
    required this.onOriginChanged,
    this.showFilterButton = true,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryFilterChip(
                  label: 'Tümü',
                  isSelected: selectedOrigin == null,
                  onTap: () => onOriginChanged(null),
                ),
                const SizedBox(width: 8),
                CategoryFilterChip(
                  label: 'Türk',
                  isSelected: selectedOrigin == CulturalOrigin.turkish,
                  onTap: () => onOriginChanged(CulturalOrigin.turkish),
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                CategoryFilterChip(
                  label: 'Dünya',
                  isSelected: selectedOrigin == CulturalOrigin.world,
                  onTap: () => onOriginChanged(CulturalOrigin.world),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          if (showFilterButton) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: onFilterTap,
                icon: const Icon(Icons.tune),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
