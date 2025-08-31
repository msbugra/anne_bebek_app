import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/models/feeding_tracking_model.dart' hide BreastSide;
import '../../shared/models/breastfeeding_tracking_model.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';

class AddFeedingRecordScreen extends StatefulWidget {
  final FeedingTrackingModel? feedingRecord;
  final BreastfeedingTrackingModel? breastfeedingRecord;

  const AddFeedingRecordScreen({
    super.key,
    this.feedingRecord,
    this.breastfeedingRecord,
  });

  bool get isEditMode => feedingRecord != null || breastfeedingRecord != null;

  @override
  State<AddFeedingRecordScreen> createState() => _AddFeedingRecordScreenState();
}

class _AddFeedingRecordScreenState extends State<AddFeedingRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Common fields
  late DateTime _selectedDateTime;
  String? _notes;

  // Breastfeeding fields
  late int _durationMinutes;
  late BreastSide _breastSide;

  // Feeding fields
  late FeedingType _feedingType;
  double? _amountMl;
  final List<SolidFood> _solidFoods = [];
  final _solidFoodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.feedingRecord != null ? 1 : 0,
    );

    if (widget.isEditMode) {
      if (widget.breastfeedingRecord != null) {
        final record = widget.breastfeedingRecord!;
        _selectedDateTime = record.feedingDateTime;
        _durationMinutes = record.durationMinutes;
        _breastSide = record.breastSide;
        _notes = record.notes;
      } else if (widget.feedingRecord != null) {
        final record = widget.feedingRecord!;
        _selectedDateTime = record.feedingDateTime;
        _feedingType = record.feedingType;
        _amountMl = record.amountMl;
        if (record.solidFoods != null) {
          _solidFoods.addAll(record.solidFoods!);
        }
        _notes = record.notes;
      }
    } else {
      _selectedDateTime = DateTime.now();
      _durationMinutes = 15;
      _breastSide = BreastSide.left;
      _feedingType = FeedingType.formula;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _solidFoodController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addSolidFood() {
    if (_solidFoodController.text.isNotEmpty) {
      setState(() {
        _solidFoods.add(SolidFood(name: _solidFoodController.text));
        _solidFoodController.clear();
      });
    }
  }

  void _removeSolidFood(SolidFood food) {
    setState(() {
      _solidFoods.remove(food);
    });
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final babyProvider = Provider.of<BabyProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final babyId = babyProvider.currentBaby?.id;

    if (babyId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bebek bilgisi bulunamadı.')),
      );
      return;
    }

    bool success = false;
    if (_tabController.index == 0) {
      // Breastfeeding
      final recordToSave = BreastfeedingTrackingModel(
        id: widget.breastfeedingRecord?.id,
        babyId: babyId,
        feedingDateTime: _selectedDateTime,
        durationMinutes: _durationMinutes,
        breastSide: _breastSide,
        notes: _notes,
        createdAt: widget.isEditMode
            ? widget.breastfeedingRecord!.createdAt
            : DateTime.now(),
      );
      if (widget.isEditMode) {
        success = await healthProvider.updateBreastfeedingRecord(recordToSave);
      } else {
        success = await healthProvider.addBreastfeedingRecord(recordToSave);
      }
    } else {
      // Other feeding
      final recordToSave = FeedingTrackingModel(
        id: widget.feedingRecord?.id,
        babyId: babyId,
        feedingDateTime: _selectedDateTime,
        feedingType: _feedingType,
        amountMl: _feedingType == FeedingType.formula ? _amountMl : null,
        solidFoods: _feedingType == FeedingType.solidFood ? _solidFoods : null,
        notes: _notes,
        createdAt: widget.isEditMode
            ? widget.feedingRecord!.createdAt
            : DateTime.now(),
      );
      if (widget.isEditMode) {
        success = await healthProvider.updateFeedingRecord(recordToSave);
      } else {
        success = await healthProvider.addFeedingRecord(recordToSave);
      }
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt kaydedilirken bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Kaydı Düzenle' : 'Beslenme Kaydı Ekle',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Emzirme'),
            Tab(text: 'Mama / Katı Gıda'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [_buildBreastfeedingForm(), _buildFeedingForm()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveRecord,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildBreastfeedingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimePicker(),
          const SizedBox(height: 16),
          const Text('Emzirme Süresi (dakika)'),
          Slider(
            value: _durationMinutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            label: '$_durationMinutes dk',
            onChanged: (value) {
              setState(() {
                _durationMinutes = value.round();
              });
            },
          ),
          const SizedBox(height: 16),
          const Text('Meme Tarafı'),
          DropdownButtonFormField<BreastSide>(
            initialValue: _breastSide,
            items: BreastSide.values
                .map(
                  (side) => DropdownMenuItem(
                    value: side,
                    child: Text(side.toString().split('.').last),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _breastSide = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildFeedingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateTimePicker(),
          const SizedBox(height: 16),
          const Text('Beslenme Türü'),
          DropdownButtonFormField<FeedingType>(
            initialValue: _feedingType,
            items: [FeedingType.formula, FeedingType.solidFood]
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _feedingType = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          if (_feedingType == FeedingType.formula) _buildAmountField(),
          if (_feedingType == FeedingType.solidFood) _buildSolidFoodField(),
          const SizedBox(height: 16),
          _buildNotesField(),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Tarih ve Saat'),
      subtitle: Text(
        '${_selectedDateTime.toLocal().day}/${_selectedDateTime.toLocal().month}/${_selectedDateTime.toLocal().year} ${_selectedDateTime.toLocal().hour.toString().padLeft(2, '0')}:${_selectedDateTime.toLocal().minute.toString().padLeft(2, '0')}',
      ),
      onTap: _selectDateTime,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      initialValue: _amountMl?.toString(),
      decoration: const InputDecoration(
        labelText: 'Miktar (ml)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen miktar girin';
        }
        if (double.tryParse(value) == null) {
          return 'Geçerli bir sayı girin';
        }
        return null;
      },
      onSaved: (value) {
        _amountMl = double.tryParse(value!);
      },
    );
  }

  Widget _buildSolidFoodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _solidFoodController,
                decoration: const InputDecoration(
                  labelText: 'Katı Gıda Ekle',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: _addSolidFood),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _solidFoods
              .map(
                (food) => Chip(
                  label: Text(food.name),
                  onDeleted: () => _removeSolidFood(food),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      initialValue: _notes,
      decoration: const InputDecoration(
        labelText: 'Notlar',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onSaved: (value) {
        _notes = value;
      },
    );
  }
}
