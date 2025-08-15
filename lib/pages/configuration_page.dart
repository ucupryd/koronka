// lib/pages/configuration_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';

import '../main.dart';
import '../widgets/config_input_field.dart';
import '../widgets/info_card.dart';
import '../models/product_model.dart'; // Import Product model

// Ubah menjadi ConsumerStatefulWidget
class ConfigurationPage extends ConsumerStatefulWidget {
  const ConfigurationPage({super.key});

  @override
  ConsumerState<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends ConsumerState<ConfigurationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAutoCycleEnabled = true;

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
    // =======================================================================
    // !!! PERBAIKAN UTAMA DI SINI !!!
    // Dengarkan provider baru yang memberikan objek Product lengkap.
    // =======================================================================
    final selectedProduct = ref.watch(selectedProductProvider);

    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textLight,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: 'Auto Cycle'),
          Tab(text: 'Parameters'),
          Tab(text: 'Defrost'),
        ],
      ),
      // Tampilkan UI berdasarkan apakah ada produk yang dipilih
      body: selectedProduct == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Pilih sebuah perangkat di halaman Dashboard untuk melihat konfigurasi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textLight),
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                // Kirim seluruh objek Product ke setiap tab
                _buildAutoCycleTab(selectedProduct),
                _buildParametersTab(selectedProduct),
                _buildDefrostTab(selectedProduct),
              ],
            ),
    );
  }

  // Modifikasi setiap fungsi build tab untuk menerima objek Product
  Widget _buildAutoCycleTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoCard(
            // Gunakan nama produk dari objek
            title: 'Current Auto Cycle Status for "${product.name}"',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusColumn('Current Mode', 'Freezing'),
                    _buildStatusColumn('Time Remaining', '2h 59m'),
                    _buildStatusColumn('Target Temp', '-18°C'),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Cycle Progress'),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.337,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  alignment: Alignment.center,
                  // Tampilkan nama produk di sini juga jika perlu
                  child: Text('[Chart untuk: ${product.name}]'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Cycle Window Configuration',
            trailing: Switch(
              value: _isAutoCycleEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isAutoCycleEnabled = value;
                });
              },
            ),
            child: Column(
                children: [
                  ConfigInputField(label: 'Freezing Window Time', initialValue: '240', unit: 'minutes', description: 'Duration of freezing cycle (30-1440 min)'),
                  const SizedBox(height: 10),
                  ConfigInputField(label: 'Defrost Window Time', initialValue: '30', unit: 'minutes', description: 'Duration of defrost cycle (5-120 min)'),
                   const SizedBox(height: 10),
                  ConfigInputField(label: 'Target Temperature (Freezing)', initialValue: '-18', unit: '°C', description: 'Target temperature during freezing mode.'),
                   const SizedBox(height: 10),
                  ConfigInputField(label: 'Target Temperature (Defrost)', initialValue: '8', unit: '°C', description: 'Target temperature during defrost mode.'),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: InfoCard(
        title: 'Standard Parameters for "${product.name}"',
        child: Column(
          children: [
            ConfigInputField(label: 'F01 - Temperature setpoint', initialValue: '-18', unit: '°C', description: 'Target temperature for the cooling system.'),
            const SizedBox(height: 10),
            ConfigInputField(label: 'F02 - Hysteresis value', initialValue: '2', unit: '°C', description: 'Temperature difference for compressor cycling.'),
            // ... sisa parameter
          ],
        ),
      ),
    );
  }

  Widget _buildDefrostTab(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: InfoCard(
        title: 'Defrost Configuration for "${product.name}"',
        child: Column(
          children: [
             ConfigInputField(label: 'F07 - Defrost interval', initialValue: '360', unit: 'min', description: 'Time between automatic defrost cycles.'),
             // ... sisa parameter
          ],
        ),
      ),
    );
  }

   Widget _buildStatusColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
        ),
      ],
    );
  }
}
