// lib/services/device_service.dart
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../models/device_model.dart';

// Kelas ini menyediakan data dummy seolah-olah dari database/API
class DeviceService {
  final Random _random = Random();

  // Fungsi untuk menghasilkan data grafik acak
  List<FlSpot> _generateChartData(double baseTemp) {
    return List.generate(24, (index) {
      final double temp = baseTemp + (_random.nextDouble() * 2) - 1.0;
      return FlSpot(index.toDouble(), double.parse(temp.toStringAsFixed(1)));
    });
  }

  // Fungsi utama untuk mendapatkan daftar semua perangkat
  List<Device> getDevices() {
    return [
      // Perangkat 1: Sesuai dengan "Main Freezer Unit A"
      Device(
        id: 'FRZ001',
        name: 'Main Freezer Unit A',
        sensorData: {
          'evaporator_temp': '-18.4°C',
          'product_temp': '-16.3°C',
          'ambient_temp': '25.1°C',
          'condenser_temp': '45.3°C',
          'humidity': '65.2%',
          'pressure': '1013.2hPa',
          'current': '8.5A',
          'voltage': '230.2V',
        },
        systemStatus: {
          'door_switch': 'Closed',
          'compressor': 'On',
          'fan_1': 'On',
          'defrost_heater': 'Off',
          'alarm': 'Inactive',
          'emergency_stop': 'Off',
          'high_pressure': 'Normal',
        },
        chartData: _generateChartData(-18.5),
      ),
      // Perangkat 2: Sesuai dengan "Backup Freezer Unit B"
      Device(
        id: 'FRZ002',
        name: 'Backup Freezer Unit B',
        sensorData: {
          'evaporator_temp': '-15.2°C',
          'product_temp': '-14.8°C',
          'ambient_temp': '28.5°C',
          'condenser_temp': '55.2°C',
          'humidity': '70.1%',
          'pressure': '1011.0hPa',
          'current': '9.1A',
          'voltage': '228.5V',
        },
        systemStatus: {
          'door_switch': 'Closed',
          'compressor': 'On',
          'fan_1': 'On',
          'defrost_heater': 'Off',
          'alarm': 'Active (High Temp)',
          'emergency_stop': 'Off',
          'high_pressure': 'Warning',
        },
        chartData: _generateChartData(-15.0),
      ),
      // Perangkat 3: Sesuai dengan "Temperature Monitor 1"
      Device(
        id: 'THM001',
        name: 'Temperature Monitor 1',
        sensorData: {
          'evaporator_temp': '5.3°C',
          'product_temp': '4.1°C',
          'ambient_temp': '26.0°C',
          'condenser_temp': '30.1°C',
          'humidity': '68.5%',
          'pressure': '1012.5hPa',
          'current': '0.5A',
          'voltage': '231.0V',
        },
        systemStatus: {
          'door_switch': 'Open',
          'compressor': 'Off',
          'fan_1': 'Off',
          'defrost_heater': 'On (Defrost Cycle)',
          'alarm': 'Inactive',
          'emergency_stop': 'Off',
          'high_pressure': 'Normal',
        },
        chartData: _generateChartData(5.0),
      ),
    ];
  }
}
