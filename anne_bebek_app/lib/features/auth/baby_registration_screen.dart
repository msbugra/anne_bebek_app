import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/zodiac_calculator.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_dropdown.dart';
import '../../shared/widgets/date_time_picker_widget.dart';
import '../../shared/widgets/progress_stepper.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/baby_model.dart';
import 'registration_success_screen.dart';

class BabyRegistrationScreen extends StatefulWidget {
  const BabyRegistrationScreen({super.key});

  @override
  State<BabyRegistrationScreen> createState() => _BabyRegistrationScreenState();
}

class _BabyRegistrationScreenState extends State<BabyRegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _headCircumferenceController =
      TextEditingController();

  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _birthCity;
  String? _gender;
  String? _zodiacSign;

  int _currentStep = 0;
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Temel Bilgiler',
    'Doğum Detayları',
    'Fiziksel Ölçümler',
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
    _weightController.dispose();
    _heightController.dispose();
    _headCircumferenceController.dispose();
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
        return _nameController.text.trim().isNotEmpty && _birthDate != null;
      case 1:
        return true; // Detaylar opsiyonel
      case 2:
        return _weightController.text.trim().isNotEmpty &&
            _heightController.text.trim().isNotEmpty;
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
      if (_birthDate != null) {
        final zodiacSign = ZodiacCalculator.calculateZodiacSign(_birthDate!);
        calculatedZodiac = ZodiacCalculator.getZodiacName(zodiacSign);
      }

      // Birth time string oluştur
      String? birthTimeString;
      if (_birthTime != null) {
        birthTimeString =
            '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}';
      }

      // Gender enum'a çevir
      BabyGender? babyGender;
      if (_gender != null) {
        babyGender = _gender == 'male' ? BabyGender.male : BabyGender.female;
      }

      final success = await babyProvider.saveBabyProfile(
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        birthTime: birthTimeString,
        birthWeight: double.tryParse(
          _weightController.text.replaceAll(',', '.'),
        ),
        birthHeight: double.tryParse(
          _heightController.text.replaceAll(',', '.'),
        ),
        birthHeadCircumference: _headCircumferenceController.text.isNotEmpty
            ? double.tryParse(
                _headCircumferenceController.text.replaceAll(',', '.'),
              )
            : null,
        birthCity: _birthCity,
        gender: babyGender,
        zodiacSign: calculatedZodiac,
      );

      if (success && mounted) {
        // Başarı ekranına geç
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RegistrationSuccessScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: AppConstants.mediumAnimation,
          ),
        );
      } else {
        _showErrorDialog(
          'Kayıt sırasında bir hata oluştu. Lütfen tekrar deneyin.',
        );
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
          'Bebek Bilgileri',
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
                    _buildBasicInfoStep(),
                    _buildBirthDetailsStep(),
                    _buildMeasurementsStep(),
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

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Bebeğinizin Temel Bilgileri',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bebeğinizin ismini ve doğum tarihini giriniz.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 32),

            // Baby name field
            CustomTextField(
              label: 'Bebeğinizin Adı',
              hint: 'Bebek adını giriniz',
              controller: _nameController,
              prefixIcon: Icons.child_care_rounded,
              validator: FormValidators.validateName,
              inputFormatters: [TurkishNameFormatter()],
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 24),

            // Birth date
            DateTimePickerWidget(
              label: 'Doğum Tarihi',
              hint: 'Doğum tarihini seçiniz',
              selectedDate: _birthDate,
              onDateChanged: (date) {
                setState(() {
                  _birthDate = date;
                  // Burç otomatik hesaplama
                  if (_birthDate != null) {
                    final zodiacSign = ZodiacCalculator.calculateZodiacSign(
                      _birthDate!,
                    );
                    _zodiacSign = ZodiacCalculator.getZodiacName(zodiacSign);
                  }
                });
              },
              lastDate: DateTime.now(),
              firstDate: DateTime.now().subtract(
                const Duration(days: 365 * 5),
              ), // Son 5 yıl
              required: true,
            ),

            const SizedBox(height: 24),

            // Gender selection
            GenderDropdown(
              selectedGender: _gender,
              onChanged: (gender) => setState(() => _gender = gender),
              required: true,
            ),

            const SizedBox(height: 24),

            // Zodiac display
            if (_zodiacSign != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                  border: Border.all(
                    color: const Color(0xFF6B4EFF).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: const Color(0xFF6B4EFF),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Burcu: $_zodiacSign',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B4EFF),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Burç özelliklerine uygun öneriler hazırlanacak',
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
              const SizedBox(height: 16),
            ],

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: const Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu bilgiler bebeğinize özel gelişim takibi ve öneriler için kullanılacak.',
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
      ),
    );
  }

  Widget _buildBirthDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Doğum Detayları',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu bilgiler opsiyoneldir. Daha detaylı analiz için paylaşabilirsiniz.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 32),

          // Birth time
          TimePickerWidget(
            label: 'Doğum Saati',
            hint: 'Doğum saatini seçiniz',
            selectedTime: _birthTime,
            onTimeChanged: (time) => setState(() => _birthTime = time),
          ),

          const SizedBox(height: 24),

          // Birth city
          CityDropdown(
            label: 'Doğum Yeri',
            selectedCity: _birthCity,
            onChanged: (city) => setState(() => _birthCity = city),
          ),

          const SizedBox(height: 32),

          // Benefits info
          Text(
            'Bu Bilgilerin Faydaları',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 16),

          _buildBenefitItem(
            Icons.schedule_rounded,
            'Doğum Saati',
            'Astrolojik analizler için yükselen burç hesaplama',
            const Color(0xFF6B4EFF),
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.location_city_rounded,
            'Doğum Yeri',
            'Bölgesel kültürel öneriler ve yerel etkinlikler',
            const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Fiziksel Ölçümler',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1B23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bebeğinizin doğumdaki fiziksel ölçümlerini giriniz.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 32),

          // Weight field
          CustomTextField(
            label: 'Doğum Kilosu (kg)',
            hint: 'Örnek: 3,2',
            controller: _weightController,
            prefixIcon: Icons.monitor_weight_rounded,
            validator: FormValidators.validateWeight,
            inputFormatters: [
              NumericFormatter(maxDigits: 3, allowDecimal: true),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 24),

          // Height field
          CustomTextField(
            label: 'Doğum Boyu (cm)',
            hint: 'Örnek: 50',
            controller: _heightController,
            prefixIcon: Icons.height_rounded,
            validator: FormValidators.validateHeight,
            inputFormatters: [
              NumericFormatter(maxDigits: 3, allowDecimal: true),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 24),

          // Head circumference field (optional)
          CustomTextField(
            label: 'Baş Çevresi (cm)',
            hint: 'Örnek: 35 (Opsiyonel)',
            controller: _headCircumferenceController,
            prefixIcon: Icons.circle_outlined,
            validator: FormValidators.validateHeadCircumference,
            inputFormatters: [
              NumericFormatter(maxDigits: 3, allowDecimal: true),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 24),

          // Growth tracking info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Büyüme Takibi',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu ölçümler, bebeğinizin gelişimini takip etmek ve büyüme eğrilerini oluşturmak için kullanılacak.',
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

  Widget _buildBenefitItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
            color: Colors.black.withOpacity(0.05),
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
                text: _currentStep == 2 ? 'Bebek Kaydını Tamamla' : 'İleri',
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
