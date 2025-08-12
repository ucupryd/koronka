// lib/pages/maintenance_page.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/info_card.dart';
import '../widgets/status_chip.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              StatusChip(label: 'Optimal', count: 3, color: AppColors.optimal),
              SizedBox(width: 8),
              StatusChip(label: 'Warning', count: 2, color: AppColors.warning),
              SizedBox(width: 8),
              StatusChip(label: 'Dangerous', count: 1, color: AppColors.dangerous),
            ],
          ),
          const SizedBox(height: 16),
          // Device Location Map & Device Info side-by-side
          InfoCard(
            title: 'Device Location Map',
            child: Container(
              height: 200,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      // Gunakan gambar peta sebagai placeholder
                      image: NetworkImage(
                          'https://i.stack.imgur.com/x5M5g.png'),
                      fit: BoxFit.cover)),
              child: const Text('Map Placeholder',
                  style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.black45,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Device Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Freezer Complex Makassar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('WARNING',
                            style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
                const Text('ID: KRN-005',
                    style: TextStyle(color: AppColors.textLight)),
                const SizedBox(height: 8),
                const Text('Location:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Lat: -5.1477°, Lng: 119.4327°'),
                const SizedBox(height: 8),
                const Text('Maintenance Schedule:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Last: 2024-07-01'),
                const Text('Next: 2024-08-01'),
                 const SizedBox(height: 8),
                const Text('Current Issues:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('- Door seal inspection needed'),
                 const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Schedule Maintenance'),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

               InfoCard(
            title: 'All Devices', // <-- PINDAHKAN JUDUL KE SINI
            child: Column(
              children: [
                _buildDeviceListItem('Freezer Unit Jakarta', 'KRN-001',
                    'Next: 2024-09-15', 'optimal'),
                const Divider(),
                _buildDeviceListItem('Cooling System Surabaya', 'KRN-002',
                    'Next: 2024-08-20', 'warning'),
                const Divider(),
                _buildDeviceListItem('Refrigeration Bandung', 'KRN-003',
                    'Next: 2024-07-10', 'warning'),
                const Divider(),
                _buildDeviceListItem('Cold Storage Medan', 'KRN-004',
                    'Next: 2024-08-25', 'dangerous'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDeviceListItem(
      String name, String id, String nextDate, String status) {
    Color statusColor;
    switch (status) {
      case 'warning':
        statusColor = AppColors.warning;
        break;
      case 'dangerous':
        statusColor = AppColors.dangerous;
        break;
      default:
        statusColor = AppColors.optimal;
    }
    return ListTile(
      title: Text(name),
      subtitle: Text('$id\n$nextDate'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(
              color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      isThreeLine: true,
    );
  }
}