import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/date_time_picker_widget.dart';
import '../../shared/widgets/custom_switch.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/profile_header.dart';

class EditMotherProfileScreen extends StatefulWidget {
  const EditMotherProfileScreen({super.key});

  @override
  State<EditMotherProfileScreen> createState() =>
      _EditMotherProfileScreenState();
}

class _EditMotherProfileScreenState extends State<EditMotherProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthCityController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  DateTime? _selectedBirthDate;
  bool _astrologyEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final mother = babyProvider.currentMother;

    _nameController = TextEditingController(text: mother?.name ?? '');
    _birthCityController = TextEditingController(text: mother?.birthCity ?? '');
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedBirthDate = mother?.birthDate;
    _astrologyEnabled = mother?.astrologyEnabled ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthCityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Anne Profili Düzenle',
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
                        ? 'Anne Profili'
                        : _nameController.text,
                    subtitle: 'Temel bilgileri düzenleyin',
                    icon: Icons.person_rounded,
                    iconColor: Colors.pink,
                  ),

                  const SizedBox(height: 24),

                  // Temel Bilgiler Bölümü
                  _buildSectionTitle('Temel Bilgiler'),
                  const SizedBox(height: 16),

                  // İsim
                  CustomTextField(
                    controller: _nameController,
                    label: 'İsim',
                    hint: 'Adınızı girin',
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
                  ),

                  const SizedBox(height: 16),

                  // Doğum Şehri
                  CustomTextField(
                    controller: _birthCityController,
                    label: 'Doğum Şehri',
                    hint: 'Doğduğunuz şehri girin',
                    prefixIcon: Icons.location_city,
                  ),

                  const SizedBox(height: 24),

                  // Astroloji Tercihleri Bölümü
                  _buildSectionTitle('Astroloji Tercihleri'),
                  const SizedBox(height: 16),

                  // Astroloji Modülü
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Astroloji Modülü',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Burç uyumluluğu ve astroloji özelliklerini etkinleştir',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CustomSwitch(
                              value: _astrologyEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _astrologyEnabled = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // İletişim Bilgileri Bölümü
                  _buildSectionTitle('İletişim Bilgileri (Opsiyonel)'),
                  const SizedBox(height: 16),

                  // E-posta
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    hint: 'ornek@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Geçerli bir e-posta adresi girin';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Telefon
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    hint: '+90 5XX XXX XX XX',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
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

    setState(() {
      _isLoading = true;
    });

    try {
      final babyProvider = Provider.of<BabyProvider>(context, listen: false);

      final success = await babyProvider.saveMotherProfile(
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate,
        birthCity: _birthCityController.text.isEmpty
            ? null
            : _birthCityController.text.trim(),
        astrologyEnabled: _astrologyEnabled,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anne profili başarıyla güncellendi')),
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
