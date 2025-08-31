import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/settings_tile.dart';
import 'edit_mother_profile_screen.dart';
import 'edit_baby_profile_screen.dart';
import 'theme_settings_screen.dart';
import 'data_management_screen.dart';
import 'notifications_settings_screen.dart';
import 'language_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Consumer2<BabyProvider, ThemeProvider>(
        builder: (context, babyProvider, themeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kullanıcı Profili Bölümü
                _buildProfileSection(context, babyProvider),

                const SizedBox(height: 24),

                // Uygulama Ayarları
                _buildAppSettingsSection(context, themeProvider),

                const SizedBox(height: 24),

                // Veri Yönetimi
                _buildDataManagementSection(context),

                const SizedBox(height: 24),

                // Hakkında
                _buildAboutSection(context),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, BabyProvider babyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kullanıcı Profili',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Anne Profili
        if (babyProvider.currentMother != null)
          SettingsTile(
            title: 'Anne Profili',
            subtitle: babyProvider.currentMother!.name,
            icon: Icons.person_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditMotherProfileScreen(),
                ),
              );
            },
          ),

        const SizedBox(height: 8),

        // Bebek Profili
        if (babyProvider.currentBaby != null)
          SettingsTile(
            title: 'Bebek Profili',
            subtitle: babyProvider.currentBaby!.name,
            icon: Icons.baby_changing_station_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditBabyProfileScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAppSettingsSection(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uygulama Ayarları',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Tema Ayarları
        SettingsTile(
          title: 'Görünüm ve Tema',
          subtitle: _getThemeModeText(themeProvider.themeMode),
          icon: Icons.palette_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ThemeSettingsScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Bildirimler
        SettingsTile(
          title: 'Bildirimler',
          subtitle: 'Bildirim tercihlerini yönet',
          icon: Icons.notifications_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsSettingsScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Dil Seçenekleri
        SettingsTile(
          title: 'Dil',
          subtitle: 'Türkçe',
          icon: Icons.language_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LanguageSettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Veri Yönetimi',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Veri Yönetimi
        SettingsTile(
          title: 'Veri Yönetimi',
          subtitle: 'Yedekleme, dışa aktarma, sıfırlama',
          icon: Icons.storage_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DataManagementScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Gizlilik ve Güvenlik
        SettingsTile(
          title: 'Gizlilik ve Güvenlik',
          subtitle: 'Veri paylaşım tercihleri',
          icon: Icons.security_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacySettingsScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hakkında',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Uygulama Bilgileri
        SettingsTile(
          title: 'Uygulama Hakkında',
          subtitle: 'Sürüm 1.0.0',
          icon: Icons.info_rounded,
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Anne-Bebek Uygulaması',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2024 Tüm hakları saklıdır.',
            );
          },
        ),

        const SizedBox(height: 8),

        // Destek
        SettingsTile(
          title: 'Destek ve Yardım',
          subtitle: 'Yardım ve geri bildirim',
          icon: Icons.help_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportScreen()),
            );
          },
        ),
      ],
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Aydınlık';
      case ThemeMode.dark:
        return 'Karanlık';
      case ThemeMode.system:
        return 'Sistem';
    }
  }
}
