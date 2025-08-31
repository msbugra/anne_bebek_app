import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import 'onboarding_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final bool showOnboarding;

  const WelcomeScreen({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    if (showOnboarding) {
      // Gerçek onboarding ekranını göster
      return const OnboardingScreen();
    } else {
      return const MainScreen();
    }
  }
}

// Ana ekran (profil varsa)
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_rounded,
                size: 80,
                color: Color(0xFF6B4EFF),
              ),

              const SizedBox(height: 24),

              Text(
                'Ana Ekran',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1B23),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Ana dashboard burada olacak.\nÖneriler, sağlık takibi, profil bilgileri...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  _showComingSoonDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Önerileri Görüntüle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Geliştirme aşamasında dialog
void _showComingSoonDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: Text(
        'Geliştirme Aşamasında',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'Bu özellik şu anda geliştirme aşamasındadır. '
        'En kısa sürede kullanıma sunulacaktır.',
        style: GoogleFonts.inter(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}
