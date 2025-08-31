import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/models/sleep_tracking_model.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/providers/health_provider.dart';

class AddSleepRecordScreen extends StatefulWidget {
  final SleepTrackingModel? record;

  const AddSleepRecordScreen({super.key, this.record});

  bool get isEditMode => record != null;

  @override
  State<AddSleepRecordScreen> createState() => _AddSleepRecordScreenState();
}

class _AddSleepRecordScreenState extends State<AddSleepRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _sleepDate;
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  int? _napCount;
  int? _napDurationMinutes;
  SleepQuality? _sleepQuality;
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      final r = widget.record!;
      _sleepDate = r.sleepDate;
      _bedTime = _parseTimeOfDay(r.bedTime);
      _wakeTime = _parseTimeOfDay(r.wakeTime);
      _napCount = r.napCount;
      _napDurationMinutes = r.napDurationMinutes;
      _sleepQuality = r.sleepQuality;
      _notes = r.notes;
    } else {
      _sleepDate = DateTime.now();
      _sleepQuality = SleepQuality.fair;
    }
  }

  TimeOfDay? _parseTimeOfDay(String? hhmm) {
    if (hhmm == null) return null;
    try {
      final parts = hhmm.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  String? _formatTimeOfDay(TimeOfDay? t) {
    if (t == null) return null;
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _sleepDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    if (!mounted) return;
    setState(() => _sleepDate = date);
  }

  Future<void> _pickTime({required bool forBedTime}) async {
    final initial = forBedTime ? _bedTime : _wakeTime;
    final time = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );
    if (time == null) return;
    if (!mounted) return;
    setState(() {
      if (forBedTime) {
        _bedTime = time;
      } else {
        _wakeTime = time;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final babyProvider = Provider.of<BabyProvider>(context, listen: false);

    int? babyId;
    if (widget.isEditMode) {
      babyId = widget.record!.babyId;
    } else {
      babyId = babyProvider.currentBaby?.id;
    }

    if (babyId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bebek bilgisi bulunamadı.')),
      );
      return;
    }

    final record = SleepTrackingModel(
      id: widget.record?.id,
      babyId: babyId,
      sleepDate: _sleepDate,
      bedTime: _formatTimeOfDay(_bedTime),
      wakeTime: _formatTimeOfDay(_wakeTime),
      napCount: _napCount,
      napDurationMinutes: _napDurationMinutes,
      sleepQuality: _sleepQuality,
      notes: _notes,
      createdAt: widget.isEditMode ? widget.record!.createdAt : DateTime.now(),
    );

    bool ok;
    if (widget.isEditMode) {
      ok = await healthProvider.updateSleepRecord(record);
    } else {
      ok = await healthProvider.addSleepRecord(record);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt kaydedilirken hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Uyku Kaydını Düzenle' : 'Uyku Kaydı Ekle',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Tarih'),
                subtitle: Text(
                  '${_sleepDate.day.toString().padLeft(2, '0')}/${_sleepDate.month.toString().padLeft(2, '0')}/${_sleepDate.year}',
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.bedtime),
                      title: const Text('Yatış Saati'),
                      subtitle: Text(
                        _bedTime != null
                            ? _formatTimeOfDay(_bedTime)!
                            : 'Seçilmedi',
                      ),
                      onTap: () => _pickTime(forBedTime: true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.wb_sunny),
                      title: const Text('Kalkış Saati'),
                      subtitle: Text(
                        _wakeTime != null
                            ? _formatTimeOfDay(_wakeTime)!
                            : 'Seçilmedi',
                      ),
                      onTap: () => _pickTime(forBedTime: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _napCount != null
                          ? _napCount.toString()
                          : '',
                      decoration: const InputDecoration(
                        labelText: 'Gündüz Uykusu Sayısı',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) {
                        _napCount = (v == null || v.isEmpty)
                            ? null
                            : int.tryParse(v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _napDurationMinutes != null
                          ? _napDurationMinutes.toString()
                          : '',
                      decoration: const InputDecoration(
                        labelText: 'Gündüz Uyku Süresi (dk)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onSaved: (v) {
                        _napDurationMinutes = (v == null || v.isEmpty)
                            ? null
                            : int.tryParse(v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SleepQuality>(
                initialValue: _sleepQuality,
                decoration: const InputDecoration(
                  labelText: 'Uyku Kalitesi',
                  border: OutlineInputBorder(),
                ),
                items: SleepQuality.values
                    .map(
                      (q) => DropdownMenuItem(
                        value: q,
                        child: Text(_sleepQualityLabel(q)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _sleepQuality = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _notes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notlar',
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => _notes = v,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
    );
  }

  String _sleepQualityLabel(SleepQuality q) {
    switch (q) {
      case SleepQuality.excellent:
        return 'Mükemmel';
      case SleepQuality.good:
        return 'İyi';
      case SleepQuality.fair:
        return 'Orta';
      case SleepQuality.poor:
        return 'Kötü';
      case SleepQuality.veryPoor:
        return 'Çok Kötü';
    }
  }
}
