// lib/pages/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // Untuk AppColors

class QRScannerPage extends StatefulWidget {
  // Parameter opsional untuk menentukan mode scanner
  final QRScannerMode mode;

  const QRScannerPage({
    super.key,
    this.mode = QRScannerMode.getInfo, // Default mode
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

// Enum untuk mode scanner
enum QRScannerMode {
  getInfo, // Untuk membuka browser atau menampilkan info
  addDevice, // Untuk menambahkan perangkat
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanCompleted = false;

  // Fungsi untuk menangani hasil scan
  void _handleBarcode(BarcodeCapture capture) {
    if (_isScanCompleted) return;

    setState(() {
      _isScanCompleted = true;
    });

    final String code = capture.barcodes.first.rawValue ?? "Tidak ada data";

    // Logika berdasarkan mode scanner
    if (widget.mode == QRScannerMode.addDevice) {
      // Jika modenya adalah 'addDevice', kembalikan data ke halaman sebelumnya
      Navigator.of(context).pop(code);
    } else {
      // Jika modenya adalah 'getInfo' (default)
      // Tampilkan dialog konfirmasi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("QR Code Terdeteksi"),
          content: Text("Data: $code"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              child: const Text("Tutup"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _launchURL(code);
              },
              child: const Text("Buka di Browser"),
            ),
          ],
        ),
      );
    }
  }

  // Fungsi untuk membuka URL
  Future<void> _launchURL(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) Navigator.of(context).pop(); // Kembali setelah membuka browser
    } else {
      // Jika bukan URL, tampilkan pesan error dan kembali
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data yang di-scan bukan URL yang valid.")),
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pindai QR Code"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),
          // Overlay untuk area scan
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.8), width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Tombol untuk kontrol kamera
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // --- PERBAIKAN DI SINI ---
                // Mengganti ValueListenableBuilder dengan IconButton biasa
                IconButton(
                  onPressed: () => _scannerController.toggleTorch(),
                  icon: const Icon(
                    Icons.flash_on, // Menggunakan ikon statis
                    color: Colors.white,
                    size: 32,
                  ),
                  tooltip: 'Senter',
                ),
                IconButton(
                  onPressed: () => _scannerController.switchCamera(),
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                  tooltip: 'Ganti Kamera',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
