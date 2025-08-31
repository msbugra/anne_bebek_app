import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selected = 'tr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dil',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLangTile('Türkçe', 'tr'),
          const SizedBox(height: 8),
          _buildLangTile('İngilizce', 'en'),
        ],
      ),
    );
  }

  Widget _buildLangTile(String label, String code) {
    final selected = _selected == code;
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).cardColor,
      title: Text(
        label,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        setState(() => _selected = code);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Dil değiştirildi: $label')));
      },
    );
  }
}
