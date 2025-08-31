import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/widgets/custom_switch.dart';
import '../../shared/models/feeding_tracking_model.dart';
import '../../shared/models/breastfeeding_tracking_model.dart' as bf;

class AddFeedingScreen extends StatefulWidget {
  final FeedingTrackingModel? feedingRecord;
  final bf.BreastfeedingTrackingModel? breastfeedingRecord;
  final bool isEditing;

  const AddFeedingScreen({
    super.key,
    this.feedingRecord,
    this.breastfeedingRecord,
    this.isEditing = false,
  });

  @override
  State<AddFeedingScreen> createState() => _AddFeedingScreenState();
}

class _AddFeedingScreenState extends State<AddFeedingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Common fields
  DateTime _feedingDateTime = DateTime.now();
  bool _isLoading = false;

  // Breastfeeding fields
  int _durationMinutes = 15;
  bf.BreastSide _breastSide = bf.BreastSide.left;
  bf.BreastfeedingQuality? _feedingQuality = bf.BreastfeedingQuality.good;
  bool? _babyWasSatisfied = true;
  bool? _hadDifficulty = false;
  final _difficultyNoteController = TextEditingController();
  final _breastfeedingNotesController = TextEditingController();

  // Feeding fields
  FeedingType _feedingType = FeedingType.formula;
  double? _amountMl;
  FormulaType? _formulaType = FormulaType.cowBased;
  final _amountController = TextEditingController();
  final _feedingNotesController = TextEditingController();

  // Solid food fields
  List<SolidFood> _solidFoods = [];
  final _solidFoodController = TextEditingController();
  final _solidFoodAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFields();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _difficultyNoteController.dispose();
    _breastfeedingNotesController.dispose();
    _amountController.dispose();
    _feedingNotesController.dispose();
    _solidFoodController.dispose();
    _solidFoodAmountController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (widget.breastfeedingRecord != null) {
      final record = widget.breastfeedingRecord!;
      _feedingDateTime = record.feedingDateTime;
      _durationMinutes = record.durationMinutes;
      _breastSide = record.breastSide;
      _feedingQuality = record.feedingQuality;
      _babyWasSatisfied = record.babyWasSatisfied;
      _hadDifficulty = record.hadDifficulty;
      _difficultyNoteController.text = record.difficultyNote ?? '';
      _breastfeedingNotesController.text = record.notes ?? '';
      _tabController.index = 0; // Breastfeeding tab
    } else if (widget.feedingRecord != null) {
      final record = widget.feedingRecord!;
      _feedingDateTime = record.feedingDateTime;
      _feedingType = record.feedingType;
      _amountMl = record.amountMl;
      _formulaType = record.formulaType;
      _amountController.text = record.amountMl?.toString() ?? '';
      _feedingNotesController.text = record.notes ?? '';
      _solidFoods = record.solidFoods ?? [];
      _tabController.index = 1; // Feeding tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewRecord =
        widget.feedingRecord == null && widget.breastfeedingRecord == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewRecord
              ? 'Yeni Beslenme Kaydı'
              : widget.isEditing
              ? 'Beslenme Düzenle'
              : 'Beslenme Detayları',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.child_care), text: 'Emzirme'),
            Tab(icon: Icon(Icons.restaurant), text: 'Mama/Katı Gıda'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [_buildBreastfeedingForm(), _buildFeedingForm()],
              ),
            ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildBreastfeedingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeField(),
          const SizedBox(height: 16),
          _buildDurationField(),
          const SizedBox(height: 16),
          _buildBreastSideField(),
          const SizedBox(height: 16),
          _buildFeedingQualityField(),
          const SizedBox(height: 16),
          _buildSatisfactionField(),
          const SizedBox(height: 16),
          _buildDifficultyField(),
          if (_hadDifficulty == true) ...[
            const SizedBox(height: 16),
            _buildDifficultyNoteField(),
          ],
          const SizedBox(height: 16),
          _buildBreastfeedingNotesField(),
          const SizedBox(height: 100), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildFeedingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimeField(),
          const SizedBox(height: 16),
          _buildFeedingTypeField(),
          const SizedBox(height: 16),
          if (_feedingType == FeedingType.formula) ...[
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildFormulaTypeField(),
            const SizedBox(height: 16),
          ],
          if (_feedingType == FeedingType.solidFood ||
              _feedingType == FeedingType.mixed) ...[
            _buildSolidFoodSection(),
            const SizedBox(height: 16),
          ],
          _buildFeedingNotesField(),
          const SizedBox(height: 100), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beslenme Tarih/Saat *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_feedingDateTime)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(_formatTime(_feedingDateTime)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emzirme Süresi (Dakika) *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _durationMinutes.toDouble(),
          min: 1,
          max: 60,
          divisions: 59,
          label: '$_durationMinutes dakika',
          onChanged: (value) {
            setState(() => _durationMinutes = value.round());
          },
        ),
        Text(
          '$_durationMinutes dakika',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBreastSideField() {
    return CustomRadioGroup<bf.BreastSide>(
      title: 'Hangi Meme *',
      value: _breastSide,
      direction: Axis.horizontal,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _breastSide = value;
          });
        }
      },
      options: const [
        RadioOption(value: bf.BreastSide.left, title: 'Sol'),
        RadioOption(value: bf.BreastSide.right, title: 'Sağ'),
        RadioOption(value: bf.BreastSide.both, title: 'Her İkisi'),
      ],
    );
  }

  Widget _buildFeedingQualityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Emzirme Kalitesi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<bf.BreastfeedingQuality>(
          initialValue: _feedingQuality,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.star),
          ),
          items: bf.BreastfeedingQuality.values
              .map(
                (quality) => DropdownMenuItem(
                  value: quality,
                  child: Text(_getBreastfeedingQualityDisplayName(quality)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _feedingQuality = value),
        ),
      ],
    );
  }

  Widget _buildSatisfactionField() {
    return CustomRadioGroup<bool?>(
      title: 'Bebek Doydu mu?',
      value: _babyWasSatisfied,
      direction: Axis.horizontal,
      onChanged: (value) {
        setState(() {
          _babyWasSatisfied = value;
        });
      },
      options: const [
        RadioOption(value: true, title: 'Evet'),
        RadioOption(value: false, title: 'Hayır'),
      ],
    );
  }

  Widget _buildDifficultyField() {
    return CustomRadioGroup<bool?>(
      title: 'Zorluk Yaşandı mı?',
      value: _hadDifficulty,
      direction: Axis.horizontal,
      onChanged: (value) {
        setState(() {
          _hadDifficulty = value;
        });
      },
      options: const [
        RadioOption(value: false, title: 'Hayır'),
        RadioOption(value: true, title: 'Evet'),
      ],
    );
  }

  Widget _buildDifficultyNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zorluk Açıklaması',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _difficultyNoteController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Yaşanan zorluğu açıklayın...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.warning),
          ),
        ),
      ],
    );
  }

  Widget _buildBreastfeedingNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _breastfeedingNotesController,
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

  Widget _buildFeedingTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Beslenme Türü *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FeedingType>(
          initialValue: _feedingType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.restaurant),
          ),
          items: FeedingType.values
              .where(
                (type) => type != FeedingType.breastMilk,
              ) // Exclude breastmilk for this tab
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getFeedingTypeDisplayName(type)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _feedingType = value;
                if (value == FeedingType.solidFood) {
                  _amountMl = null;
                  _formulaType = null;
                } else if (value == FeedingType.formula) {
                  _solidFoods.clear();
                }
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Miktar (ml) *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Mama miktarını girin',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.local_drink),
            suffixText: 'ml',
          ),
          validator: (value) {
            if (_feedingType == FeedingType.formula &&
                (value == null || value.isEmpty)) {
              return 'Mama miktarı gereklidir';
            }
            if (value != null && value.isNotEmpty) {
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Geçerli bir miktar girin';
              }
            }
            return null;
          },
          onChanged: (value) {
            _amountMl = double.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildFormulaTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mama Türü',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<FormulaType>(
          initialValue: _formulaType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info),
          ),
          items: FormulaType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(_getFormulaTypeDisplayName(type)),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _formulaType = value),
        ),
      ],
    );
  }

  Widget _buildSolidFoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Katı Gıdalar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        // Add solid food form
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _solidFoodController,
                decoration: const InputDecoration(
                  hintText: 'Gıda adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _solidFoodAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Miktar',
                  border: OutlineInputBorder(),
                  suffixText: 'g',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addSolidFood,
              icon: const Icon(Icons.add_circle, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Solid foods list
        if (_solidFoods.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _solidFoods.asMap().entries.map((entry) {
                final index = entry.key;
                final food = entry.value;
                return ListTile(
                  dense: true,
                  title: Text(food.name),
                  subtitle: food.amount != null
                      ? Text('${food.amount} ${food.unit ?? "gram"}')
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeSolidFood(index),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeedingNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _feedingNotesController,
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
              onPressed: _saveFeedingRecord,
              child: Text(
                widget.feedingRecord == null &&
                        widget.breastfeedingRecord == null
                    ? 'Kaydet'
                    : 'Güncelle',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _feedingDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _feedingDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _feedingDateTime.hour,
          _feedingDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_feedingDateTime),
    );
    if (time != null) {
      setState(() {
        _feedingDateTime = DateTime(
          _feedingDateTime.year,
          _feedingDateTime.month,
          _feedingDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _addSolidFood() {
    final foodName = _solidFoodController.text.trim();
    if (foodName.isEmpty) return;

    final amount = double.tryParse(_solidFoodAmountController.text);

    setState(() {
      _solidFoods.add(SolidFood(name: foodName, amount: amount, unit: 'gram'));
      _solidFoodController.clear();
      _solidFoodAmountController.clear();
    });
  }

  void _removeSolidFood(int index) {
    setState(() => _solidFoods.removeAt(index));
  }

  Future<void> _saveFeedingRecord() async {
    if (!_formKey.currentState!.validate()) return;

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    if (babyProvider.currentBaby?.id == null) {
      _showMessage('Bebek bilgisi bulunamadı');
      return;
    }

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    bool success = false;

    try {
      if (_tabController.index == 0) {
        // Breastfeeding record
        if (widget.breastfeedingRecord == null) {
          // New breastfeeding record
          final record = bf.BreastfeedingTrackingModel(
            babyId: babyProvider.currentBaby!.id!,
            feedingDateTime: _feedingDateTime,
            durationMinutes: _durationMinutes,
            breastSide: _breastSide,
            feedingQuality: _feedingQuality,
            babyWasSatisfied: _babyWasSatisfied,
            hadDifficulty: _hadDifficulty,
            difficultyNote: _difficultyNoteController.text.isNotEmpty
                ? _difficultyNoteController.text
                : null,
            notes: _breastfeedingNotesController.text.isNotEmpty
                ? _breastfeedingNotesController.text
                : null,
            createdAt: DateTime.now(),
          );
          success = await healthProvider.addBreastfeedingRecord(record);
        } else {
          // Update existing breastfeeding record
          final updatedRecord = widget.breastfeedingRecord!.copyWith(
            feedingDateTime: _feedingDateTime,
            durationMinutes: _durationMinutes,
            breastSide: _breastSide,
            feedingQuality: _feedingQuality,
            babyWasSatisfied: _babyWasSatisfied,
            hadDifficulty: _hadDifficulty,
            difficultyNote: _difficultyNoteController.text.isNotEmpty
                ? _difficultyNoteController.text
                : null,
            notes: _breastfeedingNotesController.text.isNotEmpty
                ? _breastfeedingNotesController.text
                : null,
          );
          success = await healthProvider.updateBreastfeedingRecord(
            updatedRecord,
          );
        }
      } else {
        // Feeding record
        if (widget.feedingRecord == null) {
          // New feeding record
          final record = FeedingTrackingModel(
            babyId: babyProvider.currentBaby!.id!,
            feedingDateTime: _feedingDateTime,
            feedingType: _feedingType,
            amountMl: _amountMl,
            formulaType: _formulaType,
            solidFoods: _solidFoods.isNotEmpty ? _solidFoods : null,
            notes: _feedingNotesController.text.isNotEmpty
                ? _feedingNotesController.text
                : null,
            createdAt: DateTime.now(),
          );
          success = await healthProvider.addFeedingRecord(record);
        } else {
          // Update existing feeding record
          final updatedRecord = widget.feedingRecord!.copyWith(
            feedingDateTime: _feedingDateTime,
            feedingType: _feedingType,
            amountMl: _amountMl,
            formulaType: _formulaType,
            solidFoods: _solidFoods.isNotEmpty ? _solidFoods : null,
            notes: _feedingNotesController.text.isNotEmpty
                ? _feedingNotesController.text
                : null,
          );
          success = await healthProvider.updateFeedingRecord(updatedRecord);
        }
      }

      if (success) {
        _showMessage(
          widget.feedingRecord == null && widget.breastfeedingRecord == null
              ? 'Beslenme kaydı eklendi'
              : 'Beslenme kaydı güncellendi',
        );
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        _showMessage('Beslenme kaydı kaydedilirken hata oluştu');
      }
    } catch (e) {
      _showMessage('Hata: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getFeedingTypeDisplayName(FeedingType type) {
    switch (type) {
      case FeedingType.breastMilk:
        return 'Anne Sütü';
      case FeedingType.formula:
        return 'Mama';
      case FeedingType.solidFood:
        return 'Katı Gıda';
      case FeedingType.mixed:
        return 'Karma Beslenme';
    }
  }

  String _getFormulaTypeDisplayName(FormulaType type) {
    switch (type) {
      case FormulaType.cowBased:
        return 'İnek Sütü Bazlı';
      case FormulaType.goatBased:
        return 'Keçi Sütü Bazlı';
      case FormulaType.soyBased:
        return 'Soya Bazlı';
      case FormulaType.hydrolyzed:
        return 'Hidrolize';
      case FormulaType.lactoseFree:
        return 'Laktozsuz';
      case FormulaType.hypoallergenic:
        return 'Hipoalerjenik';
    }
  }

  String _getBreastfeedingQualityDisplayName(bf.BreastfeedingQuality quality) {
    switch (quality) {
      case bf.BreastfeedingQuality.excellent:
        return 'Mükemmel';
      case bf.BreastfeedingQuality.good:
        return 'İyi';
      case bf.BreastfeedingQuality.fair:
        return 'Orta';
      case bf.BreastfeedingQuality.poor:
        return 'Kötü';
      case bf.BreastfeedingQuality.difficult:
        return 'Zor';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
