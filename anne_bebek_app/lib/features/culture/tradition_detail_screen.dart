import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/models/cultural_tradition_model.dart';
import '../../shared/providers/culture_provider.dart';
import '../../shared/widgets/tradition_card.dart';

class TraditionDetailScreen extends StatefulWidget {
  final CulturalTraditionModel tradition;

  const TraditionDetailScreen({super.key, required this.tradition});

  @override
  State<TraditionDetailScreen> createState() => _TraditionDetailScreenState();
}

class _TraditionDetailScreenState extends State<TraditionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          _buildSliverAppBar(context),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Tags Section
                _buildTitleSection(context),

                const SizedBox(height: 24),

                // Description Section
                _buildDescriptionSection(context),

                const SizedBox(height: 24),

                // History Section
                if (widget.tradition.history != null)
                  _buildHistorySection(context),

                const SizedBox(height: 24),

                // How to Apply Section
                if (widget.tradition.howToApply != null)
                  _buildHowToApplySection(context),

                const SizedBox(height: 24),

                // Importance Section
                _buildImportanceSection(context),

                const SizedBox(height: 24),

                // Age Information Section
                _buildAgeInfoSection(context),

                const SizedBox(height: 24),

                // Related Traditions Section
                _buildRelatedTraditionsSection(context),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ],
      ),
      // Floating Action Buttons
      floatingActionButton: _buildFloatingActions(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: _getOriginColor(),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.tradition.title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: const Offset(0, 1),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_getOriginColor(), _getOriginColor().withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getCategoryIcon(),
                        size: 100,
                        color: Colors.white.withOpacity(0.2),
                      );
                    },
                  ),
                ),
              ),
              // Center icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<CultureProvider>(
          builder: (context, cultureProvider, child) {
            final isFavorite = cultureProvider.isFavorite(widget.tradition);

            return IconButton(
              onPressed: () {
                cultureProvider.toggleFavorite(widget.tradition);
                _showFavoriteSnackBar(!isFavorite);
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
            );
          },
        ),
        IconButton(
          onPressed: _shareTraditon,
          icon: const Icon(Icons.share, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin and Category Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(
                widget.tradition.originDisplayName,
                _getOriginColor(),
                Icons.flag,
              ),
              _buildTag(
                widget.tradition.categoryDisplayName,
                _getCategoryColor(),
                _getCategoryIcon(),
              ),
              _buildTag(
                widget.tradition.ageRangeDisplayName,
                Colors.purple,
                _getAgeRangeIcon(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return _buildSection(
      title: 'Açıklama',
      icon: Icons.description,
      color: Colors.blue,
      child: Text(
        widget.tradition.description,
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return _buildSection(
      title: 'Tarihçe ve Köken',
      icon: Icons.history,
      color: Colors.orange,
      child: Text(
        widget.tradition.history!,
        style: GoogleFonts.inter(
          fontSize: 15,
          height: 1.6,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildHowToApplySection(BuildContext context) {
    return _buildSection(
      title: 'Nasıl Uygulanır?',
      icon: Icons.checklist,
      color: Colors.green,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
        ),
        child: Text(
          widget.tradition.howToApply!,
          style: GoogleFonts.inter(
            fontSize: 15,
            height: 1.6,
            color: const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildImportanceSection(BuildContext context) {
    return _buildSection(
      title: 'Önemi ve Faydaları',
      icon: Icons.star,
      color: Colors.amber,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.tradition.importance,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.6,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeInfoSection(BuildContext context) {
    return _buildSection(
      title: 'Yaş Bilgisi',
      icon: _getAgeRangeIcon(),
      color: Colors.purple,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_getAgeRangeIcon(), color: Colors.purple, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uygun Yaş Aralığı',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.tradition.ageRangeDisplayName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedTraditionsSection(BuildContext context) {
    return Consumer<CultureProvider>(
      builder: (context, cultureProvider, child) {
        final relatedTraditions = cultureProvider.getRelatedTraditions(
          widget.tradition,
          limit: 3,
        );

        if (relatedTraditions.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSection(
          title: 'İlgili Gelenekler',
          icon: Icons.connect_without_contact,
          color: Colors.indigo,
          child: Column(
            children: relatedTraditions.map((tradition) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CompactTraditionCard(
                  tradition: tradition,
                  showFavoriteButton: false,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share button
        FloatingActionButton.small(
          onPressed: _shareTraditon,
          backgroundColor: Colors.grey[100],
          foregroundColor: Colors.grey[700],
          child: const Icon(Icons.share),
        ),

        const SizedBox(height: 8),

        // Favorite button
        Consumer<CultureProvider>(
          builder: (context, cultureProvider, child) {
            final isFavorite = cultureProvider.isFavorite(widget.tradition);

            return FloatingActionButton.small(
              onPressed: () {
                cultureProvider.toggleFavorite(widget.tradition);
                _showFavoriteSnackBar(!isFavorite);
              },
              backgroundColor: isFavorite ? Colors.red : Colors.grey[100],
              foregroundColor: isFavorite ? Colors.white : Colors.grey[700],
              child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            );
          },
        ),
      ],
    );
  }

  Color _getOriginColor() {
    switch (widget.tradition.origin) {
      case CulturalOrigin.turkish:
        return Colors.red;
      case CulturalOrigin.world:
        return Colors.blue;
    }
  }

  Color _getCategoryColor() {
    switch (widget.tradition.category) {
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

  IconData _getCategoryIcon() {
    switch (widget.tradition.category) {
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

  IconData _getAgeRangeIcon() {
    switch (widget.tradition.ageRange) {
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

  void _shareTraditon() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.tradition.title} paylaşım özelliği yakında eklenecek',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showFavoriteSnackBar(bool added) {
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
            Expanded(
              child: Text(
                added
                    ? '${widget.tradition.title} favorilere eklendi'
                    : '${widget.tradition.title} favorilerden çıkarıldı',
              ),
            ),
          ],
        ),
        backgroundColor: added ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Geri Al',
          textColor: Colors.white,
          onPressed: () {
            Provider.of<CultureProvider>(
              context,
              listen: false,
            ).toggleFavorite(widget.tradition);
          },
        ),
      ),
    );
  }
}
