import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/vaccination_model.dart';

class VaccinationDetailScreen extends StatefulWidget {
  final VaccinationModel? vaccination;
  final bool isEditing;

  const VaccinationDetailScreen({
    super.key,
    this.vaccination,
    this.isEditing = false,
  });

  @override
  State<VaccinationDetailScreen> createState() =>
      _VaccinationDetailScreenState();
}

class _VaccinationDetailScreenState extends State<VaccinationDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _scheduledDate = DateTime.now();
  DateTime? _administeredDate;
  int _doseNumber = 1;
  VaccineStatus _status = VaccineStatus.scheduled;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (widget.vaccination != null) {
      final vaccination = widget.vaccination!;
      _vaccineNameController.text = vaccination.vaccineName;
      _locationController.text = vaccination.location ?? '';
      _notesController.text = vaccination.notes ?? '';
      _scheduledDate = vaccination.scheduledDate;
      _administeredDate = vaccination.administeredDate;
      _doseNumber = vaccination.doseNumber;
      _status = vaccination.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewVaccination = widget.vaccination == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewVaccination
              ? 'Yeni Aşı Ekle'
              : widget.isEditing
              ? 'Aşı Düzenle'
              : 'Aşı Detayları',
        ),
        actions: [
          if (!isNewVaccination && !widget.isEditing) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: _toggleEdit),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                if (_status != VaccineStatus.completed) ...[
                  const PopupMenuItem(
                    value: 'mark_completed',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Tamamlandı İşaretle'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: (isNewVaccination || widget.isEditing)
          ? _buildActionButtons()
          : null,
    );
  }

  Widget _buildBody() {
    if (widget.vaccination != null && !widget.isEditing) {
      return _buildViewMode();
    }
    return _buildEditMode();
  }

  Widget _buildViewMode() {
    final vaccination = widget.vaccination!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(vaccination),
          const SizedBox(height: 16),
          _buildInfoSection(vaccination),
          if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesSection(vaccination),
          ],
          const SizedBox(height: 16),
          _buildTimelineSection(vaccination),
        ],
      ),
    );
  }

  Widget _buildStatusCard(VaccinationModel vaccination) {
    final statusColor = _getStatusColor(vaccination.status);
    final statusIcon = _getStatusIcon(vaccination.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination.vaccineName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vaccination.doseNumber}. Doz',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    vaccination.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (vaccination.isDelayed) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${vaccination.delayDays} gün gecikme var',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(VaccinationModel vaccination) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aşı Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.schedule,
              'Planlanan Tarih',
              _formatDate(vaccination.scheduledDate),
            ),
            if (vaccination.administeredDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.event_available,
                'Yapıldığı Tarih',
                _formatDate(vaccination.administeredDate!),
              ),
            ],
            if (vaccination.location != null &&
                vaccination.location!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.location_on,
                'Lokasyon',
                vaccination.location!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(VaccinationModel vaccination) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notes, size: 20),
                SizedBox(width: 8),
                Text(
                  'Notlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                vaccination.notes!,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection(VaccinationModel vaccination) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zaman Çizelgesi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              Icons.add_circle_outline,
              'Kayıt Oluşturuldu',
              _formatDateTime(vaccination.createdAt),
              Colors.blue,
            ),
            if (vaccination.administeredDate != null) ...[
              const SizedBox(height: 8),
              _buildTimelineItem(
                Icons.check_circle,
                'Aşı Tamamlandı',
                _formatDateTime(vaccination.administeredDate!),
                Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVaccineNameField(),
            const SizedBox(height: 16),
            _buildDoseNumberField(),
            const SizedBox(height: 16),
            _buildScheduledDateField(),
            const SizedBox(height: 16),
            _buildStatusField(),
            if (_status == VaccineStatus.completed) ...[
              const SizedBox(height: 16),
              _buildAdministeredDateField(),
            ],
            const SizedBox(height: 16),
            _buildLocationField(),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aşı Adı *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _vaccineNameController,
          decoration: const InputDecoration(
            hintText: 'Aşı adını girin',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.vaccines),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Aşı adı gereklidir';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDoseNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doz Numarası *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _doseNumber,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.format_list_numbered),
          ),
          items: List.generate(10, (index) => index + 1)
              .map(
                (dose) =>
                    DropdownMenuItem(value: dose, child: Text('$dose. Doz')),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _doseNumber = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildScheduledDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Planlanan Tarih *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectScheduledDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(_formatDate(_scheduledDate)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durum *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<VaccineStatus>(
          initialValue: _status,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info),
          ),
          items: VaccineStatus.values
              .map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusDisplayName(status)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _status = value;
                if (_status != VaccineStatus.completed) {
                  _administeredDate = null;
                } else {
                  _administeredDate ??= DateTime.now();
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAdministeredDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yapıldığı Tarih *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectAdministeredDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event_available),
            ),
            child: Text(
              _administeredDate != null
                  ? _formatDate(_administeredDate!)
                  : 'Tarih seçin',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lokasyon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            hintText: 'Hastane, sağlık ocağı vb.',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'İsteğe bağlı notlar...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.notes),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveVaccination,
              child: Text(widget.vaccination == null ? 'Kaydet' : 'Güncelle'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectScheduledDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _scheduledDate = date);
    }
  }

  Future<void> _selectAdministeredDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _administeredDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _administeredDate = date);
    }
  }

  void _toggleEdit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VaccinationDetailScreen(
          vaccination: widget.vaccination,
          isEditing: true,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'mark_completed':
        await _markAsCompleted();
        break;
      case 'delete':
        await _deleteVaccination();
        break;
    }
  }

  Future<void> _markAsCompleted() async {
    if (widget.vaccination == null) return;

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final updatedVaccination = widget.vaccination!.copyWith(
      status: VaccineStatus.completed,
      administeredDate: DateTime.now(),
    );

    setState(() => _isLoading = true);
    final success = await healthProvider.updateVaccination(updatedVaccination);
    setState(() => _isLoading = false);

    if (success) {
      _showMessage('Aşı tamamlandı olarak işaretlendi');
      Navigator.pop(context);
    } else {
      _showMessage('Aşı güncellenirken hata oluştu');
    }
  }

  Future<void> _deleteVaccination() async {
    if (widget.vaccination == null) return;

    final confirm = await _showConfirmDialog(
      'Aşı Kaydını Sil',
      'Bu aşı kaydı silinsin mi? Bu işlem geri alınamaz.',
    );

    if (confirm) {
      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      setState(() => _isLoading = true);
      final success = await healthProvider.deleteVaccination(
        widget.vaccination!.id!.toString(),
      );
      setState(() => _isLoading = false);

      if (success) {
        _showMessage('Aşı kaydı silindi');
        Navigator.pop(context);
      } else {
        _showMessage('Aşı kaydı silinirken hata oluştu');
      }
    }
  }

  Future<void> _saveVaccination() async {
    if (!_formKey.currentState!.validate()) return;

    if (_status == VaccineStatus.completed && _administeredDate == null) {
      _showMessage('Tamamlanmış aşı için tarih gereklidir');
      return;
    }

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    if (babyProvider.currentBaby?.id == null) {
      _showMessage('Bebek bilgisi bulunamadı');
      return;
    }

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    bool success;
    if (widget.vaccination == null) {
      // New vaccination
      final vaccination = VaccinationModel(
        babyId: babyProvider.currentBaby!.id!,
        vaccineName: _vaccineNameController.text,
        scheduledDate: _scheduledDate,
        administeredDate: _administeredDate,
        doseNumber: _doseNumber,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        status: _status,
        createdAt: DateTime.now(),
      );
      success = await healthProvider.addVaccination(vaccination);
    } else {
      // Update existing vaccination
      final updatedVaccination = widget.vaccination!.copyWith(
        vaccineName: _vaccineNameController.text,
        scheduledDate: _scheduledDate,
        administeredDate: _administeredDate,
        doseNumber: _doseNumber,
        location: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        status: _status,
      );
      success = await healthProvider.updateVaccination(updatedVaccination);
    }

    setState(() => _isLoading = false);

    if (success) {
      _showMessage(
        widget.vaccination == null
            ? 'Aşı kaydı eklendi'
            : 'Aşı kaydı güncellendi',
      );
      Navigator.pop(context);
    } else {
      _showMessage(
        widget.vaccination == null
            ? 'Aşı kaydı eklenirken hata oluştu'
            : 'Aşı kaydı güncellenirken hata oluştu',
      );
    }
  }

  Color _getStatusColor(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.completed:
        return Colors.green;
      case VaccineStatus.scheduled:
        return Colors.blue;
      case VaccineStatus.delayed:
        return Colors.orange;
      case VaccineStatus.skipped:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.completed:
        return Icons.check_circle;
      case VaccineStatus.scheduled:
        return Icons.schedule;
      case VaccineStatus.delayed:
        return Icons.warning;
      case VaccineStatus.skipped:
        return Icons.block;
    }
  }

  String _getStatusDisplayName(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.scheduled:
        return 'Planlanmış';
      case VaccineStatus.completed:
        return 'Tamamlanmış';
      case VaccineStatus.delayed:
        return 'Gecikmiş';
      case VaccineStatus.skipped:
        return 'Atlanmış';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
