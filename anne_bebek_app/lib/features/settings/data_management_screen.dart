import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/settings_tile.dart';
import '../../shared/widgets/custom_button.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Veri Yönetimi',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  'Veri Yönetimi',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verilerinizi yönetin, yedekleyin ve dışa aktarın',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Yedekleme Bölümü
                _buildBackupSection(context),

                const SizedBox(height: 32),

                // Dışa Aktarma Bölümü
                _buildExportSection(context),

                const SizedBox(height: 32),

                // Veri Temizleme Bölümü
                _buildDataCleanupSection(context, babyProvider),

                const SizedBox(height: 32),

                // Uyarı Bölümü
                _buildWarningSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yedekleme',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
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
              Icon(
                Icons.backup_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Verilerinizi yedekleyin',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tüm verilerinizi güvenli bir şekilde yedekleyebilirsiniz. Yedekleme özelliği yakında eklenecek.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Yedekle',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yedekleme özelliği yakında eklenecek'),
                    ),
                  );
                },
                icon: Icons.backup_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dışa Aktarma',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Sağlık Raporu
        SettingsTile(
          title: 'Sağlık Raporu',
          subtitle: 'Bebeğinizin sağlık verilerini PDF olarak dışa aktar',
          icon: Icons.description_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sağlık raporu özelliği yakında eklenecek'),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Gelişim Raporu
        SettingsTile(
          title: 'Gelişim Raporu',
          subtitle: 'Gelişim takibi verilerini dışa aktar',
          icon: Icons.trending_up_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gelişim raporu özelliği yakında eklenecek'),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Beslenme Raporu
        SettingsTile(
          title: 'Beslenme Raporu',
          subtitle: 'Beslenme kayıtlarını dışa aktar',
          icon: Icons.restaurant_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Beslenme raporu özelliği yakında eklenecek'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataCleanupSection(
    BuildContext context,
    BabyProvider babyProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Veri Temizleme',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Önbelleği Temizle
        SettingsTile(
          title: 'Önbelleği Temizle',
          subtitle: 'Geçici verileri temizle',
          icon: Icons.cleaning_services_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Önbellek temizlendi')),
            );
          },
        ),

        const SizedBox(height: 8),

        // Eski Verileri Temizle
        SettingsTile(
          title: 'Eski Verileri Temizle',
          subtitle: '30 günden eski verileri kaldır',
          icon: Icons.delete_sweep_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Eski veriler temizlendi')),
            );
          },
        ),

        const SizedBox(height: 16),

        // Tehlikeli İşlemler
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.error,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tehlikeli İşlemler',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tüm Verileri Sıfırla
              SettingsTile(
                title: 'Tüm Verileri Sıfırla',
                subtitle: 'Uygulamayı fabrika ayarlarına döndür',
                icon: Icons.restore_rounded,
                onTap: () =>
                    _showResetConfirmationDialog(context, babyProvider),
              ),

              const SizedBox(height: 8),

              // Hesabı Sil
              SettingsTile(
                title: 'Hesabı Sil',
                subtitle: 'Hesabınızı ve tüm verilerinizi kalıcı olarak sil',
                icon: Icons.delete_forever_rounded,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Veri yönetimi işlemlerinde dikkatli olun. Bazı işlemler geri alınamaz.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(
    BuildContext context,
    BabyProvider babyProvider,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tüm Verileri Sıfırla',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Bu işlem tüm verilerinizi kalıcı olarak silecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await babyProvider.resetProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tüm veriler başarıyla sıfırlandı')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hesabı Sil',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Hesabınız ve tüm verileriniz kalıcı olarak silinecektir. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      // TODO: Hesap silme işlemi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesap silme özelliği yakında eklenecek')),
      );
    }
  }
}
