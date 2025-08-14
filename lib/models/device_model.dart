// lib/models/device_model.dart
import 'package:fl_chart/fl_chart.dart';

// Model untuk merepresentasikan satu perangkat
class Device {
  final String id;
  final String name;
  final Map<String, String> sensorData;
  final Map<String, dynamic> systemStatus;
  final List<FlSpot> chartData;

  Device({
    required this.id,
    required this.name,
    required this.sensorData,
    required this.systemStatus,
    required this.chartData,
  });
}
