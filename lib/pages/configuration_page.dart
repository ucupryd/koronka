// lib/pages/configuration_page.dart
import 'package:flutter/material.dart';
import '../main.dart'; // Untuk AppColors
import '../widgets/config_input_field.dart';
import '../widgets/info_card.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> with SingleTickerProviderStateMixin {
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAutoCycleTab(),
          _buildParametersTab(),
          _buildDefrostTab(),
        ],
      ),
    );
  }

  Widget _buildAutoCycleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoCard(
            title: 'Current Auto Cycle Status',
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
                  child: const Text('[Placeholder for 24-Hour Temp Cycle Chart]'),
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

  Widget _buildParametersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoCard(
            title: 'Standard Parameters',
            child: Column(
              children: [
                ConfigInputField(label: 'F01 - Temperature setpoint', initialValue: '-18', unit: '°C', description: 'Target temperature for the cooling system.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F02 - Hysteresis value', initialValue: '2', unit: '°C', description: 'Temperature difference for compressor cycling.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F03 - High alarm threshold', initialValue: '-10', unit: '°C', description: 'Temperature threshold for high alarm.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F04 - Low alarm threshold', initialValue: '-25', unit: '°C', description: 'Temperature threshold for low alarm.'),
                 const SizedBox(height: 10),
                ConfigInputField(label: 'F05 - Alarm delay time', initialValue: '30', unit: 'min', description: 'Delay before triggering temperature alarms.'),
                 const SizedBox(height: 10),
                ConfigInputField(label: 'F06 - Compressor delay', initialValue: '3', unit: 'min', description: 'Minimum time between compressor starts.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefrostTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
           InfoCard(
            title: 'Defrost Configuration',
            child: Column(
              children: [
                 ConfigInputField(label: 'F07 - Defrost interval', initialValue: '360', unit: 'min', description: 'Time between automatic defrost cycles.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F08 - Max defrost duration', initialValue: '45', unit: 'min', description: 'Maximum time allowed for defrost cycle.'),
                 const SizedBox(height: 10),
                 ConfigInputField(label: 'F09 - Defrost stop temp', initialValue: '8', unit: '°C', description: 'Temperature to end defrost cycle.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F10 - Fan mode', initialValue: '1', unit: '', description: '0=Off during defrost, 1=On, 2=Delayed start.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F11 - Drip time after defrost', initialValue: '5', unit: 'min', description: 'Wait time after defrost before restarting.'),
                const SizedBox(height: 10),
                ConfigInputField(label: 'F12 - Door open alarm time', initialValue: '60', unit: 'sec', description: 'Time before door open alarm triggers.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // --- PERUBAHAN DI SINI ---
          InfoCard(
            title: 'Defrost Status Information',
            // Mengubah Row menjadi Column
            child: Column(
              children: [
                _buildStatusRow('Last Defrost', '2 hours ago'),
                const Divider(height: 24),
                _buildStatusRow('Next Scheduled', '4 hours'),
                const Divider(height: 24),
                _buildStatusRow('Defrost Cycles Today', '3'),
              ],
            ),
          ),
        ],
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

  // Widget helper baru untuk tata letak vertikal
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
