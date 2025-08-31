import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/zodiac_calculator.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_dropdown.dart';
import '../../shared/widgets/custom_switch.dart';
import '../../shared/widgets/date_time_picker_widget.dart';
import '../../shared/widgets/progress_stepper.dart';
import '../../shared/providers/baby_provider.dart';
import 'baby_registration_screen.dart';

class MotherRegistrationScreen extends StatefulWidget {
  const MotherRegistrationScreen({super.key});

  @override
  State<MotherRegistrationScreen> createState() =>
      _MotherRegistrationScreenState();
}

class _MotherRegistrationScreenState extends State<MotherRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _birthCity;
  bool _astrologyEnabled = false;
  String? _zodiacSign;

  int _currentStep = 0;
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Kişisel Bilgiler',
    'Doğum Bilgileri',
    'Tercihler',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimation,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.nextPage(
          duration: AppConstants.mediumAnimation,
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return true; // Doğum bilgileri opsiyonel
      case 2:
        return true; // Tercihler opsiyonel
      default:
        return false;
    }
  }

  Future<void> _submitForm() async {
    if (!_validateCurrentStep()) return;

    setState(() => _isLoading = true);

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);

      // Burç hesaplama
      String? calculatedZodiac;
      if (_astrologyEnabled && _birthDate != null) {
        final zodiacSign = ZodiacCalculator.calculateZodiacSign(_birthDate!);
        calculatedZodiac = ZodiacCalculator.getZodiacName(zodiacSign);
      }

      final success = await babyProvider.saveMotherProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDate,
        birthCity: _birthCity,
        astrologyEnabled: _astrologyEnabled,
        zodiacSign: calculatedZodiac,
      );

      if (success && mounted) {
        debugPrint(
          '🔍 [DEBUG] Mother registration successful, navigating to baby screen',
        );
        // Bebek kayıt ekranına geç
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const BabyRegistrationScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    child: child,
                  );
                },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
        debugPrint('🔍 [DEBUG] Navigation to baby screen completed');
      } else {
        debugPrint('🔍 [DEBUG] Mother registration failed or not mounted');
        // Provider'dan detaylı hata mesajını al
        final errorMessage =
            babyProvider.errorMessage ??
            'Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin.';
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      _showErrorDialog('Beklenmeyen bir hata oluştu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        title: Text(
          'Hata',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          CustomButton.text(
            text: 'Tamam',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Anne Bilgileri',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1B23),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back_rounded),
              )
            : IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
      ),
      body: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: Column(
            children: [
              // Progress stepper
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: ProgressStepper(
                  totalSteps: 3,
                  currentStep: _currentStep,
                  stepTitles: _stepTitles,
                ),
              ),

              // Form content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPersonalInfoStep(),
                    _buildBirthInfoStep(),
                    _buildPreferencesStep(),
                  ],
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Kişisel Bilgileriniz',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Size nasıl hitap edelim? İsminizi giriniz.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 32),

            // Name field
            CustomTextField(
              label: 'Adınız',
              hint: 'Adınızı giriniz',
              controller: _nameController,
              prefixIcon: Icons.person_rounded,
              validator: FormValidators.validateName,
              inputFormatters: [TurkishNameFormatter()],
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 24),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EFF).withAlpha(26),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: const Color(0xFF6B4EFF).withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: const Color(0xFF6B4EFF),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu bilgiler sadece size özel öneriler sunmak için kullanılacak.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B4EFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Doğum Bilgileriniz',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu bilgiler opsiyoneldir. Daha kişisel öneriler için paylaşabilirsiniz.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 32),

          // Birth date
          DateTimePickerWidget(
            label: 'Doğum Tarihiniz',
            hint: 'Doğum tarihinizi seçiniz',
            selectedDate: _birthDate,
            onDateChanged: (date) => setState(() => _birthDate = date),
            lastDate: DateTime.now(),
            firstDate: DateTime(1950),
          ),

          const SizedBox(height: 24),

          // Birth city
          CityDropdown(
            label: 'Doğum Yeriniz',
            selectedCity: _birthCity,
            onChanged: (city) => setState(() => _birthCity = city),
          ),

          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(26),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: const Color(0xFF10B981).withAlpha(77)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_rounded,
                  color: const Color(0xFF10B981),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tüm bilgileriniz gizli tutulur ve üçüncü şahıslarla paylaşılmaz.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Tercihleriniz',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hangi özelliklerden yararlanmak istiyorsunuz?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 32),

          // Astrology preference
          CustomSwitch(
            value: _astrologyEnabled,
            onChanged: (value) {
              setState(() {
                _astrologyEnabled = value;
                if (value && _birthDate != null) {
                  final zodiacSign = ZodiacCalculator.calculateZodiacSign(
                    _birthDate!,
                  );
                  _zodiacSign = ZodiacCalculator.getZodiacName(zodiacSign);
                } else {
                  _zodiacSign = null;
                }
              });
            },
            title: 'Astroloji Desteği',
            subtitle: 'Burç özelliklerine göre özel öneriler alın',
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
          ),

          // Zodiac display
          if (_astrologyEnabled && _zodiacSign != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(26),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: const Color(0xFFEF4444).withAlpha(77),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFEF4444),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Burcunuz: $_zodiacSign',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size özel astrolojik öneriler hazırlanacak',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Features preview
          Text(
            'Sizin İçin Hazırladıklarımız',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 16),

          _buildFeatureItem(
            Icons.timeline_rounded,
            'Gelişim Takibi',
            'Bebeğinizin gelişimini haftalık takip edin',
            const Color(0xFF6B4EFF),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.lightbulb_rounded,
            'Akıllı Öneriler',
            'Yaşa uygun kitap, müzik ve oyun önerileri',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            Icons.health_and_safety_rounded,
            'Sağlık Takibi',
            'Aşı takvimi ve büyüme eğrileri',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: CustomButton.outline(
                  text: 'Geri',
                  onPressed: _previousStep,
                  icon: Icons.arrow_back_rounded,
                ),
              )
            else
              const SizedBox.shrink(),

            if (_currentStep > 0) const SizedBox(width: 16),

            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: CustomButton.primary(
                text: _currentStep == 2 ? 'Anne Kaydını Tamamla' : 'İleri',
                onPressed: _nextStep,
                loading: _isLoading,
                icon: _currentStep == 2
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                iconRight: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
