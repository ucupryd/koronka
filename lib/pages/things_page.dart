// lib/pages/things_page.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/info_card.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';
import 'qr_scanner_page.dart'; // Import halaman scanner

class ThingsPage extends StatefulWidget {
  const ThingsPage({super.key});

  @override
  State<ThingsPage> createState() => _ThingsPageState();
}

class _ThingsPageState extends State<ThingsPage> {
  final AuthService _authService = AuthService();
  late Future<List<Product>> _productsFuture;
  final TextEditingController _deviceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _productsFuture = _authService.getProducts();
    });
  }

  // Fungsi untuk membuka scanner dari halaman ini
  void _openScannerForAdd() async {
    // Navigasi ke halaman scanner dan tunggu hasilnya
    final result = await Navigator.of(context).push<String>(MaterialPageRoute(
      builder: (context) => const QRScannerPage(mode: QRScannerMode.addDevice),
    ));

    // Jika ada hasil (pengguna tidak menekan tombol back), isi text field
    if (result != null && mounted) {
      setState(() {
        _deviceIdController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _loadProducts,
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            );
          }
          
          final products = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    InfoCard(
                      title: 'Add New Device',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _deviceIdController,
                              decoration: const InputDecoration(
                                labelText: 'Enter or Scan Device ID',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                          // Tombol scan baru
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 28),
                            onPressed: _openScannerForAdd,
                            tooltip: 'Scan Device ID',
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Implementasi logika register device dengan _deviceIdController.text
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (products.isNotEmpty)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Connected Devices',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ),
                      ),
                  ],
                );
              }

              final product = products[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InfoCard(
                  title: product.name,
                  child: _buildDeviceTile(context, product),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDeviceTile(BuildContext context, Product product) {
    final bool isOnline = product.status.toLowerCase() == 'online';
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.ac_unit_outlined, size: 40, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productTypeName,
                  style: const TextStyle(color: AppColors.textMedium),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.optimal : AppColors.dangerous,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isOnline ? 'ONLINE' : 'OFFLINE',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'ID: ${product.serialNumber}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Connected: ${product.formattedInstalledAt}',
                  style: const TextStyle(color: AppColors.textLight, fontSize: 12)
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textLight), onPressed: () {}, tooltip: 'Edit'),
              IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.dangerous), onPressed: () {}, tooltip: 'Delete'),
            ],
          ),
        ],
      ),
    );
  }
}
