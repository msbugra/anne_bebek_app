import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _general = true;
  bool _reminders = true;
  bool _tips = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bildirimler',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSwitch(
            title: 'Genel Bildirimler',
            subtitle: 'Uygulama içi genel bildirimleri al',
            value: _general,
            onChanged: (v) => setState(() => _general = v),
          ),
          const SizedBox(height: 8),
          _buildSwitch(
            title: 'Hatırlatıcılar',
            subtitle: 'Aşı, beslenme ve uyku hatırlatıcıları',
            value: _reminders,
            onChanged: (v) => setState(() => _reminders = v),
          ),
          const SizedBox(height: 8),
          _buildSwitch(
            title: 'İpuçları ve Öneriler',
            subtitle: 'Günlük öneriler ve ipuçları',
            value: _tips,
            onChanged: (v) => setState(() => _tips = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
