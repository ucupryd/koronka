// lib/pages/things_page.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/info_card.dart';

class ThingsPage extends StatelessWidget {
  const ThingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          InfoCard(
            title: 'Add New Device',
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter Device ID (e.g., FRZ003)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
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
          InfoCard(
            title: 'Connected Devices',
            child: Column(
              children: [
                _buildDeviceTile(
                  context,
                  'Main Freezer Unit A',
                  'Industrial Freezer',
                  'ID: FRZ001',
                  'Connected: 15/01/2024',
                  isOnline: true,
                ),
                const Divider(),
                 _buildDeviceTile(
                  context,
                  'Backup Freezer Unit B',
                  'Commercial Freezer',
                  'ID: FRZ002',
                  'Connected: 20/01/2024',
                  isOnline: true,
                ),
                const Divider(),
                 _buildDeviceTile(
                  context,
                  'Temperature Monitor 1',
                  'Temperature Sensor',
                  'ID: THM001',
                  'Connected: 01/02/2024',
                  isOnline: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Total Devices', '3'),
              _buildSummaryItem('Online', '2', color: AppColors.optimal),
              _buildSummaryItem('Offline', '1', color: AppColors.dangerous),
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET YANG DIPERBAIKI ---
  Widget _buildDeviceTile(
    BuildContext context,
    String title,
    String subtitle,
    String id,
    String connectionInfo, {
    required bool isOnline,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kolom 1: Ikon
          const Icon(Icons.ac_unit_outlined, size: 40, color: AppColors.primary),
          const SizedBox(width: 16),

          // Kolom 2: Informasi Teks (dibuat fleksibel)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PERBAIKAN: Menambahkan properti overflow dan maxLines
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
                    // PERBAIKAN: Membungkus ID dengan Flexible agar bisa terpotong
                    Flexible(
                      child: Text(
                        id,
                        style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(connectionInfo, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Kolom 3: Tombol Aksi
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.textLight), onPressed: () {}, tooltip: 'Edit'),
              IconButton(icon: Icon(Icons.delete_outline, color: AppColors.dangerous), onPressed: () {}, tooltip: 'Delete'),
            ],
          ),
        ],
      ),
    );
  }

   Widget _buildSummaryItem(String label, String value, {Color color = AppColors.textDark}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: AppColors.textLight)),
      ],
    );
  }
}
