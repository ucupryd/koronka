// lib/pages/dashboard_page.dart
import 'dart:math'; // Import untuk generator angka acak
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart'; // Import package grafik
import '../main.dart';
import '../widgets/info_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Kartu Sensor Suhu ---
              InfoCard(
                title: 'Temperature Sensors (NTC)',
                child: GridView.count(
                  crossAxisCount: isMobile ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 1.2 : 1.3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildSensorReading(
                      'Evaporator Temp', '-18.4°C', CupertinoIcons.thermometer, AppColors.optimal, 'Optimal'),
                    _buildSensorReading(
                      'Product Temp', '-16.3°C', CupertinoIcons.cube_box, AppColors.optimal, 'Optimal'),
                    _buildSensorReading(
                      'Ambient Temp', '28.1°C', CupertinoIcons.sun_max, AppColors.warning, 'Warm'),
                    _buildSensorReading(
                      'Condenser Temp', '45.3°C', CupertinoIcons.wind, AppColors.optimal, 'Optimal'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Tata Letak Status Sistem yang Responsif ---
              _buildResponsiveSystemLayout(isMobile),

              const SizedBox(height: 16),

              // --- Kartu Riwayat Suhu dengan Grafik ---
              InfoCard(
                title: 'Evaporator Temperature History (24h)',
                child: SizedBox(
                  height: 180,
                  child: _buildTemperatureChart(), // Memanggil widget grafik
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET GRAFIK ---
  Widget _buildTemperatureChart() {
    final Random random = Random();
    final List<FlSpot> dummyData = List.generate(24, (index) {
      final double temp = -18.5 + (random.nextDouble() * 3) - 1.5;
      return FlSpot(index.toDouble(), double.parse(temp.toStringAsFixed(1)));
    });

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: FlTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipBorder: const BorderSide(color: AppColors.primary, width: 1),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final textStyle = TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                final tempText = '${touchedSpot.y}°C';
                final hourText = '\nJam ke-${touchedSpot.x.toInt()}';

                return LineTooltipItem(
                  '',
                  const TextStyle(),
                  children: [
                    TextSpan(text: tempText, style: textStyle),
                    TextSpan(
                      text: hourText,
                      style: textStyle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                  textAlign: TextAlign.center,
                );
              }).toList();
            },
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 4,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppColors.surfaceVariant,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return const FlLine(
              color: AppColors.surfaceVariant,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 6,
              getTitlesWidget: (value, meta) {
                String text;
                switch (value.toInt()) {
                  case 0: text = '24h ago'; break;
                  case 6: text = '18h'; break;
                  case 12: text = '12h'; break;
                  case 18: text = '6h'; break;
                  case 23: text = 'Now'; break;
                  default: return Container();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(text, style: const TextStyle(color: AppColors.textLight, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}°',
                  style: const TextStyle(color: AppColors.textLight, fontSize: 10),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: dummyData,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: 23,
        minY: -22,
        maxY: -16,
      ),
    );
  }

  // --- Widget-widget lainnya (tidak berubah) ---

  Widget _buildResponsiveSystemLayout(bool isMobile) {
    final environmentalCard = InfoCard(
      title: 'Environmental',
      child: Column(
        children: [
          _buildSystemStatusItem('Digital Sensor', '1.0', isNormal: true),
          const Divider(height: 24),
          _buildSystemStatusItem('Humidity', '65.2%', isNormal: true),
          const Divider(height: 24),
          _buildSystemStatusItem('Pressure', '1013.2hPa', isNormal: true),
        ],
      ),
    );

    final electricalCard = InfoCard(
      title: 'Electrical',
      child: Column(
        children: [
          _buildSystemStatusItem('Current', '8.5A', isNormal: true),
          const Divider(height: 24),
          _buildSystemStatusItem('Voltage', '230.2V', isNormal: true),
        ],
      ),
    );

    final systemStatusCard = InfoCard(
      title: 'System Status',
      child: Column(
        children: [
          _buildSimpleStatus('Door Switch', 'Closed', true),
          _buildSimpleStatus('Emergency Stop', 'Off', true),
          _buildSimpleStatus('High Pressure', 'Normal', true),
          const Divider(height: 16),
          _buildSimpleStatus('Compressor', 'On', true),
          _buildSimpleStatus('Fan 1', 'On', true),
          _buildSimpleStatus('Defrost Heater', 'Off', true),
          _buildSimpleStatus('Alarm', 'Inactive', false),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          systemStatusCard,
          const SizedBox(height: 16),
          environmentalCard,
          const SizedBox(height: 16),
          electricalCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              environmentalCard,
              const SizedBox(height: 16),
              electricalCard,
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: systemStatusCard,
        ),
      ],
    );
  }

  Widget _buildSensorReading(String name, String value, IconData icon, Color statusColor, String statusText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textMedium)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildSystemStatusItem(String title, String value, {bool isNormal = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),
          Text(
            value,
            style: TextStyle(
              color: isNormal ? AppColors.textDark : AppColors.dangerous,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatus(String title, String status, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),
          Row(
            children: [
              Icon(
                isActive ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
                color: isActive ? AppColors.optimal : AppColors.dangerous,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: isActive ? AppColors.textDark : AppColors.dangerous,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
