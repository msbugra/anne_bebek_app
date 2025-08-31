import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Destek ve Yardım',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(
              'Bize Ulaşın',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('destek@annebebek.app'),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Theme.of(context).cardColor,
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(
              'SSS',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Sıkça sorulan sorular'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
