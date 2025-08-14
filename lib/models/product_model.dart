// lib/models/product_model.dart
import 'package:intl/intl.dart';

// Class untuk merepresentasikan data produk dari backend
class Product {
  final String id;
  final String serialNumber;
  final String name;
  final String productTypeName;
  final String status; // "online" or "offline"
  final DateTime installedAt;

  Product({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.productTypeName,
    required this.status,
    required this.installedAt,
  });

  // Factory constructor untuk membuat instance Product dari JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      serialNumber: json['serial_number'] ?? 'N/A',
      name: json['name'] ?? 'Unknown Device',
      productTypeName: json['product_type_name'] ?? 'N/A',
      status: json['status'] ?? 'offline',
      installedAt: DateTime.tryParse(json['installed_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper untuk format tanggal
  String get formattedInstalledAt {
    return DateFormat('dd/MM/yyyy').format(installedAt);
  }
}
