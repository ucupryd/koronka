// lib/pages/dashboard_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import '../widgets/info_card.dart';
import '../models/product_model.dart'; // Import model produk asli
import '../services/auth_service.dart'; // Import service API

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  late Future<List<Product>> _productsFuture;
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    // Memuat daftar produk dari backend
    _productsFuture = _authService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        // Saat loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Jika error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // Jika tidak ada data atau data kosong
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada perangkat yang dapat ditampilkan.'));
        }

        final products = snapshot.data!;
        // Inisialisasi perangkat terpilih jika belum ada
        _selectedProduct ??= products.first;

        // Mendapatkan data dummy dinamis berdasarkan produk yang dipilih
        final dummyDetails = _getDummyDetailsForProduct(_selectedProduct!);

        final bool isMobile = MediaQuery.of(context).size.width < 600;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeviceSelector(products),
              const SizedBox(height: 16),
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
                    _buildSensorReading('Evaporator Temp', dummyDetails['evaporator_temp']!, CupertinoIcons.thermometer),
                    _buildSensorReading('Product Temp', dummyDetails['product_temp']!, CupertinoIcons.cube_box),
                    _buildSensorReading('Ambient Temp', dummyDetails['ambient_temp']!, CupertinoIcons.sun_max),
                    _buildSensorReading('Condenser Temp', dummyDetails['condenser_temp']!, CupertinoIcons.wind),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildResponsiveSystemLayout(isMobile, dummyDetails),
              const SizedBox(height: 16),
              InfoCard(
                title: 'Evaporator Temperature History (24h)',
                child: SizedBox(
                  height: 180,
                  child: _buildTemperatureChart(dummyDetails['chartData']),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET-WIDGET BUILDER ---

  Widget _buildDeviceSelector(List<Product> products) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Product>(
          value: _selectedProduct,
          isExpanded: true,
          icon: const Icon(CupertinoIcons.chevron_down, color: AppColors.primary),
          onChanged: (Product? newValue) {
            setState(() {
              _selectedProduct = newValue!;
            });
          },
          items: products.map<DropdownMenuItem<Product>>((Product product) {
            return DropdownMenuItem<Product>(
              value: product,
              child: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textDark),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(List<FlSpot> chartData) {
    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          verticalInterval: 4,
          getDrawingVerticalLine: (value) => const FlLine(color: AppColors.surfaceVariant, strokeWidth: 1),
          drawHorizontalLine: true,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.surfaceVariant, strokeWidth: 1),
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
                  case 12: text = '12h'; break;
                  case 23: text = 'Now'; break;
                  default: return Container();
                }
                return SideTitleWidget(axisSide: meta.axisSide, space: 8.0, child: Text(text, style: const TextStyle(color: AppColors.textLight, fontSize: 10)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 5),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.primaryLight.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveSystemLayout(bool isMobile, Map<String, dynamic> details) {
    final environmentalCard = InfoCard(
      title: 'Environmental',
      child: Column(
        children: [
          _buildSystemStatusItem('Humidity', details['humidity']!),
          const Divider(height: 24),
          _buildSystemStatusItem('Pressure', details['pressure']!),
        ],
      ),
    );

    final electricalCard = InfoCard(
      title: 'Electrical',
      child: Column(
        children: [
          _buildSystemStatusItem('Current', details['current']!),
          const Divider(height: 24),
          _buildSystemStatusItem('Voltage', details['voltage']!),
        ],
      ),
    );

    final systemStatusCard = InfoCard(
      title: 'System Status',
      child: Column(
        children: [
          _buildSimpleStatus('Door Switch', details['door_switch']!, details['door_switch'] == 'Closed'),
          _buildSimpleStatus('Emergency Stop', details['emergency_stop']!, details['emergency_stop'] == 'Off'),
          _buildSimpleStatus('High Pressure', details['high_pressure']!, details['high_pressure'] == 'Normal'),
          const Divider(height: 16),
          _buildSimpleStatus('Compressor', details['compressor']!, details['compressor'] == 'On'),
          _buildSimpleStatus('Fan 1', details['fan_1']!, details['fan_1'] == 'On'),
          _buildSimpleStatus('Defrost Heater', details['defrost_heater']!, details['defrost_heater'] == 'Off'),
          _buildSimpleStatus('Alarm', details['alarm']!, details['alarm'] == 'Inactive'),
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

  Widget _buildSensorReading(String name, String value, IconData icon) {
    final double tempValue = double.tryParse(value.replaceAll('°C', '')) ?? 0.0;
    Color statusColor = AppColors.optimal;
    String statusText = 'Optimal';
    if (tempValue > -16) {
      statusColor = AppColors.warning;
      statusText = 'Warm';
    }
    if (tempValue > 0) {
      statusColor = AppColors.dangerous;
      statusText = 'High';
    }

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
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildSystemStatusItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textMedium)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
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
              Text(status, style: TextStyle(color: isActive ? AppColors.textDark : AppColors.dangerous, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // --- FUNGSI HELPER UNTUK DATA DUMMY DINAMIS ---
  Map<String, dynamic> _getDummyDetailsForProduct(Product product) {
    final Random random = Random(product.id.hashCode); // Seed acak berdasarkan ID unik produk
    double baseTemp = -18.5;
    if (product.status.toLowerCase() != 'online') {
      baseTemp = 5.0;
    } else if (product.name.toLowerCase().contains('backup')) {
      baseTemp = -15.0;
    }

    return {
      // Temperature Sensors
      'evaporator_temp': '${(baseTemp + random.nextDouble()).toStringAsFixed(1)}°C',
      'product_temp': '${(baseTemp - 1.5 + random.nextDouble()).toStringAsFixed(1)}°C',
      'ambient_temp': '${(25 + random.nextDouble() * 5).toStringAsFixed(1)}°C',
      'condenser_temp': '${(45 + random.nextDouble() * 10).toStringAsFixed(1)}°C',
      // Environmental
      'humidity': '${(65 + random.nextDouble() * 10).toStringAsFixed(1)}%',
      'pressure': '${(1010 + random.nextDouble() * 5).toStringAsFixed(1)}hPa',
      // Electrical
      'current': '${(8.0 + random.nextDouble() * 2).toStringAsFixed(1)}A',
      'voltage': '${(228 + random.nextDouble() * 4).toStringAsFixed(1)}V',
      // System Status
      'door_switch': product.status.toLowerCase() == 'online' ? 'Closed' : 'Open',
      'emergency_stop': 'Off',
      'high_pressure': baseTemp > -16 ? 'Warning' : 'Normal',
      'compressor': product.status.toLowerCase() == 'online' ? 'On' : 'Off',
      'fan_1': product.status.toLowerCase() == 'online' ? 'On' : 'Off',
      'defrost_heater': baseTemp > 0 ? 'On' : 'Off',
      'alarm': baseTemp > -16 ? 'Active' : 'Inactive',
      // Chart Data
      'chartData': List.generate(24, (index) {
        final double temp = baseTemp + (random.nextDouble() * 2) - 1.0;
        return FlSpot(index.toDouble(), double.parse(temp.toStringAsFixed(1)));
      }),
    };
  }
}
