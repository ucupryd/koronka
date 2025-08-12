// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // !!! PENTING: Ganti dengan alamat IP atau domain server backend Anda !!!
  static const String _baseUrl = 'http://192.168.100.30:8001'; // <-- GANTI INI
  final _storage = const FlutterSecureStorage();

  /// Mengirim permintaan login ke backend.
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: <String, String>{
          // Backend Anda menggunakan OAuth2PasswordRequestForm,
          // yang mengharapkan header 'application/x-www-form-urlencoded'.
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        // Body di-encode sebagai string form, bukan JSON.
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Jika login berhasil, simpan token akses dengan aman.
        await _storage.write(key: 'auth_token', value: data['access_token']);
        return true;
      } else {
        // Jika gagal, lemparkan error dengan pesan dari server.
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Login gagal.');
      }
    } on SocketException {
      // Error jika tidak ada koneksi internet atau server tidak bisa dijangkau.
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      // Melempar kembali error lainnya.
      rethrow;
    }
  }

  /// Menghapus token dari penyimpanan (logout).
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Memeriksa apakah ada token yang tersimpan.
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}
