import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/feeding_tracking_model.dart' hide BreastSide;
import '../../shared/models/breastfeeding_tracking_model.dart';
import 'add_feeding_record_screen.dart';
import 'feeding_timer_screen.dart';

class FeedingTrackingScreen extends StatefulWidget {
  const FeedingTrackingScreen({super.key});

  @override
  State<FeedingTrackingScreen> createState() => _FeedingTrackingScreenState();
}

class _FeedingTrackingScreenState extends State<FeedingTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedingData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedingData() async {
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
        title: const Text('Beslenme Takibi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: _startFeedingTimer,
            tooltip: 'Emzirme Timer',
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
                    Text('Beslenme Önerileri'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'Emzirme'),
            Tab(text: 'Mama/Katı Gıda'),
            Tab(text: 'Grafikler'),
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
              _buildBreastfeedingTab(healthProvider),
              _buildFeedingTab(healthProvider),
              _buildChartsTab(healthProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFeedingRecord,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryTab(HealthProvider healthProvider) {
    final feedingRecords = healthProvider.feedingRecords;
    final breastfeedingRecords = healthProvider.breastfeedingRecords;
    final feedingStatistics = healthProvider.feedingStatistics;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    return RefreshIndicator(
      onRefresh: _loadFeedingData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTodaySummaryCard(feedingRecords, breastfeedingRecords),
            const SizedBox(height: 16),
            if (feedingStatistics != null) ...[
              _buildFeedingStatisticsCards(feedingStatistics),
              const SizedBox(height: 16),
            ],
            if (feedingRecords.isNotEmpty ||
                breastfeedingRecords.isNotEmpty) ...[
              _buildFeedingPatternCard(
                feedingRecords,
                breastfeedingRecords,
                baby,
              ),
              const SizedBox(height: 16),
              _buildRecentFeedingRecords(feedingRecords, breastfeedingRecords),
            ] else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreastfeedingTab(HealthProvider healthProvider) {
    final breastfeedingRecords = healthProvider.breastfeedingRecords;

    if (breastfeedingRecords.isEmpty) {
      return _buildEmptyState('Henüz emzirme kaydı bulunmuyor');
    }

    return RefreshIndicator(
      onRefresh: _loadFeedingData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: breastfeedingRecords.length,
        itemBuilder: (context, index) {
          final record = breastfeedingRecords[index];
          return _buildBreastfeedingRecordCard(record);
        },
      ),
    );
  }

  Widget _buildFeedingTab(HealthProvider healthProvider) {
    final feedingRecords = healthProvider.feedingRecords;

    if (feedingRecords.isEmpty) {
      return _buildEmptyState('Henüz mama/katı gıda kaydı bulunmuyor');
    }

    return RefreshIndicator(
      onRefresh: _loadFeedingData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: feedingRecords.length,
        itemBuilder: (context, index) {
          final record = feedingRecords[index];
          return _buildFeedingRecordCard(record);
        },
      ),
    );
  }

  Widget _buildChartsTab(HealthProvider healthProvider) {
    final feedingRecords = healthProvider.feedingRecords;
    final breastfeedingRecords = healthProvider.breastfeedingRecords;

    if (feedingRecords.isEmpty && breastfeedingRecords.isEmpty) {
      return _buildEmptyState('Grafik için veri bulunmuyor');
    }

    return RefreshIndicator(
      onRefresh: _loadFeedingData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (breastfeedingRecords.isNotEmpty) ...[
              _buildBreastfeedingChart(breastfeedingRecords),
              const SizedBox(height: 16),
            ],
            if (feedingRecords.isNotEmpty) ...[
              _buildFeedingTypesChart(feedingRecords),
              const SizedBox(height: 16),
            ],
            _buildDailyFeedingChart(feedingRecords, breastfeedingRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummaryCard(
    List<FeedingTrackingModel> feedingRecords,
    List<BreastfeedingTrackingModel> breastfeedingRecords,
  ) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final todayFeeding = feedingRecords
        .where((f) => f.feedingDate == todayDate)
        .length;
    final todayBreastfeeding = breastfeedingRecords
        .where((b) => b.feedingDate == todayDate)
        .length;
    final totalTodayFeedings = todayFeeding + todayBreastfeeding;

    final todayBreastfeedingDuration = breastfeedingRecords
        .where((b) => b.feedingDate == todayDate)
        .fold(0, (sum, b) => sum + b.durationMinutes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Bugünkü Beslenme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(today),
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeedingInfoItem(
                    'Toplam Beslenme',
                    '$totalTodayFeedings',
                    Icons.restaurant,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeedingInfoItem(
                    'Emzirme',
                    '$todayBreastfeeding',
                    Icons.child_care,
                    Colors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFeedingInfoItem(
                    'Mama/Katı Gıda',
                    '$todayFeeding',
                    Icons.baby_changing_station,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeedingInfoItem(
                    'Emzirme Süresi',
                    '$todayBreastfeedingDuration dk',
                    Icons.timer,
                    Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingInfoItem(
    String title,
    String value,
    IconData icon,
    Color color,
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
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingStatisticsCards(Map<String, dynamic> statistics) {
    final feedingStats = statistics['feeding'] as Map<String, dynamic>? ?? {};
    final breastfeedingStats =
        statistics['breastfeeding'] as Map<String, dynamic>? ?? {};

    final avgDailyFeedings = feedingStats['avgDailyFeedings'] ?? 0.0;
    final avgDailyBreastfeedings =
        breastfeedingStats['avgDailyFeedings'] ?? 0.0;
    final avgBreastfeedingDuration =
        breastfeedingStats['avgDurationPerFeeding'] ?? 0.0;
    final successRate = breastfeedingStats['successRate'] ?? 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Günlük Ortalama',
                '${(avgDailyFeedings + avgDailyBreastfeedings).toStringAsFixed(1)}',
                Icons.restaurant,
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Emzirme Başarısı',
                '${successRate.toInt()}%',
                Icons.thumb_up,
                _getSuccessRateColor(successRate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Ort. Emzirme',
                '${avgBreastfeedingDuration.toInt()} dk',
                Icons.timer,
                Colors.indigo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                'Haftalık Toplam',
                '${(feedingStats['totalFeedings'] ?? 0)}',
                Icons.trending_up,
                Colors.purple,
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
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
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

  Widget _buildFeedingPatternCard(
    List<FeedingTrackingModel> feedingRecords,
    List<BreastfeedingTrackingModel> breastfeedingRecords,
    dynamic baby,
  ) {
    final baby = Provider.of<BabyProvider>(context).currentBaby;
    final babyAgeInDays = baby?.ageInDays ?? 0;

    final feedingRecommendations = FeedingAnalyzer.getFeedingRecommendations(
      feedingRecords,
      babyAgeInDays,
    );

    final breastfeedingRecommendations =
        BreastfeedingAnalyzer.getBreastfeedingRecommendations(
          breastfeedingRecords,
          babyAgeInDays,
        );

    final allRecommendations = [
      ...feedingRecommendations,
      ...breastfeedingRecommendations,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Beslenme Pattern Analizi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (allRecommendations.isNotEmpty) ...[
              ...allRecommendations
                  .take(5)
                  .map(
                    (rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: TextStyle(color: Colors.teal[600])),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ] else ...[
              Text(
                'Beslenme pattern analizi için daha fazla veri gerekli.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFeedingRecords(
    List<FeedingTrackingModel> feedingRecords,
    List<BreastfeedingTrackingModel> breastfeedingRecords,
  ) {
    // Combine and sort recent records
    List<Map<String, dynamic>> allRecords = [];

    // Add feeding records
    for (var record in feedingRecords.take(3)) {
      allRecords.add({
        'type': 'feeding',
        'record': record,
        'dateTime': record.feedingDateTime,
      });
    }

    // Add breastfeeding records
    for (var record in breastfeedingRecords.take(3)) {
      allRecords.add({
        'type': 'breastfeeding',
        'record': record,
        'dateTime': record.feedingDateTime,
      });
    }

    // Sort by date
    allRecords.sort(
      (a, b) =>
          (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime),
    );

    // Take only recent 5
    final recentRecords = allRecords.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Son Beslenme Kayıtları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentRecords.map((item) => _buildRecentFeedingItem(item)),
            if (allRecords.length > 5) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _showAllFeedingRecords(),
                  child: const Text('Tüm Kayıtları Gör'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFeedingItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final dateTime = item['dateTime'] as DateTime;

    IconData icon;
    Color color;
    String summary;

    if (type == 'breastfeeding') {
      final record = item['record'] as BreastfeedingTrackingModel;
      icon = Icons.child_care;
      color = Colors.pink;
      summary =
          'Emzirme - ${record.durationMinutes} dk (${record.breastSideDisplayName})';
    } else {
      final record = item['record'] as FeedingTrackingModel;
      icon = Icons.baby_changing_station;
      color = Colors.orange;
      summary = record.feedingSummary;
    }

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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatDateTime(dateTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreastfeedingRecordCard(BreastfeedingTrackingModel record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.withAlpha((255 * 0.1).round()),
          child: const Icon(Icons.child_care, color: Colors.pink),
        ),
        title: Text('Emzirme - ${record.durationText}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.breastSideDisplayName),
            Text(_formatDateTime(record.feedingDateTime)),
            if (record.feedingQuality != null)
              Text('Kalite: ${record.feedingQualityDisplayName}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBreastfeedingAction(value, record),
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

  Widget _buildFeedingRecordCard(FeedingTrackingModel record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFeedingTypeColor(
            record.feedingType,
          ).withAlpha((255 * 0.1).round()),
          child: Icon(
            _getFeedingTypeIcon(record.feedingType),
            color: _getFeedingTypeColor(record.feedingType),
          ),
        ),
        title: Text(record.feedingTypeDisplayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.feedingSummary),
            Text(_formatDateTime(record.feedingDateTime)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleFeedingAction(value, record),
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

  Widget _buildBreastfeedingChart(List<BreastfeedingTrackingModel> records) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emzirme Süresi Trendi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Emzirme grafiği yakında eklenecek',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingTypesChart(List<FeedingTrackingModel> records) {
    final typeCounts = <FeedingType, int>{};
    for (final record in records) {
      typeCounts[record.feedingType] =
          (typeCounts[record.feedingType] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beslenme Türü Dağılımı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: typeCounts.entries.map((entry) {
                  final type = entry.key;
                  final count = entry.value;
                  final total = typeCounts.values.reduce((a, b) => a + b);
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
                          color: _getFeedingTypeColor(type),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getFeedingTypeShortName(type),
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

  Widget _buildDailyFeedingChart(
    List<FeedingTrackingModel> feedingRecords,
    List<BreastfeedingTrackingModel> breastfeedingRecords,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Günlük Beslenme Sayıları',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Günlük beslenme grafiği yakında eklenecek',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState([String? message]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message ?? 'Henüz beslenme kaydı bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk beslenme kaydınızı ekleyin',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addFeedingRecord,
            icon: const Icon(Icons.add),
            label: const Text('Beslenme Ekle'),
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
            onPressed: _loadFeedingData,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
          ),
        ],
      ),
    );
  }

  Color _getFeedingTypeColor(FeedingType type) {
    switch (type) {
      case FeedingType.breastMilk:
        return Colors.pink;
      case FeedingType.formula:
        return Colors.orange;
      case FeedingType.solidFood:
        return Colors.green;
      case FeedingType.mixed:
        return Colors.purple;
    }
  }

  IconData _getFeedingTypeIcon(FeedingType type) {
    switch (type) {
      case FeedingType.breastMilk:
        return Icons.child_care;
      case FeedingType.formula:
        return Icons.baby_changing_station;
      case FeedingType.solidFood:
        return Icons.restaurant;
      case FeedingType.mixed:
        return Icons.local_dining;
    }
  }

  String _getFeedingTypeShortName(FeedingType type) {
    switch (type) {
      case FeedingType.breastMilk:
        return 'Anne S.';
      case FeedingType.formula:
        return 'Mama';
      case FeedingType.solidFood:
        return 'Katı';
      case FeedingType.mixed:
        return 'Karma';
    }
  }

  Color _getSuccessRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportFeedingReport();
        break;
      case 'recommendations':
        _showFeedingRecommendations();
        break;
    }
  }

  void _exportFeedingReport() {
    _showMessage('Rapor dışa aktarma özelliği yakında eklenecek');
  }

  void _showFeedingRecommendations() {
    final baby = Provider.of<BabyProvider>(context, listen: false).currentBaby;
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    if (baby == null) {
      _showMessage('Bebek bilgisi bulunamadı');
      return;
    }

    final feedingRecommendations = FeedingAnalyzer.getFeedingRecommendations(
      healthProvider.feedingRecords,
      baby.ageInDays,
    );

    final breastfeedingRecommendations =
        BreastfeedingAnalyzer.getBreastfeedingRecommendations(
          healthProvider.breastfeedingRecords,
          baby.ageInDays,
        );

    final allRecommendations = [
      ...feedingRecommendations,
      ...breastfeedingRecommendations,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Beslenme Önerileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (allRecommendations.isNotEmpty) ...[
              ...allRecommendations.map(
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
              const Text('Beslenme önerileri için daha fazla veri gerekli.'),
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

  void _startFeedingTimer() async {
    final babyId = Provider.of<BabyProvider>(
      context,
      listen: false,
    ).currentBaby?.id;
    if (babyId == null) {
      _showMessage('Lütfen önce bir bebek seçin.');
      return;
    }

    final result = await Navigator.push<Duration>(
      context,
      MaterialPageRoute(builder: (context) => const FeedingTimerScreen()),
    );

    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddFeedingRecordScreen(
            breastfeedingRecord: BreastfeedingTrackingModel(
              babyId: babyId,
              feedingDateTime: DateTime.now(),
              durationMinutes: result.inMinutes,
              breastSide: BreastSide.left, // Default value
              createdAt: DateTime.now(),
            ),
          ),
        ),
      ).then((_) => _loadFeedingData());
    }
  }

  void _addFeedingRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFeedingRecordScreen()),
    ).then((_) => _loadFeedingData());
  }

  void _showAllFeedingRecords() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tüm Beslenme Kayıtları',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Emzirme'),
                        Tab(text: 'Mama/Katı Gıda'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Consumer<HealthProvider>(
                            builder: (context, healthProvider, child) {
                              return ListView.builder(
                                itemCount:
                                    healthProvider.breastfeedingRecords.length,
                                itemBuilder: (context, index) {
                                  final record = healthProvider
                                      .breastfeedingRecords[index];
                                  return _buildBreastfeedingRecordCard(record);
                                },
                              );
                            },
                          ),
                          Consumer<HealthProvider>(
                            builder: (context, healthProvider, child) {
                              return ListView.builder(
                                itemCount: healthProvider.feedingRecords.length,
                                itemBuilder: (context, index) {
                                  final record =
                                      healthProvider.feedingRecords[index];
                                  return _buildFeedingRecordCard(record);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBreastfeedingAction(
    String action,
    BreastfeedingTrackingModel record,
  ) async {
    switch (action) {
      case 'edit':
        _editBreastfeedingRecord(record);
        break;
      case 'delete':
        await _deleteBreastfeedingRecord(record);
        break;
    }
  }

  void _editBreastfeedingRecord(BreastfeedingTrackingModel record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddFeedingRecordScreen(breastfeedingRecord: record),
      ),
    ).then((_) => _loadFeedingData());
  }

  Future<void> _deleteBreastfeedingRecord(
    BreastfeedingTrackingModel record,
  ) async {
    final confirm = await _showConfirmDialog(
      'Emzirme Kaydını Sil',
      'Bu emzirme kaydı silinsin mi? Bu işlem geri alınamaz.',
    );

    if (!mounted) return;

    if (confirm) {
      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      final success = await healthProvider.deleteBreastfeedingRecord(
        record.id!.toString(),
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Emzirme kaydı silindi');
      } else {
        _showMessage('Emzirme kaydı silinirken hata oluştu');
      }
    }
  }

  void _handleFeedingAction(String action, FeedingTrackingModel record) async {
    switch (action) {
      case 'edit':
        _editFeedingRecord(record);
        break;
      case 'delete':
        await _deleteFeedingRecord(record);
        break;
    }
  }

  void _editFeedingRecord(FeedingTrackingModel record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFeedingRecordScreen(feedingRecord: record),
      ),
    ).then((_) => _loadFeedingData());
  }

  Future<void> _deleteFeedingRecord(FeedingTrackingModel record) async {
    final confirm = await _showConfirmDialog(
      'Beslenme Kaydını Sil',
      'Bu beslenme kaydı silinsin mi? Bu işlem geri alınamaz.',
    );

    if (!mounted) return;

    if (confirm) {
      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      final success = await healthProvider.deleteFeedingRecord(
        record.id!.toString(),
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Beslenme kaydı silindi');
      } else {
        _showMessage('Beslenme kaydı silinirken hata oluştu');
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
