import 'package:flutter/material.dart';
import '../../shared/models/growth_tracking_model.dart';

class DetailedAnalysisScreen extends StatelessWidget {
  final List<GrowthTrackingModel> measurements;

  const DetailedAnalysisScreen({super.key, required this.measurements});

  @override
  Widget build(BuildContext context) {
    final latestMeasurement = measurements.isNotEmpty
        ? measurements.first
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detaylı Büyüme Analizi')),
      body: latestMeasurement == null
          ? const Center(child: Text('Analiz için yeterli veri bulunmuyor.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallSummary(latestMeasurement),
                  const SizedBox(height: 24),
                  if (latestMeasurement.weight != null) ...[
                    _buildAnalysisSection(
                      context: context,
                      title: 'Kilo Analizi',
                      icon: Icons.monitor_weight,
                      color: Colors.blue,
                      assessment: latestMeasurement.growthAssessment,
                      percentile: latestMeasurement.weightPercentile,
                      recommendations: _getRecommendations(
                        'weight',
                        latestMeasurement.weightPercentile,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (latestMeasurement.height != null) ...[
                    _buildAnalysisSection(
                      context: context,
                      title: 'Boy Analizi',
                      icon: Icons.height,
                      color: Colors.green,
                      assessment: latestMeasurement.heightAssessment,
                      percentile: latestMeasurement.heightPercentile,
                      recommendations: _getRecommendations(
                        'height',
                        latestMeasurement.heightPercentile,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (latestMeasurement.headCircumference != null) ...[
                    _buildAnalysisSection(
                      context: context,
                      title: 'Baş Çevresi Analizi',
                      icon: Icons.face,
                      color: Colors.purple,
                      assessment: latestMeasurement.headCircumferenceAssessment,
                      percentile: latestMeasurement.headPercentile,
                      recommendations: _getRecommendations(
                        'head',
                        latestMeasurement.headPercentile,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildOverallSummary(GrowthTrackingModel latest) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genel Değerlendirme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bu rapor, bebeğinizin son ölçüm verilerine dayanarak genel bir büyüme analizi sunmaktadır. Unutmayın, her bebeğin gelişim süreci farklıdır ve bu rapor tıbbi bir teşhis niteliği taşımaz. Düzenli doktor kontrolleri en doğru bilgiyi sağlayacaktır.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String assessment,
    required double? percentile,
    required List<String> recommendations,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(128), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Mevcut Durum:', assessment),
            if (percentile != null)
              _buildInfoRow('Percentil Değeri:', 'P${percentile.toInt()}'),
            const SizedBox(height: 16),
            Text(
              'Öneriler:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[700],
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: Colors.green[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(color: Colors.grey[800]),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  List<String> _getRecommendations(String type, double? percentile) {
    if (percentile == null) {
      return [
        'Değerlendirme için percentil verisi gerekli.',
        'Lütfen doktorunuza danışın.',
      ];
    }

    if (type == 'weight') {
      if (percentile < 10) {
        return [
          'Beslenme uzmanına danışılması önerilir.',
          'Düzenli doktor kontrolü önemlidir.',
        ];
      }
      if (percentile > 90) {
        return [
          'Beslenme düzenine dikkat edilmelidir.',
          'Fiziksel aktivite artırılmalıdır.',
        ];
      }
    } else if (type == 'height') {
      if (percentile < 10) {
        return [
          'Gelişimin yakından takip edilmesi önemlidir.',
          'Doktorunuzla beslenme ve vitamin takviyelerini görüşün.',
        ];
      }
    } else if (type == 'head') {
      if (percentile < 3 || percentile > 97) {
        return [
          'Nörolojik gelişim açısından doktor kontrolü önemlidir.',
          'Bu durum her zaman bir soruna işaret etmez, ancak takip gerektirir.',
        ];
      }
    }

    return [
      'Normal gelişim seyrinde devam ediyor.',
      'Aylık doktor kontrollerini ve düzenli ölçümleri sürdürün.',
    ];
  }
}
