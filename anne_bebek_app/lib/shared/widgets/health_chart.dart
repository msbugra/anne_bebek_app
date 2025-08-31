import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/growth_tracking_model.dart';
import '../models/sleep_tracking_model.dart';

class HealthChart extends StatelessWidget {
  final HealthChartType chartType;
  final List<dynamic> data;
  final String title;
  final String? subtitle;
  final bool showPercentiles;
  final bool isMale;
  final Color primaryColor;
  final Color secondaryColor;

  const HealthChart({
    super.key,
    required this.chartType,
    required this.data,
    required this.title,
    this.subtitle,
    this.showPercentiles = false,
    this.isMale = true,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.pink,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: _buildChart()),
            if (showPercentiles) _buildPercentileLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case HealthChartType.growth:
        return _buildGrowthChart();
      case HealthChartType.sleep:
        return _buildSleepChart();
      case HealthChartType.feeding:
        return _buildFeedingChart();
      case HealthChartType.weight:
        return _buildWeightChart();
      case HealthChartType.height:
        return _buildHeightChart();
      case HealthChartType.headCircumference:
        return _buildHeadCircumferenceChart();
    }
  }

  Widget _buildGrowthChart() {
    if (data.isEmpty) return _buildEmptyChart();

    final measurements = data.cast<GrowthTrackingModel>();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: 1,
          verticalInterval: 30,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey[300], strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey[300], strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                final days = value.toInt();
                final months = (days / 30).round();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${months}ay',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}kg',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        lineBarsData: [
          // Weight line
          if (measurements.any((m) => m.weight != null))
            LineChartBarData(
              spots: measurements
                  .where((m) => m.weight != null)
                  .map((m) => FlSpot(m.ageInDays.toDouble(), m.weight!))
                  .toList(),
              isCurved: true,
              color: primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: primaryColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: primaryColor.withAlpha((255 * 0.1).round()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    if (data.isEmpty) return _buildEmptyChart();

    final measurements = data.cast<GrowthTrackingModel>();
    final weightData = measurements.where((m) => m.weight != null).toList();

    if (weightData.isEmpty) return _buildEmptyChart();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 30,
              getTitlesWidget: (value, meta) {
                final months = (value / 30).round();
                return Text(
                  '${months}ay',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)}kg',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: weightData
                .map((m) => FlSpot(m.ageInDays.toDouble(), m.weight!))
                .toList(),
            isCurved: true,
            color: primaryColor,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withAlpha((255 * 0.1).round()),
            ),
          ),
          // Percentile lines if enabled
          if (showPercentiles) ..._buildPercentileLines(weightData, 'weight'),
        ],
      ),
    );
  }

  Widget _buildHeightChart() {
    if (data.isEmpty) return _buildEmptyChart();

    final measurements = data.cast<GrowthTrackingModel>();
    final heightData = measurements.where((m) => m.height != null).toList();

    if (heightData.isEmpty) return _buildEmptyChart();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 30,
              getTitlesWidget: (value, meta) {
                final months = (value / 30).round();
                return Text(
                  '${months}ay',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}cm',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: heightData
                .map((m) => FlSpot(m.ageInDays.toDouble(), m.height!))
                .toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withAlpha((255 * 0.1).round()),
            ),
          ),
          // Percentile lines if enabled
          if (showPercentiles) ..._buildPercentileLines(heightData, 'height'),
        ],
      ),
    );
  }

  Widget _buildHeadCircumferenceChart() {
    if (data.isEmpty) return _buildEmptyChart();

    final measurements = data.cast<GrowthTrackingModel>();
    final headData = measurements
        .where((m) => m.headCircumference != null)
        .toList();

    if (headData.isEmpty) return _buildEmptyChart();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 30,
              getTitlesWidget: (value, meta) {
                final months = (value / 30).round();
                return Text(
                  '${months}ay',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}cm',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: headData
                .map(
                  (m) => FlSpot(m.ageInDays.toDouble(), m.headCircumference!),
                )
                .toList(),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withAlpha((255 * 0.1).round()),
            ),
          ),
          // Percentile lines if enabled
          if (showPercentiles) ..._buildPercentileLines(headData, 'head'),
        ],
      ),
    );
  }

  Widget _buildSleepChart() {
    if (data.isEmpty) return _buildEmptyChart();

    final sleepRecords = data.cast<SleepTrackingModel>();
    final validRecords = sleepRecords
        .where((record) => record.totalSleepDurationMinutes != null)
        .toList();

    if (validRecords.isEmpty) return _buildEmptyChart();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final date = DateTime.now().subtract(
                  Duration(days: (validRecords.length - 1 - value).toInt()),
                );
                return Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: validRecords
                .asMap()
                .entries
                .map(
                  (entry) => FlSpot(
                    entry.key.toDouble(),
                    (entry.value.totalSleepDurationMinutes! / 60),
                  ),
                )
                .toList(),
            isCurved: true,
            color: Colors.indigo,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.indigo.withAlpha((255 * 0.1).round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingChart() {
    if (data.isEmpty) return _buildEmptyChart();

    // Assume data contains daily feeding counts
    final feedingCounts = data.cast<Map<String, dynamic>>();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()} beslenme',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                return Text(
                  days[value.toInt() % 7],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: feedingCounts
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.value['count'] ?? 0).toDouble(),
                    color: primaryColor,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz veri bulunmuyor',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Veri ekledikten sonra grafik burada görünecek',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  List<LineChartBarData> _buildPercentileLines(
    List<GrowthTrackingModel> measurements,
    String measurementType,
  ) {
    if (measurements.isEmpty) return [];

    List<LineChartBarData> percentileLines = [];

    // P3, P50, P97 percentile lines
    final percentiles = [3, 50, 97];
    final colors = [Colors.red, Colors.green, Colors.red];

    for (int i = 0; i < percentiles.length; i++) {
      List<FlSpot> spots = [];

      for (var measurement in measurements) {
        double percentileValue = _getPercentileValue(
          measurement.ageInDays,
          percentiles[i],
          measurementType,
          isMale,
        );
        spots.add(FlSpot(measurement.ageInDays.toDouble(), percentileValue));
      }

      percentileLines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors[i].withAlpha((255 * 0.7).round()),
          barWidth: 2,
          dotData: FlDotData(show: false),
          dashArray: [5, 5],
        ),
      );
    }

    return percentileLines;
  }

  double _getPercentileValue(
    int ageInDays,
    int percentile,
    String measurementType,
    bool isMale,
  ) {
    // This is a simplified version - in real implementation, use WHO data
    switch (measurementType) {
      case 'weight':
        if (percentile == 50) {
          return 3.5 + (ageInDays / 30) * 0.6; // Approximate median weight
        }
        if (percentile == 3) return 2.5 + (ageInDays / 30) * 0.4;
        if (percentile == 97) return 4.5 + (ageInDays / 30) * 0.8;
        break;
      case 'height':
        if (percentile == 50) {
          return 50 + (ageInDays / 30) * 2.5; // Approximate median height
        }
        if (percentile == 3) return 46 + (ageInDays / 30) * 2.0;
        if (percentile == 97) return 54 + (ageInDays / 30) * 3.0;
        break;
      case 'head':
        if (percentile == 50) {
          return 35 +
              (ageInDays / 30) * 0.8; // Approximate median head circumference
        }
        if (percentile == 3) return 33 + (ageInDays / 30) * 0.6;
        if (percentile == 97) return 37 + (ageInDays / 30) * 1.0;
        break;
    }
    return 0;
  }

  Widget _buildPercentileLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('P3', Colors.red, 'Alt sınır'),
          _buildLegendItem('P50', Colors.green, 'Ortalama'),
          _buildLegendItem('P97', Colors.red, 'Üst sınır'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String description) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 2,
          color: color.withAlpha((255 * 0.7).round()),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}

enum HealthChartType {
  growth,
  weight,
  height,
  headCircumference,
  sleep,
  feeding,
}
