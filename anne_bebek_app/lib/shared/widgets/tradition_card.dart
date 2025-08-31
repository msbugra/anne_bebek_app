import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/cultural_tradition_model.dart';
import '../providers/culture_provider.dart';
import '../../features/culture/tradition_detail_screen.dart';

class TraditionCard extends StatelessWidget {
  final CulturalTraditionModel tradition;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool showOriginTag;
  final bool compact;

  const TraditionCard({
    super.key,
    required this.tradition,
    this.onTap,
    this.showFavoriteButton = true,
    this.showOriginTag = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: compact ? 8.0 : 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and favorite button
              _buildHeader(context),

              SizedBox(height: compact ? 8 : 12),

              // Description
              _buildDescription(context),

              if (!compact) ...[
                const SizedBox(height: 12),

                // Tags row
                _buildTagsRow(context),

                const SizedBox(height: 8),

                // Action buttons
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getOriginColor().withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: _getOriginColor(),
            size: compact ? 20 : 24,
          ),
        ),

        const SizedBox(width: 12),

        // Title and origin tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tradition.title,
                style: GoogleFonts.inter(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                  height: 1.3,
                ),
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),

              if (showOriginTag) ...[
                const SizedBox(height: 4),
                _buildOriginTag(),
              ],
            ],
          ),
        ),

        // Favorite button
        if (showFavoriteButton) _buildFavoriteButton(context),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      tradition.description,
      style: GoogleFonts.inter(
        fontSize: compact ? 12 : 13,
        height: 1.4,
        color: const Color(0xFF6B7280),
      ),
      maxLines: compact ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildOriginTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getOriginColor().withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getOriginColor().withAlpha((255 * 0.3).round()),
          width: 1,
        ),
      ),
      child: Text(
        tradition.originDisplayName,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getOriginColor(),
        ),
      ),
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildTag(tradition.categoryDisplayName, Colors.blue),
        _buildTag(tradition.ageRangeDisplayName, Colors.purple),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Read more button
        TextButton.icon(
          onPressed: () => _navigateToDetail(context),
          icon: const Icon(Icons.read_more, size: 16),
          label: Text(
            'Devamını Oku',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),

        const Spacer(),

        // Share button
        IconButton(
          onPressed: () => _shareTraditon(context),
          icon: const Icon(Icons.share, size: 18),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Consumer<CultureProvider>(
      builder: (context, cultureProvider, child) {
        final isFavorite = cultureProvider.isFavorite(tradition);

        return IconButton(
          onPressed: () {
            cultureProvider.toggleFavorite(tradition);
            _showFavoriteSnackBar(context, !isFavorite);
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : const Color(0xFF6B7280),
            size: compact ? 20 : 24,
          ),
          style: IconButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.all(8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      },
    );
  }

  Color _getOriginColor() {
    switch (tradition.origin) {
      case CulturalOrigin.turkish:
        return Colors.red;
      case CulturalOrigin.world:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    switch (tradition.category) {
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

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TraditionDetailScreen(tradition: tradition),
      ),
    );
  }

  void _shareTraditon(BuildContext context) {
    final title = tradition.title;
    final desc = tradition.description;
    final origin = tradition.originDisplayName;
    final category = tradition.categoryDisplayName;
    final age = tradition.ageRangeDisplayName;

    final text = StringBuffer()
      ..writeln('“$title”')
      ..writeln(desc)
      ..writeln()
      ..writeln('#$origin #$category #$age')
      ..writeln('Anne-Bebek Rehberi');

    SharePlus.instance.share(
      ShareParams(text: text.toString(), subject: title),
    );
  }

  void _showFavoriteSnackBar(BuildContext context, bool added) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              added ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              added
                  ? '${tradition.title} favorilere eklendi'
                  : '${tradition.title} favorilerden çıkarıldı',
            ),
          ],
        ),
        backgroundColor: added ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: Colors.white,
          onPressed: () {
            Provider.of<CultureProvider>(
              context,
              listen: false,
            ).toggleFavorite(tradition);
          },
        ),
      ),
    );
  }
}

// Compact tradition card for lists
class CompactTraditionCard extends StatelessWidget {
  final CulturalTraditionModel tradition;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const CompactTraditionCard({
    super.key,
    required this.tradition,
    this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return TraditionCard(
      tradition: tradition,
      onTap: onTap,
      showFavoriteButton: showFavoriteButton,
      showOriginTag: false,
      compact: true,
    );
  }
}

// Tradition card for grid view
class GridTraditionCard extends StatelessWidget {
  final CulturalTraditionModel tradition;
  final VoidCallback? onTap;

  const GridTraditionCard({super.key, required this.tradition, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and favorite
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _getOriginColor().withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      color: _getOriginColor(),
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  Consumer<CultureProvider>(
                    builder: (context, cultureProvider, child) {
                      final isFavorite = cultureProvider.isFavorite(tradition);

                      return GestureDetector(
                        onTap: () => cultureProvider.toggleFavorite(tradition),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? Colors.red
                              : const Color(0xFF6B7280),
                          size: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                tradition.title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description
              Expanded(
                child: Text(
                  tradition.description,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    height: 1.3,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Origin tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getOriginColor().withAlpha((255 * 0.1).round()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getOriginColor().withAlpha((255 * 0.3).round()),
                    width: 1,
                  ),
                ),
                child: Text(
                  tradition.originDisplayName,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: _getOriginColor(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOriginColor() {
    switch (tradition.origin) {
      case CulturalOrigin.turkish:
        return Colors.red;
      case CulturalOrigin.world:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon() {
    switch (tradition.category) {
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

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TraditionDetailScreen(tradition: tradition),
      ),
    );
  }
}
