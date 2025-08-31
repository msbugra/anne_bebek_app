import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/growth_tracking_model.dart';

class AddMeasurementScreen extends StatefulWidget {
  final GrowthTrackingModel? measurement;
  final bool isEditing;

  const AddMeasurementScreen({
    super.key,
    this.measurement,
    this.isEditing = false,
  });

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headCircumferenceController = TextEditingController();

  DateTime _measurementDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headCircumferenceController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (widget.measurement != null) {
      final measurement = widget.measurement!;
      _measurementDate = measurement.measurementDate;
      _weightController.text = measurement.weight?.toString() ?? '';
      _heightController.text = measurement.height?.toString() ?? '';
      _headCircumferenceController.text =
          measurement.headCircumference?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewMeasurement = widget.measurement == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewMeasurement
              ? 'Yeni Ölçüm Ekle'
              : widget.isEditing
              ? 'Ölçüm Düzenle'
              : 'Ölçüm Detayları',
        ),
        actions: [
          if (!isNewMeasurement && !widget.isEditing) ...[
            IconButton(icon: const Icon(Icons.edit), onPressed: _toggleEdit),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
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
      bottomNavigationBar: (isNewMeasurement || widget.isEditing)
          ? _buildActionButtons()
          : null,
    );
  }

  Widget _buildBody() {
    if (widget.measurement != null && !widget.isEditing) {
      return _buildViewMode();
    }
    return _buildEditMode();
  }

