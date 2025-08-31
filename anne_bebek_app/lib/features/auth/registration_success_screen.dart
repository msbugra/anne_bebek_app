import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/providers/baby_provider.dart';
import '../../main.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _confettiAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti animation
    _confettiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _confettiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _confettiAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Fade animation
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    // Scale animation
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _scaleAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _confettiAnimationController.forward();
  }

  @override
  void dispose() {
    _confettiAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppInitializer(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppConstants.mediumAnimation,
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B4EFF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const Spacer(),

              // Confetti animation area
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    // Main success icon
                    Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            size: 60,
                            color: Color(0xFF6B4EFF),
                          ),
                        ),
                      ),
                    ),

                    // Animated confetti particles
                    AnimatedBuilder(
                      animation: _confettiAnimation,
                      builder: (context, child) {
                        return Stack(
                          children: List.generate(20, (index) {
                            return _buildConfettiParticle(index);
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Success message
              ScaleTransition(
                scale: _scaleAnimation,
                child: Text(
                  'Tebrikler!',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              FadeTransition(
                opacity: _fadeAnimation,
                child: Consumer<BabyProvider>(
                  builder: (context, babyProvider, child) {
                    String motherName =
                        babyProvider.currentMother?.name ?? 'Anne';
                    String babyName = babyProvider.currentBaby?.name ?? 'Bebek';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        '$motherName, $babyName için yolculuğunuz başladı!\n'
                        'Artık kişisel öneriler ve gelişim takibi alabilirsiniz.',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // Features preview
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      Text(
                        'Sizi Neler Bekliyor?',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildFeatureItem(
                        Icons.timeline_rounded,
                        'Haftalık Gelişim Takibi',
                        'Bebeğinizin her aşamasını izleyin',
                      ),
                      const SizedBox(height: 16),

                      _buildFeatureItem(
                        Icons.lightbulb_rounded,
                        'Kişiselleştirilmiş Öneriler',
                        'Yaşa ve ihtiyaca özel içerikler',
                      ),
                      const SizedBox(height: 16),

                      _buildFeatureItem(
                        Icons.health_and_safety_rounded,
                        'Sağlık ve Aşı Takibi',
                        'Önemli tarihleri kaçırmayın',
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Ana Sayfaya Git',
                        onPressed: _navigateToHome,
                        type: ButtonType.primary,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6B4EFF),
                        fullWidth: true,
                        icon: Icons.home_rounded,
                        iconRight: true,
                        size: ButtonSize.large,
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        text: 'Profili İncele',
                        onPressed: () {
                          // TODO: Profile screen'e git
                          _navigateToHome();
                        },
                        type: ButtonType.text,
                        foregroundColor: Colors.white.withOpacity(0.8),
                        fullWidth: true,
                        icon: Icons.person_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiParticle(int index) {
    final colors = [
      Colors.yellow,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
    ];

    final random = (index * 123456) % 100000;
    final startX = (random % 300).toDouble() + 50;
    final endY = (random % 400).toDouble() + 100;
    final color = colors[index % colors.length];
    final size = ((random % 8) + 4).toDouble();

    return Positioned(
      left: startX,
      top: 50 + (endY * _confettiAnimation.value),
      child: Opacity(
        opacity: 1.0 - _confettiAnimation.value,
        child: Transform.rotate(
          angle: _confettiAnimation.value * 4,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Alternatif minimalist success screen
class MinimalSuccessScreen extends StatefulWidget {
  const MinimalSuccessScreen({super.key});

  @override
  State<MinimalSuccessScreen> createState() => _MinimalSuccessScreenState();
}

class _MinimalSuccessScreenState extends State<MinimalSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _checkAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark
              ScaleTransition(
                scale: _checkAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Success text
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Kayıt Tamamlandı!',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1B23),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Profiliniz başarıyla oluşturuldu.\n'
                      'Artık kişiselleştirilmiş öneriler alabilirsiniz.',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Continue button
              FadeTransition(
                opacity: _fadeAnimation,
                child: CustomButton.primary(
                  text: 'Devam Et',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const AppInitializer(),
                    ),
                    (route) => false,
                  ),
                  icon: Icons.arrow_forward_rounded,
                  iconRight: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
