import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/progress_stepper.dart';
import 'mother_registration_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.baby_changing_station_rounded,
      title: 'Anne-Bebek Rehberi\'ne\nHoş Geldiniz',
      subtitle:
          'Bebeğinizin gelişimini takip edin, uzman önerileri alın ve bu özel yolculukta yanınızda olalım.',
      color: const Color(0xFF6B4EFF),
    ),
    OnboardingPage(
      icon: Icons.timeline_rounded,
      title: 'Gelişimi Takip Edin',
      subtitle:
          'Bebeğinizin fiziksel ve zihinsel gelişimini hafta hafta, ay ay takip edin. Kilo, boy, baş çevresi ölçümlerini kaydedin.',
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      icon: Icons.lightbulb_rounded,
      title: 'Kişisel Öneriler',
      subtitle:
          'Bebeğinizin yaşına ve gelişim aşamasına özel kitap, müzik, oyun ve aktivite önerileri alın.',
      color: const Color(0xFFF59E0B),
    ),
    OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Astroloji Desteği',
      subtitle:
          'İsteğe bağlı astroloji özelliği ile bebeğinizin burç özelliklerini keşfedin ve buna uygun öneriler alın.',
      color: const Color(0xFFEF4444),
    ),
    OnboardingPage(
      icon: Icons.health_and_safety_rounded,
      title: 'Sağlık Takibi',
      subtitle:
          'Aşı takvimi, büyüme eğrileri, beslenme ve uyku takibi ile bebeğinizin sağlığını koruyun.',
      color: const Color(0xFF8B5FFF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRegistration();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _navigateToRegistration() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MotherRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
        transitionDuration: AppConstants.mediumAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo or app name
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B4EFF),
                      ),
                    ),

                    // Skip button
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Atla',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ProgressDots(
                  totalDots: _pages.length,
                  activeDot: _currentPage,
                ),
              ),

              const SizedBox(height: 40),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const Spacer(),

                          // Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [page.color, page.color.withAlpha(204)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: page.color.withAlpha(77),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Title
                          Text(
                            page.title,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1B23),
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Subtitle
                          Text(
                            page.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF6B7280),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Back button
                    if (_currentPage > 0)
                      CustomButton.outline(
                        text: 'Geri',
                        onPressed: _previousPage,
                        icon: Icons.arrow_back_rounded,
                        size: ButtonSize.medium,
                      )
                    else
                      const SizedBox(width: 100),

                    const Spacer(),

                    // Next/Start button
                    CustomButton.primary(
                      text: _currentPage == _pages.length - 1
                          ? 'Başlayalım'
                          : 'İleri',
                      onPressed: _nextPage,
                      icon: _currentPage == _pages.length - 1
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      iconRight: true,
                      size: ButtonSize.medium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Onboarding page model
class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

// Interactive onboarding with features showcase
class InteractiveOnboardingScreen extends StatefulWidget {
  const InteractiveOnboardingScreen({super.key});

  @override
  State<InteractiveOnboardingScreen> createState() =>
      _InteractiveOnboardingScreenState();
}

class _InteractiveOnboardingScreenState
    extends State<InteractiveOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.longAnimation,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutBack,
          ),
        );

    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B4EFF),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              const Spacer(),

              // Animated logo
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.baby_changing_station_rounded,
                        size: 80,
                        color: Color(0xFF6B4EFF),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                AppConstants.appName,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Bebeğinizle birlikte büyüyoruz',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white.withAlpha(230),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Feature highlights
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      Icons.timeline_rounded,
                      'Gelişim Takibi',
                      'Haftalık ve aylık gelişim raporları',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      Icons.lightbulb_rounded,
                      'Akıllı Öneriler',
                      'Yaşa özel kitap, müzik ve oyun önerileri',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      Icons.health_and_safety_rounded,
                      'Sağlık Takibi',
                      'Aşı takvimi ve büyüme eğrileri',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Start button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: CustomButton(
                  text: 'Hemen Başla',
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MotherRegistrationScreen(),
                    ),
                  ),
                  type: ButtonType.primary,
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6B4EFF),
                  fullWidth: true,
                  icon: Icons.arrow_forward_rounded,
                  iconRight: true,
                ),
              ),

              const SizedBox(height: 32),
            ],
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
            color: Colors.white.withAlpha(51),
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
                  color: Colors.white.withAlpha(204),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