  Widget _buildViewMode() {
    final measurement = widget.measurement!;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMeasurementSummaryCard(measurement),
          const SizedBox(height: 16),
          _buildPercentileCard(measurement, baby),
          const SizedBox(height: 16),
          _buildMeasurementDetailsCard(measurement),
          const SizedBox(height: 16),
          _buildAssessmentCard(measurement),
        ],
      ),
    );
  }

  Widget _buildMeasurementSummaryCard(GrowthTrackingModel measurement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Ölçüm Özeti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(measurement.measurementDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (measurement.weight != null)
                  Expanded(
                    child: _buildMeasurementItem(
                      'Kilo',
                      '${measurement.weight!.toStringAsFixed(1)} kg',
                      Colors.blue,
                      Icons.monitor_weight,
                    ),
                  ),
                if (measurement.height != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMeasurementItem(
                      'Boy',
                      '${measurement.height!.toStringAsFixed(1)} cm',
                      Colors.green,
                      Icons.height,
                    ),
                  ),
                ],
                if (measurement.headCircumference != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMeasurementItem(
                      'Baş Çevresi',
                      '${measurement.headCircumference!.toStringAsFixed(1)} cm',
                      Colors.purple,
                      Icons.face,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPercentileCard(GrowthTrackingModel measurement, dynamic baby) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'WHO Percentil Değerleri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (measurement.weightPercentile != null)
                  Expanded(
                    child: _buildPercentileItem(
                      'Kilo',
                      'P${measurement.weightPercentile!.toInt()}',
                      _getPercentileColor(measurement.weightPercentile!),
                    ),
                  ),
                if (measurement.heightPercentile != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPercentileItem(
                      'Boy',
                      'P${measurement.heightPercentile!.toInt()}',
                      _getPercentileColor(measurement.heightPercentile!),
                    ),
                  ),
                ],
                if (measurement.headPercentile != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPercentileItem(
                      'Baş Ç.',
                      'P${measurement.headPercentile!.toInt()}',
                      _getPercentileColor(measurement.headPercentile!),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'WHO standartlarına göre yaş grubu: ${measurement.ageGroup}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentileItem(String title, String percentile, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        children: [
          Text(
            percentile,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildMeasurementDetailsCard(GrowthTrackingModel measurement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ölçüm Detayları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.calendar_today,
              'Ölçüm Tarihi',
              _formatDate(measurement.measurementDate),
            ),
            _buildDetailRow(
              Icons.child_care,
              'Bebek Yaşı',
              '${measurement.ageInDays} gün (${(measurement.ageInDays / 30).toStringAsFixed(1)} ay)',
            ),
            _buildDetailRow(
              Icons.access_time,
              'Kayıt Tarihi',
              _formatDateTime(measurement.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(GrowthTrackingModel measurement) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Değerlendirme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAssessmentRow('Kilo Durumu', measurement.growthAssessment),
            _buildAssessmentRow('Boy Durumu', measurement.heightAssessment),
            _buildAssessmentRow(
              'Baş Çevresi',
              measurement.headCircumferenceAssessment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
      ),
    );
  }

  Widget _buildAssessmentRow(String label, String assessment) {
    final color = _getAssessmentColor(assessment);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            assessment,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
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
            _buildMeasurementDateField(),
            const SizedBox(height: 24),
            _buildMeasurementFieldsCard(),
            const SizedBox(height: 16),
            _buildPercentileInfoCard(),
            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ölçüm Tarihi *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(_formatDate(_measurementDate)),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementFieldsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.straighten, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Ölçüm Değerleri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeightField(),
            const SizedBox(height: 16),
            _buildHeightField(),
            const SizedBox(height: 16),
            _buildHeadCircumferenceField(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kilo (kg)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Örn: 4.5',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.monitor_weight),
            suffixText: 'kg',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0 || weight > 50) {
                return 'Geçerli bir kilo değeri girin (0-50 kg)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Boy (cm)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Örn: 65.5',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.height),
            suffixText: 'cm',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final height = double.tryParse(value);
              if (height == null || height <= 0 || height > 200) {
                return 'Geçerli bir boy değeri girin (0-200 cm)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildHeadCircumferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Baş Çevresi (cm)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _headCircumferenceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Örn: 42.0',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.face),
            suffixText: 'cm',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final headCircumference = double.tryParse(value);
              if (headCircumference == null ||
                  headCircumference <= 0 ||
                  headCircumference > 100) {
                return 'Geçerli bir baş çevresi değeri girin (0-100 cm)';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPercentileInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Percentil Bilgisi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ölçümleri kaydettikten sonra WHO standartlarına göre percentil değerleri otomatik olarak hesaplanacaktır.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Percentil Açıklaması:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• P3-P10: Normal alt sınır\n• P10-P90: Normal aralık\n• P90-P97: Normal üst sınır',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[600],
                      height: 1.3,
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255 * 0.2).round()),
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
              onPressed: _saveMeasurement,
              child: Text(widget.measurement == null ? 'Kaydet' : 'Güncelle'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _measurementDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _measurementDate = date);
    }
  }

  void _toggleEdit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddMeasurementScreen(
          measurement: widget.measurement,
          isEditing: true,
        ),
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'delete':
        await _deleteMeasurement();
        break;
    }
  }

  Future<void> _deleteMeasurement() async {
    if (widget.measurement == null) return;

    final confirm = await _showConfirmDialog(
      'Ölçüm Kaydını Sil',
      'Bu ölçüm kaydı silinsin mi? Bu işlem geri alınamaz.',
    );

    if (!mounted) return;

    if (confirm) {
      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      setState(() => _isLoading = true);
      final success = await healthProvider.deleteGrowthMeasurement(
        widget.measurement!.id!.toString(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        _showMessage('Ölçüm kaydı silindi');
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        _showMessage('Ölçüm kaydı silinirken hata oluştu');
      }
    }
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    // At least one measurement should be provided
    final weight = _weightController.text.isNotEmpty
        ? double.tryParse(_weightController.text)
        : null;
    final height = _heightController.text.isNotEmpty
        ? double.tryParse(_heightController.text)
        : null;
    final headCircumference = _headCircumferenceController.text.isNotEmpty
        ? double.tryParse(_headCircumferenceController.text)
        : null;

    if (weight == null && height == null && headCircumference == null) {
      _showMessage('En az bir ölçüm değeri girilmelidir');
      return;
    }

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    if (babyProvider.currentBaby?.id == null) {
      _showMessage('Bebek bilgisi bulunamadı');
      return;
    }

    final baby = babyProvider.currentBaby!;
    final ageInDays = DateTime.now().difference(baby.birthDate).inDays;
    final isMale = baby.gender?.toString().contains('male') ?? true;

    // Calculate percentiles
    double? weightPercentile;
    double? heightPercentile;
    double? headPercentile;

    if (weight != null) {
      weightPercentile = WHOGrowthCalculator.calculatePercentile(
        weight,
        ageInDays,
        isMale,
        'weight',
      );
    }

    if (height != null) {
      heightPercentile = WHOGrowthCalculator.calculatePercentile(
        height,
        ageInDays,
        isMale,
        'height',
      );
    }

    if (headCircumference != null) {
      headPercentile = WHOGrowthCalculator.calculatePercentile(
        headCircumference,
        ageInDays,
        isMale,
        'head',
      );
    }

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    bool success;
    if (widget.measurement == null) {
      // New measurement
      final measurement = GrowthTrackingModel(
        babyId: baby.id!,
        measurementDate: _measurementDate,
        ageInDays: ageInDays,
        weight: weight,
        height: height,
        headCircumference: headCircumference,
        weightPercentile: weightPercentile,
        heightPercentile: heightPercentile,
        headPercentile: headPercentile,
        createdAt: DateTime.now(),
      );
      if (!mounted) return;
      success = await healthProvider.addGrowthMeasurement(measurement);
    } else {
      // Update existing measurement
      final updatedMeasurement = widget.measurement!.copyWith(
        measurementDate: _measurementDate,
        ageInDays: ageInDays,
        weight: weight,
        height: height,
        headCircumference: headCircumference,
        weightPercentile: weightPercentile,
        heightPercentile: heightPercentile,
        headPercentile: headPercentile,
      );
      if (!mounted) return;
      success = await healthProvider.updateGrowthMeasurement(
        updatedMeasurement,
      );
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      _showMessage(
        widget.measurement == null
            ? 'Ölçüm kaydı eklendi'
            : 'Ölçüm kaydı güncellendi',
      );
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      _showMessage(
        widget.measurement == null
            ? 'Ölçüm kaydı eklenirken hata oluştu'
            : 'Ölçüm kaydı güncellenirken hata oluştu',
      );
    }
  }

  Color _getPercentileColor(double percentile) {
    if (percentile < 3 || percentile > 97) return Colors.red;
    if (percentile < 10 || percentile > 90) return Colors.orange;
    return Colors.green;
  }

  Color _getAssessmentColor(String assessment) {
    if (assessment.contains('Normal')) return Colors.green;
    if (assessment.contains('altında') || assessment.contains('riski')) {
      return Colors.red;
    }
    if (assessment.contains('sınır')) return Colors.orange;
    return Colors.grey;
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
