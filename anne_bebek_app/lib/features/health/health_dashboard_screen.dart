import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/providers/baby_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/dashboard_card.dart';
import '../../shared/widgets/stat_card.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Sağlık Takibi',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1B23),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Büyüme'),
            Tab(text: 'Aşılar'),
            Tab(text: 'Genel'),
          ],
        ),
      ),
      body: Consumer<BabyProvider>(
        builder: (context, babyProvider, child) {
          if (!babyProvider.hasBabyProfile) {
            return _buildNoDataMessage();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildGrowthTab(babyProvider),
              _buildVaccinesTab(babyProvider),
              _buildGeneralHealthTab(babyProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHealthDataDialog(context);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Sağlık Verileri',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1B23),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bebeğinizin büyüme ve sağlık verilerini\ntakip etmek için profil oluşturun.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthTab(BabyProvider babyProvider) {
    final baby = babyProvider.currentBaby!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Stats
          _buildCurrentGrowthStats(baby),
          const SizedBox(height: 24),

          // Growth Chart
          _buildGrowthChart(),
          const SizedBox(height: 24),

          // WHO Percentiles
          _buildPercentileCard(baby),
          const SizedBox(height: 24),

          // Growth History
          _buildGrowthHistory(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCurrentGrowthStats(baby) {
    return DashboardCard(
      title: 'Mevcut Ölçümler',
      icon: Icons.straighten_rounded,
      child: Column(
        children: [
          Row(
            children: [
              if (baby.birthWeight != null)
                Expanded(
                  child: StatCard(
                    title: 'Kilo',
                    value: '${baby.birthWeight!.toStringAsFixed(1)} kg',
                    subtitle: 'Son ölçüm',
                    icon: Icons.monitor_weight_rounded,
                    color: Colors.blue,
                  ),
                ),
              if (baby.birthWeight != null && baby.birthHeight != null)
                const SizedBox(width: 12),
              if (baby.birthHeight != null)
                Expanded(
                  child: StatCard(
                    title: 'Boy',
                    value: '${baby.birthHeight!.toStringAsFixed(1)} cm',
                    subtitle: 'Son ölçüm',
                    icon: Icons.height_rounded,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (baby.birthHeadCircumference != null)
            StatCard(
              title: 'Baş Çevresi',
              value: '${baby.birthHeadCircumference!.toStringAsFixed(1)} cm',
              subtitle: 'Son ölçüm',
              icon: Icons.circle_rounded,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    return DashboardCard(
      title: 'Büyüme Grafiği',
      icon: Icons.analytics_rounded,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}A',
                      style: GoogleFonts.inter(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: GoogleFonts.inter(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3.5),
                  const FlSpot(1, 4.2),
                  const FlSpot(2, 5.1),
                  const FlSpot(3, 6.2),
                  const FlSpot(6, 7.8),
                  const FlSpot(12, 10.2),
                ],
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPercentileCard(baby) {
    return DashboardCard(
      title: 'WHO Persentil Değerleri',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          _buildPercentileRow('Kilo', '75', Colors.blue),
          const SizedBox(height: 8),
          _buildPercentileRow('Boy', '60', Colors.green),
          const SizedBox(height: 8),
          _buildPercentileRow('Baş Çevresi', '80', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildPercentileRow(String metric, String percentile, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            metric,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: double.parse(percentile) / 100,
            backgroundColor: color.withAlpha((255 * 0.1).round()),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentile%',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthHistory() {
    return DashboardCard(
      title: 'Ölçüm Geçmişi',
      icon: Icons.history_rounded,
      child: Column(
        children: [
          _buildHistoryItem('15 Ocak 2024', '4.2 kg', '52 cm', '38 cm'),
          _buildHistoryItem('15 Aralık 2023', '3.8 kg', '50 cm', '37 cm'),
          _buildHistoryItem('15 Kasım 2023', '3.5 kg', '48 cm', '36 cm'),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    String date,
    String weight,
    String height,
    String head,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1B23),
              ),
            ),
          ),
          Expanded(child: Text(weight, style: GoogleFonts.inter(fontSize: 11))),
          Expanded(child: Text(height, style: GoogleFonts.inter(fontSize: 11))),
          Expanded(child: Text(head, style: GoogleFonts.inter(fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildVaccinesTab(BabyProvider babyProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next Vaccines
          _buildNextVaccines(),
          const SizedBox(height: 24),

          // Vaccine Schedule
          _buildVaccineSchedule(),
          const SizedBox(height: 24),

          // Completed Vaccines
          _buildCompletedVaccines(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNextVaccines() {
    return DashboardCard(
      title: 'Yaklaşan Aşılar',
      icon: Icons.vaccines_rounded,
      iconColor: Colors.red,
      child: Column(
        children: [
          _buildVaccineItem('DaBT-İPA-Hib', '2. Doz', '15 Şubat 2024', true),
          _buildVaccineItem('Pnömokok', '2. Doz', '15 Şubat 2024', true),
          _buildVaccineItem('OPV', '2. Doz', '15 Şubat 2024', false),
        ],
      ),
    );
  }

  Widget _buildVaccineSchedule() {
    return DashboardCard(
      title: 'Aşı Takvimi',
      icon: Icons.calendar_today_rounded,
      child: Column(
        children: [
          _buildScheduleItem('2 Aylık', 'DaBT-İPA-Hib, Pnömokok, OPV', true),
          _buildScheduleItem('4 Aylık', 'DaBT-İPA-Hib, Pnömokok, OPV', false),
          _buildScheduleItem('6 Aylık', 'DaBT-İPA-Hib, Pnömokok, OPV', false),
          _buildScheduleItem('12 Aylık', 'MMR, Suçiçeği', false),
        ],
      ),
    );
  }

  Widget _buildCompletedVaccines() {
    return DashboardCard(
      title: 'Tamamlanan Aşılar',
      icon: Icons.check_circle_rounded,
      iconColor: Colors.green,
      child: Column(
        children: [
          _buildVaccineItem(
            'Hepatit B',
            '1. Doz',
            '10 Ocak 2024',
            false,
            completed: true,
          ),
          _buildVaccineItem(
            'BCG',
            '1. Doz',
            '10 Ocak 2024',
            false,
            completed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineItem(
    String name,
    String dose,
    String date,
    bool isUrgent, {
    bool completed = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withAlpha((255 * 0.05).round())
            : isUrgent
            ? Colors.red.withAlpha((255 * 0.05).round())
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed
              ? Colors.green.withAlpha((255 * 0.2).round())
              : isUrgent
              ? Colors.red.withAlpha((255 * 0.2).round())
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.vaccines_rounded,
            color: completed
                ? Colors.green
                : isUrgent
                ? Colors.red
                : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name - $dose',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Acil',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String age, String vaccines, bool current) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: current
            ? Theme.of(
                context,
              ).colorScheme.primary.withAlpha((255 * 0.05).round())
            : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: current
            ? Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha((255 * 0.2).round()),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              age,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: current ? FontWeight.w600 : FontWeight.w500,
                color: current
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF1A1B23),
              ),
            ),
          ),
          Expanded(
            child: Text(
              vaccines,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          if (current)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralHealthTab(BabyProvider babyProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sleep & Feeding Summary
          _buildSleepFeedingSummary(),
          const SizedBox(height: 24),

          // Health Reminders
          _buildHealthReminders(),
          const SizedBox(height: 24),

          // Quick Actions
          _buildHealthActions(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSleepFeedingSummary() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Son 24 Saat Uyku',
            value: '14.5h',
            subtitle: '8 uyku periyodu',
            icon: Icons.bedtime_rounded,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Günlük Beslenme',
            value: '8 kez',
            subtitle: 'Son: 2 saat önce',
            icon: Icons.restaurant_rounded,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthReminders() {
    return DashboardCard(
      title: 'Sağlık Hatırlatıcıları',
      icon: Icons.notifications_active_rounded,
      iconColor: Colors.amber,
      child: Column(
        children: [
          _buildReminderItem(
            'Boy ve kilo ölçümü',
            'Bu ay ölçüm zamanı geldi',
            Icons.straighten_rounded,
            Colors.blue,
          ),
          _buildReminderItem(
            'Doktor kontrolü',
            '2 hafta sonra randevu',
            Icons.medical_services_rounded,
            Colors.green,
          ),
          _buildReminderItem(
            'Vitamin D',
            'Günlük damla vermeyi unutma',
            Icons.water_drop_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderItem(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((255 * 0.2).round())),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1B23),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthActions() {
    return DashboardCard(
      title: 'Hızlı İşlemler',
      icon: Icons.flash_on_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Ölçüm Ekle',
                  Icons.add_chart_rounded,
                  Colors.blue,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Uyku Kaydet',
                  Icons.bedtime_rounded,
                  Colors.indigo,
                  () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Beslenme',
                  Icons.restaurant_rounded,
                  Colors.orange,
                  () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Not Ekle',
                  Icons.note_add_rounded,
                  Colors.green,
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha((255 * 0.2).round())),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1B23),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHealthDataDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sağlık Verisi Ekle',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1B23),
                ),
              ),
              const SizedBox(height: 24),
              _buildQuickAddOption(
                'Büyüme Ölçümü',
                Icons.straighten_rounded,
                Colors.blue,
              ),
              _buildQuickAddOption(
                'Uyku Kaydı',
                Icons.bedtime_rounded,
                Colors.indigo,
              ),
              _buildQuickAddOption(
                'Beslenme',
                Icons.restaurant_rounded,
                Colors.orange,
              ),
              _buildQuickAddOption(
                'Aşı Kaydı',
                Icons.vaccines_rounded,
                Colors.red,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddOption(String title, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
          // Navigate to specific add screen
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: color.withAlpha((255 * 0.1).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1B23),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
