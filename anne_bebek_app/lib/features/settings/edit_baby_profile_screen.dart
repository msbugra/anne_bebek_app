import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/date_time_picker_widget.dart';
import '../../shared/widgets/custom_dropdown.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/profile_header.dart';
import '../../shared/models/baby_model.dart';

class EditBabyProfileScreen extends StatefulWidget {
  const EditBabyProfileScreen({super.key});

  @override
  State<EditBabyProfileScreen> createState() => _EditBabyProfileScreenState();
}

class _EditBabyProfileScreenState extends State<EditBabyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthCityController;
  late TextEditingController _birthWeightController;
  late TextEditingController _birthHeightController;
  late TextEditingController _birthHeadCircumferenceController;

  DateTime? _selectedBirthDate;
  TimeOfDay? _selectedBirthTime;
  BabyGender? _selectedGender;
  bool _isLoading = false;

  final List<DropdownItem<String>> _genderOptions = [
    const DropdownItem<String>(
      value: 'male',
      text: 'Erkek',
      icon: Icons.male_rounded,
    ),
    const DropdownItem<String>(
      value: 'female',
      text: 'Kız',
      icon: Icons.female_rounded,
    ),
    const DropdownItem<String>(
      value: 'unknown',
      text: 'Belirtilmemiş',
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final baby = babyProvider.currentBaby;

    _nameController = TextEditingController(text: baby?.name ?? '');
    _birthCityController = TextEditingController(text: baby?.birthCity ?? '');
    _birthWeightController = TextEditingController(
      text: baby?.birthWeight?.toStringAsFixed(1) ?? '',
    );
    _birthHeightController = TextEditingController(
      text: baby?.birthHeight?.toStringAsFixed(1) ?? '',
    );
    _birthHeadCircumferenceController = TextEditingController(
      text: baby?.birthHeadCircumference?.toStringAsFixed(1) ?? '',
    );

    _selectedBirthDate = baby?.birthDate;
    _selectedBirthTime = baby?.birthTime != null
        ? TimeOfDay.fromDateTime(
            DateTime.parse('2024-01-01 ${baby!.birthTime}'),
          )
        : null;
    _selectedGender = baby?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthCityController.dispose();
    _birthWeightController.dispose();
    _birthHeightController.dispose();
    _birthHeadCircumferenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Bebek Profili Düzenle',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Kaydet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  ProfileHeader(
                    title: _nameController.text.isEmpty
                        ? 'Bebek Profili'
                        : _nameController.text,
                    subtitle: 'Temel bilgileri düzenleyin',
                    icon: Icons.baby_changing_station_rounded,
                    iconColor: Colors.blue,
                  ),

                  const SizedBox(height: 24),

                  // Temel Bilgiler Bölümü
                  _buildSectionTitle('Temel Bilgiler'),
                  const SizedBox(height: 16),

                  // İsim
                  CustomTextField(
                    controller: _nameController,
                    label: 'İsim',
                    hint: 'Bebeğinizin adını girin',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'İsim zorunludur';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Doğum Tarihi
                  DateTimePickerWidget(
                    label: 'Doğum Tarihi',
                    selectedDate: _selectedBirthDate,
                    onDateChanged: (date) {
                      setState(() {
                        _selectedBirthDate = date;
                      });
                    },
                    required: true,
                  ),

                  const SizedBox(height: 16),

                  // Doğum Saati
                  TimePickerWidget(
                    label: 'Doğum Saati',
                    selectedTime: _selectedBirthTime,
                    onTimeChanged: (time) {
                      setState(() {
                        _selectedBirthTime = time;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Doğum Şehri
                  CustomTextField(
                    controller: _birthCityController,
                    label: 'Doğum Şehri',
                    hint: 'Doğduğu şehri girin',
                    prefixIcon: Icons.location_city,
                  ),

                  const SizedBox(height: 24),

                  // Fiziksel Ölçümler Bölümü
                  _buildSectionTitle('Fiziksel Ölçümler'),
                  const SizedBox(height: 16),

                  // Doğum Kilosu
                  CustomTextField(
                    controller: _birthWeightController,
                    label: 'Doğum Kilosu (kg)',
                    hint: 'Örn: 3.2',
                    prefixIcon: Icons.monitor_weight,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0 || weight > 10) {
                          return 'Geçerli bir kilo girin (0-10 kg arası)';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Doğum Boyu
                  CustomTextField(
                    controller: _birthHeightController,
                    label: 'Doğum Boyu (cm)',
                    hint: 'Örn: 50.5',
                    prefixIcon: Icons.height,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final height = double.tryParse(value);
                        if (height == null || height <= 0 || height > 80) {
                          return 'Geçerli bir boy girin (0-80 cm arası)';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Baş Çevresi
                  CustomTextField(
                    controller: _birthHeadCircumferenceController,
                    label: 'Baş Çevresi (cm)',
                    hint: 'Örn: 35.0',
                    prefixIcon: Icons.circle,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final circumference = double.tryParse(value);
                        if (circumference == null ||
                            circumference <= 0 ||
                            circumference > 50) {
                          return 'Geçerli bir baş çevresi girin (0-50 cm arası)';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Sağlık Bilgileri Bölümü
                  _buildSectionTitle('Sağlık Bilgileri'),
                  const SizedBox(height: 16),

                  // Cinsiyet
                  CustomDropdown<String>(
                    label: 'Cinsiyet',
                    value: _selectedGender?.name,
                    items: _genderOptions,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          switch (value) {
                            case 'male':
                              _selectedGender = BabyGender.male;
                              break;
                            case 'female':
                              _selectedGender = BabyGender.female;
                              break;
                            case 'unknown':
                              _selectedGender = BabyGender.unknown;
                              break;
                            default:
                              _selectedGender = null;
                          }
                        });
                      } else {
                        setState(() {
                          _selectedGender = null;
                        });
                      }
                    },
                    prefixIcon: Icons.wc,
                  ),

                  const SizedBox(height: 32),

                  // Kaydet Butonu
                  CustomButton(
                    text: 'Profili Kaydet',
                    onPressed: _saveProfile,
                    loading: _isLoading,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Doğum tarihi zorunludur')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);

      // Doğum saatini string'e çevir
      String? birthTimeString;
      if (_selectedBirthTime != null) {
        final now = DateTime.now();
        final birthDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _selectedBirthTime!.hour,
          _selectedBirthTime!.minute,
        );
        birthTimeString =
            '${birthDateTime.hour.toString().padLeft(2, '0')}:${birthDateTime.minute.toString().padLeft(2, '0')}';
      }

      final success = await babyProvider.saveBabyProfile(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        birthTime: birthTimeString,
        birthWeight: _birthWeightController.text.isNotEmpty
            ? double.tryParse(_birthWeightController.text)
            : null,
        birthHeight: _birthHeightController.text.isNotEmpty
            ? double.tryParse(_birthHeightController.text)
            : null,
        birthHeadCircumference:
            _birthHeadCircumferenceController.text.isNotEmpty
            ? double.tryParse(_birthHeadCircumferenceController.text)
            : null,
        birthCity: _birthCityController.text.isEmpty
            ? null
            : _birthCityController.text.trim(),
        gender: _selectedGender,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bebek profili başarıyla güncellendi')),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              babyProvider.errorMessage ?? 'Profil güncellenirken hata oluştu',
            ),
          ),
        );
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
