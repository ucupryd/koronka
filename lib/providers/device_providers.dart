// lib/providers/device_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/auth_service.dart';

// Provider untuk mengambil daftar semua produk dari server
final productsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final authService = AuthService();
  return authService.getProducts();
});


// Provider untuk menyimpan ID perangkat yang dipilih
class SelectedDeviceNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void selectDevice(String? deviceId) {
    state = deviceId;
  }
}

final selectedDeviceProvider = NotifierProvider<SelectedDeviceNotifier, String?>(() {
  return SelectedDeviceNotifier();
});


// =======================================================================
// !!! PROVIDER BARU DI SINI !!!
// Provider ini akan secara otomatis memberikan objek Product lengkap
// dari perangkat yang sedang dipilih.
// =======================================================================
final selectedProductProvider = Provider.autoDispose<Product?>((ref) {
  // Dengarkan hasil dari pengambilan data produk
  final productsAsyncValue = ref.watch(productsProvider);
  // Dengarkan ID perangkat yang dipilih
  final selectedId = ref.watch(selectedDeviceProvider);

  // Jika data produk tersedia (tidak loading atau error)
  if (productsAsyncValue is AsyncData<List<Product>>) {
    final products = productsAsyncValue.value;
    if (products.isNotEmpty && selectedId != null) {
      // Cari dan kembalikan objek Product yang cocok dengan ID
      try {
        return products.firstWhere((p) => p.id == selectedId);
      } catch (e) {
        // Jika tidak ditemukan (kasus langka), kembalikan null
        return null;
      }
    }
  }
  
  // Jika data belum siap atau tidak ada pilihan, kembalikan null
  return null;
});
