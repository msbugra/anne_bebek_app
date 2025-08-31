import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/health_provider.dart';
import '../../shared/providers/baby_provider.dart';
import '../../shared/models/growth_tracking_model.dart';
import '../../shared/widgets/health_chart.dart';
import 'add_measurement_screen.dart';
import 'detailed_analysis_screen.dart';

class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({super.key});

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _showPercentiles = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGrowthData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGrowthData() async {
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
        title: const Text('Büyüme Takibi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showPercentiles ? Icons.show_chart : Icons.timeline),
            onPressed: () {
              setState(() => _showPercentiles = !_showPercentiles);
            },
            tooltip: _showPercentiles
                ? 'Percentilleri Gizle'
                : 'Percentilleri Göster',
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
                value: 'analysis',
                child: Row(
                  children: [
                    Icon(Icons.analytics),
                    SizedBox(width: 8),
                    Text('Detaylı Analiz'),
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
            Tab(text: 'Kilo'),
            Tab(text: 'Boy'),
            Tab(text: 'Baş Çevresi'),
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
              _buildWeightTab(healthProvider),
              _buildHeightTab(healthProvider),
              _buildHeadCircumferenceTab(healthProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeasurement,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryTab(HealthProvider healthProvider) {
    final measurements = healthProvider.growthMeasurements;
    final latestMeasurement = healthProvider.latestGrowthMeasurement;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    return RefreshIndicator(
      onRefresh: _loadGrowthData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (latestMeasurement != null) ...[
              _buildLatestMeasurementCard(latestMeasurement, baby),
              const SizedBox(height: 16),
            ],
            if (measurements.isNotEmpty) ...[
              _buildGrowthSummaryCards(measurements, baby),
              const SizedBox(height: 16),
              _buildGrowthChart(measurements, baby),
              const SizedBox(height: 16),
              _buildRecentMeasurements(measurements),
            ] else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTab(HealthProvider healthProvider) {
    final measurements = healthProvider.growthMeasurements;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGrowthData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HealthChart(
              chartType: HealthChartType.weight,
              data: measurements,
              title: 'Kilo Gelişimi',
              subtitle: 'WHO standartları ile karşılaştırma',
              showPercentiles: _showPercentiles,
              isMale: baby?.gender?.toString().contains('male') ?? true,
              primaryColor: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildWeightAnalysis(measurements, baby),
            const SizedBox(height: 16),
            _buildMeasurementsList(measurements, 'weight'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightTab(HealthProvider healthProvider) {
    final measurements = healthProvider.growthMeasurements;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGrowthData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HealthChart(
              chartType: HealthChartType.height,
              data: measurements,
              title: 'Boy Gelişimi',
              subtitle: 'WHO standartları ile karşılaştırma',
              showPercentiles: _showPercentiles,
              isMale: baby?.gender?.toString().contains('male') ?? true,
              primaryColor: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildHeightAnalysis(measurements, baby),
            const SizedBox(height: 16),
            _buildMeasurementsList(measurements, 'height'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadCircumferenceTab(HealthProvider healthProvider) {
    final measurements = healthProvider.growthMeasurements;
    final baby = Provider.of<BabyProvider>(context).currentBaby;

    if (measurements.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadGrowthData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HealthChart(
              chartType: HealthChartType.headCircumference,
              data: measurements,
              title: 'Baş Çevresi Gelişimi',
              subtitle: 'WHO standartları ile karşılaştırma',
              showPercentiles: _showPercentiles,
              isMale: baby?.gender?.toString().contains('male') ?? true,
              primaryColor: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildHeadCircumferenceAnalysis(measurements, baby),
            const SizedBox(height: 16),
            _buildMeasurementsList(measurements, 'head'),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestMeasurementCard(
    GrowthTrackingModel measurement,
    dynamic baby,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Son Ölçüm',
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
                      measurement.weightPercentile != null
                          ? 'P${measurement.weightPercentile!.toInt()}'
                          : null,
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
                      measurement.heightPercentile != null
                          ? 'P${measurement.heightPercentile!.toInt()}'
                          : null,
                      Colors.green,
                      Icons.height,
                    ),
                  ),
                ],
                if (measurement.headCircumference != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMeasurementItem(
                      'Baş Ç.',
                      '${measurement.headCircumference!.toStringAsFixed(1)} cm',
                      measurement.headPercentile != null
                          ? 'P${measurement.headPercentile!.toInt()}'
                          : null,
                      Colors.purple,
                      Icons.face,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Yaş: ${measurement.ageGroup}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(
    String title,
    String value,
    String? percentile,
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
          Text(title, style: TextStyle(fontSize: 12, color: color)),
          if (percentile != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                percentile,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrowthSummaryCards(
    List<GrowthTrackingModel> measurements,
    dynamic baby,
  ) {
    final latestMeasurement = measurements.first;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Büyüme',
            latestMeasurement.growthAssessment,
            _getAssessmentColor(latestMeasurement.growthAssessment),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Boy',
            latestMeasurement.heightAssessment,
            _getAssessmentColor(latestMeasurement.heightAssessment),
            Icons.height,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Baş Ç.',
            latestMeasurement.headCircumferenceAssessment,
            _getAssessmentColor(latestMeasurement.headCircumferenceAssessment),
            Icons.face,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String status,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((255 * 0.3).round())),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(
    List<GrowthTrackingModel> measurements,
    dynamic baby,
  ) {
    return HealthChart(
      chartType: HealthChartType.growth,
      data: measurements,
      title: 'Büyüme Gelişimi',
      subtitle: 'Tüm ölçümler',
      showPercentiles: _showPercentiles,
      isMale: baby?.gender?.toString().contains('male') ?? true,
      primaryColor: Colors.blue,
    );
  }

  Widget _buildWeightAnalysis(
    List<GrowthTrackingModel> measurements,
    dynamic baby,
  ) {
    final latestMeasurement = measurements.first;
    final growthVelocity = WHOGrowthCalculator.calculateGrowthVelocity(
      measurements,
      'weight',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kilo Analizi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalysisRow(
              'Mevcut Durum',
              latestMeasurement.growthAssessment,
            ),
            if (latestMeasurement.weightPercentile != null)
              _buildAnalysisRow(
                'Percentil',
                'P${latestMeasurement.weightPercentile!.toInt()}',
              ),
            _buildAnalysisRow(
              'Büyüme Hızı',
              '${(growthVelocity * 7).toStringAsFixed(1)} g/hafta',
            ),
            const SizedBox(height: 12),
            _buildRecommendations(latestMeasurement, 'weight'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightAnalysis(
    List<GrowthTrackingModel> measurements,
    dynamic baby,
  ) {
    final latestMeasurement = measurements.first;
    final growthVelocity = WHOGrowthCalculator.calculateGrowthVelocity(
      measurements,
      'height',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Boy Analizi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalysisRow(
              'Mevcut Durum',
              latestMeasurement.heightAssessment,
            ),
            if (latestMeasurement.heightPercentile != null)
              _buildAnalysisRow(
                'Percentil',
                'P${latestMeasurement.heightPercentile!.toInt()}',
              ),
            _buildAnalysisRow(
              'Büyüme Hızı',
              '${(growthVelocity * 30).toStringAsFixed(1)} cm/ay',
            ),
            const SizedBox(height: 12),
            _buildRecommendations(latestMeasurement, 'height'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadCircumferenceAnalysis(
    List<GrowthTrackingModel> measurements,
    dynamic baby,
  ) {
    final latestMeasurement = measurements.first;
    final growthVelocity = WHOGrowthCalculator.calculateGrowthVelocity(
      measurements,
      'head',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Baş Çevresi Analizi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalysisRow(
              'Mevcut Durum',
              latestMeasurement.headCircumferenceAssessment,
            ),
            if (latestMeasurement.headPercentile != null)
              _buildAnalysisRow(
                'Percentil',
                'P${latestMeasurement.headPercentile!.toInt()}',
              ),
            _buildAnalysisRow(
              'Büyüme Hızı',
              '${(growthVelocity * 30).toStringAsFixed(1)} cm/ay',
            ),
            const SizedBox(height: 12),
            _buildRecommendations(latestMeasurement, 'head'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(GrowthTrackingModel measurement, String type) {
    List<String> recommendations = [];

    // Simple recommendations based on percentiles
    if (type == 'weight' && measurement.weightPercentile != null) {
      if (measurement.weightPercentile! < 10) {
        recommendations.add('Beslenme uzmanına danışılması önerilir');
        recommendations.add('Düzenli doktor kontrolü önemlidir');
      } else if (measurement.weightPercentile! > 90) {
        recommendations.add('Beslenme düzenine dikkat edilmelidir');
        recommendations.add('Fiziksel aktivite artırılmalıdır');
      } else {
        recommendations.add('Normal gelişim gösteriyor');
        recommendations.add('Düzenli takip sürdürülmelidir');
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('Düzenli ölçüm takibi yapılmalıdır');
      recommendations.add('Doktor kontrollerini ihmal etmeyiniz');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, size: 16, color: Colors.orange[600]),
            const SizedBox(width: 6),
            Text(
              'Öneriler',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recommendations.map(
          (rec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: Colors.orange[600])),
                Expanded(
                  child: Text(rec, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMeasurements(List<GrowthTrackingModel> measurements) {
    final recentMeasurements = measurements.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Son Ölçümler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentMeasurements.map(
              (measurement) => _buildMeasurementRow(measurement),
            ),
            if (measurements.length > 5) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _showAllMeasurements(measurements),
                  child: const Text('Tüm Ölçümleri Gör'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(GrowthTrackingModel measurement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatDate(measurement.measurementDate),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (measurement.weight != null)
            Text(
              '${measurement.weight!.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 12),
            ),
          if (measurement.height != null) ...[
            const SizedBox(width: 8),
            Text(
              '${measurement.height!.toStringAsFixed(1)} cm',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (measurement.headCircumference != null) ...[
            const SizedBox(width: 8),
            Text(
              '${measurement.headCircumference!.toStringAsFixed(1)} cm',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementsList(
    List<GrowthTrackingModel> measurements,
    String type,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ölçüm Geçmişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...measurements.map((measurement) {
              double? value;
              double? percentile;
              String unit = '';

              switch (type) {
                case 'weight':
                  value = measurement.weight;
                  percentile = measurement.weightPercentile;
                  unit = 'kg';
                  break;
                case 'height':
                  value = measurement.height;
                  percentile = measurement.heightPercentile;
                  unit = 'cm';
                  break;
                case 'head':
                  value = measurement.headCircumference;
                  percentile = measurement.headPercentile;
                  unit = 'cm';
                  break;
              }

              if (value == null) return const SizedBox.shrink();

              return _buildDetailedMeasurementRow(
                measurement.measurementDate,
                value,
                percentile,
                unit,
                measurement,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMeasurementRow(
    DateTime date,
    double value,
    double? percentile,
    String unit,
    GrowthTrackingModel measurement,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ),
        title: Text(
          '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(date)),
            if (percentile != null)
              Text(
                'Percentil: P${percentile.toInt()}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMeasurementAction(value, measurement),
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
          Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz ölçüm kaydı bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk ölçümünüzü ekleyin',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMeasurement,
            icon: const Icon(Icons.add),
            label: const Text('Ölçüm Ekle'),
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
            onPressed: _loadGrowthData,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
          ),
        ],
      ),
    );
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportGrowthReport();
        break;
      case 'analysis':
        _showDetailedAnalysis();
        break;
    }
  }

  void _exportGrowthReport() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final measurements = healthProvider.growthMeasurements;

    if (measurements.isEmpty) {
      _showMessage('Dışa aktarılacak veri bulunmuyor.');
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add([
      "Tarih",
      "Yaş Grubu",
      "Kilo (kg)",
      "Kilo Percentil",
      "Boy (cm)",
      "Boy Percentil",
      "Baş Çevresi (cm)",
      "Baş Çevresi Percentil",
      "Büyüme Değerlendirmesi",
      "Boy Değerlendirmesi",
      "Baş Çevresi Değerlendirmesi",
    ]);

    for (var m in measurements) {
      rows.add([
        _formatDate(m.measurementDate),
        m.ageGroup,
        m.weight,
        m.weightPercentile,
        m.height,
        m.heightPercentile,
        m.headCircumference,
        m.headPercentile,
        m.growthAssessment,
        m.heightAssessment,
        m.headCircumferenceAssessment,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/growth_report.csv';
      final file = File(path);
      await file.writeAsString(csv);

      if (!mounted) return;
      _showMessage('Rapor başarıyla şuraya kaydedildi: $path');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Rapor kaydedilirken bir hata oluştu: $e');
    }
  }

  void _showDetailedAnalysis() {
    final measurements = Provider.of<HealthProvider>(
      context,
      listen: false,
    ).growthMeasurements;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailedAnalysisScreen(measurements: measurements),
      ),
    );
  }

  void _addMeasurement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMeasurementScreen()),
    ).then((_) => _loadGrowthData());
  }

  void _showAllMeasurements(List<GrowthTrackingModel> measurements) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tüm Ölçümler',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: measurements.length,
                itemBuilder: (context, index) {
                  final measurement = measurements[index];
                  return _buildMeasurementRow(measurement);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMeasurementAction(
    String action,
    GrowthTrackingModel measurement,
  ) async {
    switch (action) {
      case 'edit':
        _editMeasurement(measurement);
        break;
      case 'delete':
        await _deleteMeasurement(measurement);
        break;
    }
  }

  void _editMeasurement(GrowthTrackingModel measurement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMeasurementScreen(measurement: measurement),
      ),
    ).then((_) => _loadGrowthData());
  }

  Future<void> _deleteMeasurement(GrowthTrackingModel measurement) async {
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
      final success = await healthProvider.deleteGrowthMeasurement(
        measurement.id!.toString(),
      );

      if (!mounted) return;

      if (success) {
        _showMessage('Ölçüm kaydı silindi');
      } else {
        _showMessage('Ölçüm kaydı silinirken hata oluştu');
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
