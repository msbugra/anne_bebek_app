import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/sleep_tracking_model.dart';
import '../../shared/widgets/health_chart.dart';

class SleepTrackingScreen extends StatefulWidget {
  const SleepTrackingScreen({super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSleepData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSleepData() async {
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
        title: const Text('Uyku Takibi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: _showSleepAnalysis,
            tooltip: 'Uyku Analizi',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Rapor İndir'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'recommendations',
                child: Row(
                  children: [
                    Icon(Icons.lightbulb),
                    SizedBox(width: 8),
                    Text('Uyku Önerileri'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'Grafikler'),
            Tab(text: 'Geçmiş'),
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

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(healthProvider),
              _buildChartsTab(healthProvider),
              _buildHistoryTab(healthProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSleepRecord,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryTab(HealthProvider healthProvider) {
    final sleepRecords = healthProvider.sleepRecords;
    final sleepStatistics = healthProvider.sleepStatistics;
    final latestSleepRecord = healthProvider.latestSleepRecord;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    return RefreshIndicator(
      onRefresh: _loadSleepData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (latestSleepRecord != null) ...[
              _buildLatestSleepCard(latestSleepRecord),
              const SizedBox(height: 16),
            ],
            if (sleepStatistics != null) ...[
              _buildSleepStatisticsCards(sleepStatistics),
              const SizedBox(height: 16),
            ],
            if (sleepRecords.isNotEmpty) ...[
              _buildSleepPatternCard(sleepRecords, baby),
              const SizedBox(height: 16),
              _buildRecentSleepRecords(sleepRecords),
            ] else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab(HealthProvider healthProvider) {
    final sleepRecords = healthProvider.sleepRecords;

    if (sleepRecords.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSleepData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HealthChart(
              chartType: HealthChartType.sleep,
              data: sleepRecords,
              title: 'Uyku Süresi Trendi',
              subtitle: 'Son 30 gün',
              primaryColor: Colors.indigo,
            ),
            const SizedBox(height: 16),
            _buildSleepQualityChart(sleepRecords),
            const SizedBox(height: 16),
            _buildSleepPatternsChart(sleepRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(HealthProvider healthProvider) {
    final sleepRecords = healthProvider.sleepRecords;

    if (sleepRecords.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadSleepData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sleepRecords.length,
        itemBuilder: (context, index) {
          final record = sleepRecords[index];
          return _buildSleepRecordCard(record);
        },
      ),
    );
  }

  Widget _buildLatestSleepCard(SleepTrackingModel sleepRecord) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                const Text(
                  'Son Uyku',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(sleepRecord.sleepDate),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSleepInfoItem(
                    'Yatış',
                    sleepRecord.bedTime ?? 'Belirtilmemiş',
                    Icons.bedtime,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSleepInfoItem(
                    'Kalkış',
                    sleepRecord.wakeTime ?? 'Belirtilmemiş',
                    Icons.wb_sunny,
                    Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSleepInfoItem(
                    'Toplam Uyku',
                    sleepRecord.totalSleepDurationMinutes != null
                        ? '${(sleepRecord.totalSleepDurationMinutes! / 60).toStringAsFixed(1)} saat'
                        : 'Bilinmiyor',
                    Icons.schedule,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSleepInfoItem(
                    'Kalite',
                    sleepRecord.sleepQualityDisplayName,
                    Icons.star,
                    _getSleepQualityColor(sleepRecord.sleepQuality),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Text(
                sleepRecord.sleepAssessment,
                style: TextStyle(
                  color: Colors.indigo[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildSleepStatisticsCards(Map<String, dynamic> statistics) {
    final avgTotalSleep = statistics['averageTotalSleep'] ?? 0.0;
    final avgNightSleep = statistics['averageNightSleep'] ?? 0.0;
    final avgNapTime = statistics['averageNapTime'] ?? 0.0;
    final consistencyScore = statistics['consistencyScore'] ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Ortalama Toplam',
                '${avgTotalSleep.toStringAsFixed(1)}h',
                Icons.schedule,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Gece Uykusu',
                '${avgNightSleep.toStringAsFixed(1)}h',
                Icons.nights_stay,
                Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Gündüz Uykusu',
                '${avgNapTime.toStringAsFixed(1)}h',
                Icons.brightness_5,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Tutarlılık',
                '${(consistencyScore * 100).toInt()}%',
                Icons.trending_up,
                _getConsistencyColor(consistencyScore),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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

  Widget _buildSleepPatternCard(
    List<SleepTrackingModel> sleepRecords,
    dynamic baby,
  ) {
    final baby = Provider.of<BabyProvider>(context).currentBaby;
    final babyAgeInDays = baby?.ageInDays ?? 0;
    final recommendations = SleepPatternAnalyzer.getSleepRecommendations(
      sleepRecords,
      babyAgeInDays,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Uyku Deseni Analizi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recommendations.isNotEmpty) ...[
              ...recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: TextStyle(color: Colors.teal[600])),
                      Expanded(
                        child: Text(rec, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Uyku pattern analizi için daha fazla veri gerekli.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepQualityChart(List<SleepTrackingModel> sleepRecords) {
    final qualityData = _getSleepQualityData(sleepRecords);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uyku Kalitesi Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: qualityData.entries.map((entry) {
                  final quality = entry.key;
                  final count = entry.value;
                  final total = qualityData.values.reduce((a, b) => a + b);
                  final percentage = total > 0 ? (count / total * 100) : 0.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 30,
                        height: percentage * 1.5,
                        decoration: BoxDecoration(
                          color: _getSleepQualityColor(quality),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getSleepQualityShortName(quality),
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepPatternsChart(List<SleepTrackingModel> sleepRecords) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uyku Saatleri Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Uyku saatleri grafiği yakında eklenecek',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSleepRecords(List<SleepTrackingModel> sleepRecords) {
    final recentRecords = sleepRecords.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Son Uyku Kayıtları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentRecords.map((record) => _buildSleepRecordSummary(record)),
            if (sleepRecords.length > 5) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _tabController.animateTo(2),
                  child: const Text('Tüm Kayıtları Gör'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepRecordSummary(SleepTrackingModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getSleepQualityColor(record.sleepQuality),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.sleepDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${record.bedTime ?? "?"} - ${record.wakeTime ?? "?"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (record.totalSleepDurationMinutes != null)
            Text(
              '${(record.totalSleepDurationMinutes! / 60).toStringAsFixed(1)}h',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildSleepRecordCard(SleepTrackingModel record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSleepQualityColor(
            record.sleepQuality,
          ).withOpacity(0.1),
          child: Icon(
            Icons.bedtime,
            color: _getSleepQualityColor(record.sleepQuality),
          ),
        ),
        title: Text(_formatDate(record.sleepDate)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (record.bedTime != null && record.wakeTime != null)
              Text('${record.bedTime} - ${record.wakeTime}'),
            if (record.totalSleepDurationMinutes != null)
              Text(
                'Toplam: ${(record.totalSleepDurationMinutes! / 60).toStringAsFixed(1)} saat',
              ),
            Text('Kalite: ${record.sleepQualityDisplayName}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleSleepRecordAction(value, record),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bedtime, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz uyku kaydı bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk uyku kaydınızı ekleyin',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addSleepRecord,
            icon: const Icon(Icons.add),
            label: const Text('Uyku Ekle'),
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
            onPressed: _loadSleepData,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
          ),
        ],
      ),
    );
  }

  Map<SleepQuality?, int> _getSleepQualityData(
    List<SleepTrackingModel> records,
  ) {
    Map<SleepQuality?, int> qualityData = {};

    for (final record in records) {
      qualityData[record.sleepQuality] =
          (qualityData[record.sleepQuality] ?? 0) + 1;
    }

    return qualityData;
  }

  Color _getSleepQualityColor(SleepQuality? quality) {
    switch (quality) {
      case SleepQuality.excellent:
        return Colors.green;
      case SleepQuality.good:
        return Colors.lightGreen;
      case SleepQuality.fair:
        return Colors.orange;
      case SleepQuality.poor:
        return Colors.red;
      case SleepQuality.veryPoor:
        return Colors.deepOrange;
      case null:
        return Colors.grey;
    }
  }

  String _getSleepQualityShortName(SleepQuality? quality) {
    switch (quality) {
      case SleepQuality.excellent:
        return 'Mük.';
      case SleepQuality.good:
        return 'İyi';
      case SleepQuality.fair:
        return 'Orta';
      case SleepQuality.poor:
        return 'Kötü';
      case SleepQuality.veryPoor:
        return 'Çok K.';
      case null:
        return 'Yok';
    }
  }

  Color _getConsistencyColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportSleepReport();
        break;
      case 'recommendations':
        _showSleepRecommendations();
        break;
    }
  }

  void _exportSleepReport() {
    _showMessage('Rapor dışa aktarma özelliği yakında eklenecek');
  }

  void _showSleepRecommendations() {
    final baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    if (baby == null) {
      _showMessage('Bebek bilgisi bulunamadı');
      return;
    }

    final recommendations = SleepPatternAnalyzer.getSleepRecommendations(
      healthProvider.sleepRecords,
      baby.ageInDays,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyku Önerileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recommendations.isNotEmpty) ...[
              ...recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Text('Uyku önerileri için daha fazla veri gerekli.'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSleepAnalysis() {
    // TODO: Implement detailed sleep analysis
    _showMessage('Detaylı uyku analizi yakında eklenecek');
  }

  void _addSleepRecord() {
    // TODO: Implement add sleep record
    _showMessage('Uyku kaydı ekleme özelliği yakında eklenecek');
  }

  void _handleSleepRecordAction(
    String action,
    SleepTrackingModel record,
  ) async {
    switch (action) {
      case 'edit':
        _editSleepRecord(record);
        break;
      case 'delete':
        await _deleteSleepRecord(record);
        break;
    }
  }

  void _editSleepRecord(SleepTrackingModel record) {
    // TODO: Implement edit sleep record
    _showMessage('Uyku kaydı düzenleme özelliği yakında eklenecek');
  }

  Future<void> _deleteSleepRecord(SleepTrackingModel record) async {
    final confirm = await _showConfirmDialog(
      'Uyku Kaydını Sil',
      'Bu uyku kaydı silinsin mi? Bu işlem geri alınamaz.',
    );

    if (confirm) {
      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      final success = await healthProvider.deleteSleepRecord(
        record.id!.toString(),
      );

      if (success) {
        _showMessage('Uyku kaydı silindi');
      } else {
        _showMessage('Uyku kaydı silinirken hata oluştu');
      }
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
