import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/vaccination_model.dart';
import '../../shared/widgets/vaccination_card.dart';
import '../../shared/widgets/custom_switch.dart';
import 'vaccination_detail_screen.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  VaccineStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVaccinations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccinations() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    if (babyProvider.currentBaby?.id != null) {
      await healthProvider.initializeHealthData(
        babyProvider.currentBaby!.id!.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aşı Takibi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_schedule',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome),
                    SizedBox(width: 8),
                    Text('Aşı Takvimi Oluştur'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Dışa Aktar'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Consumer<HealthProvider>(
                builder: (context, healthProvider, child) {
                  final upcomingCount =
                      healthProvider.upcomingVaccinations.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Yaklaşan'),
                      if (upcomingCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$upcomingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Consumer<HealthProvider>(
                builder: (context, healthProvider, child) {
                  final overdueCount =
                      healthProvider.overdueVaccinations.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Gecikmiş'),
                      if (overdueCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$overdueCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: Consumer<HealthProvider>(
                builder: (context, healthProvider, child) {
                  final completedCount =
                      healthProvider.completedVaccinationsCount;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tamamlanan'),
                      if (completedCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$completedCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            const Tab(text: 'Tümü'),
          ],
        ),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.errorMessage != null) {
            return _buildErrorState(healthProvider.errorMessage!);
          }

          return Column(
            children: [
              _buildSummaryCards(healthProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVaccinationList(healthProvider.upcomingVaccinations),
                    _buildVaccinationList(healthProvider.overdueVaccinations),
                    _buildVaccinationList(
                      _getCompletedVaccinations(healthProvider),
                    ),
                    _buildVaccinationList(
                      _getFilteredVaccinations(healthProvider),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVaccination,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCards(HealthProvider healthProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Tamamlanan',
              healthProvider.completedVaccinationsCount.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Bekleyen',
              healthProvider.pendingVaccinationsCount.toString(),
              Colors.blue,
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Gecikmiş',
              healthProvider.delayedVaccinationsCount.toString(),
              Colors.red,
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationList(List<VaccinationModel> vaccinations) {
    if (vaccinations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadVaccinations,
      child: VaccinationTimeline(
        vaccinations: vaccinations,
        onVaccinationTap: _navigateToDetail,
        onVaccinationEdit: _editVaccination,
        onVaccinationDelete: _deleteVaccination,
        onMarkCompleted: _markAsCompleted,
        onAddVaccination: _addVaccination,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vaccines, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz aşı kaydı bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aşı takvimi oluşturun veya manuel aşı ekleyin',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _generateVaccinationSchedule,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Aşı Takvimi Oluştur'),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _addVaccination,
                icon: const Icon(Icons.add),
                label: const Text('Manuel Ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadVaccinations,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
          ),
        ],
      ),
    );
  }

  List<VaccinationModel> _getCompletedVaccinations(
    HealthProvider healthProvider,
  ) {
    return healthProvider.vaccinations
        .where((v) => v.status == VaccineStatus.completed)
        .toList();
  }

  List<VaccinationModel> _getFilteredVaccinations(
    HealthProvider healthProvider,
  ) {
    List<VaccinationModel> filtered = healthProvider.vaccinations;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (v) => v.vaccineName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((v) => v.status == _selectedStatus).toList();
    }

    return filtered;
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = _searchQuery;
        return AlertDialog(
          title: const Text('Aşı Ara'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Aşı adını girin...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => tempQuery = value,
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _searchQuery = tempQuery);
                Navigator.pop(context);
              },
              child: const Text('Ara'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        VaccineStatus? tempStatus = _selectedStatus;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtrele'),
              content: CustomRadioGroup<VaccineStatus?>(
                value: tempStatus,
                onChanged: (value) => setDialogState(() => tempStatus = value),
                options: const [
                  RadioOption(value: null, title: 'Tümü'),
                  RadioOption(
                    value: VaccineStatus.scheduled,
                    title: 'Planlanmış',
                  ),
                  RadioOption(
                    value: VaccineStatus.completed,
                    title: 'Tamamlanmış',
                  ),
                  RadioOption(value: VaccineStatus.delayed, title: 'Gecikmiş'),
                  RadioOption(value: VaccineStatus.skipped, title: 'Atlanmış'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedStatus = tempStatus);
                    Navigator.pop(context);
                  },
                  child: const Text('Uygula'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'generate_schedule':
        _generateVaccinationSchedule();
        break;
      case 'export':
        _exportVaccinations();
        break;
    }
  }

  Future<void> _generateVaccinationSchedule() async {
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    if (babyProvider.currentBaby == null) {
      _showMessage('Önce bebek profili oluşturulmalıdır');
      return;
    }

    final confirm = await _showConfirmDialog(
      'Aşı Takvimi Oluştur',
      'T.C. Sağlık Bakanlığı\'na göre aşı takvimi oluşturulsun mu? Mevcut kayıtlar korunacaktır.',
    );

    if (!mounted) return;
    if (confirm) {
      final success = await healthProvider.generateVaccinationSchedule(
        babyProvider.currentBaby!.birthDate,
      );
      if (success) {
        _showMessage('Aşı takvimi başarıyla oluşturuldu');
      } else {
        _showMessage('Aşı takvimi oluşturulurken hata oluştu');
      }
    }
  }

  void _exportVaccinations() {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final vaccinations = healthProvider.vaccinations;

    if (vaccinations.isEmpty) {
      _showMessage('Dışa aktarılacak aşı kaydı yok');
      return;
    }

    Future(() async {
      try {
        final rows = <List<dynamic>>[];
        rows.add([
          'Aşı Adı',
          'Doz',
          'Planlanan Tarih',
          'Uygulanan Tarih',
          'Durum',
          'Konum',
          'Notlar',
          'Gecikme (gün)',
        ]);

        for (final v in vaccinations) {
          rows.add([
            v.vaccineName,
            v.doseNumber,
            _formatDate(v.scheduledDate),
            v.administeredDate != null ? _formatDate(v.administeredDate!) : '',
            v.statusDisplayName,
            v.location ?? '',
            v.notes ?? '',
            v.delayDays,
          ]);
        }

        final csv = const ListToCsvConverter().convert(rows);
        final dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/vaccinations_${DateTime.now().millisecondsSinceEpoch}.csv',
        );
        await file.writeAsString(csv);

        if (!mounted) return;
        _showMessage('Dışa aktarıldı: ${file.path}');
      } catch (e) {
        if (!mounted) return;
        _showMessage('Dışa aktarım hatası: $e');
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToDetail(VaccinationModel vaccination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationDetailScreen(vaccination: vaccination),
      ),
    );
  }

  void _addVaccination() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VaccinationDetailScreen()),
    ).then((_) => _loadVaccinations());
  }

  void _editVaccination(VaccinationModel vaccination) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VaccinationDetailScreen(vaccination: vaccination, isEditing: true),
      ),
    ).then((_) => _loadVaccinations());
  }

  Future<void> _deleteVaccination(VaccinationModel vaccination) async {
    final confirm = await _showConfirmDialog(
      'Aşı Kaydını Sil',
      '${vaccination.vaccineName} aşı kaydı silinsin mi? Bu işlem geri alınamaz.',
    );

    if (!mounted) return;
    if (confirm) {
      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      final success = await healthProvider.deleteVaccination(
        vaccination.id!.toString(),
      );

      if (!mounted) return;
      if (success) {
        _showMessage('Aşı kaydı silindi');
      } else {
        _showMessage('Aşı kaydı silinirken hata oluştu');
      }
    }
  }

  Future<void> _markAsCompleted(VaccinationModel vaccination) async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final updatedVaccination = vaccination.copyWith(
      status: VaccineStatus.completed,
      administeredDate: DateTime.now(),
    );

    final success = await healthProvider.updateVaccination(updatedVaccination);

    if (!mounted) return;
    if (success) {
      _showMessage('Aşı tamamlandı olarak işaretlendi');
    } else {
      _showMessage('Aşı güncellenirken hata oluştu');
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Onayla'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
