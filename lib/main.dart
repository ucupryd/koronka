// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/dashboard_page.dart';
import 'pages/configuration_page.dart';
import 'pages/things_page.dart';
import 'pages/maintenance_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';

// --- PERUBAHAN WARNA DI SINI ---
class AppColors {
  // Warna utama diambil dari logo Anda
  static const Color primary = Color(0xFF0A546D); 
  // Versi yang sedikit lebih terang untuk gradient dan aksen
  static const Color primaryLight = Color(0xFF1B7F9E); 

  static const Color secondary = Color(0xFF00BCD4); // Cyan accent (bisa dipertahankan atau diubah)
  static const Color background = Color(0xFFF8FAFF);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF424242);
  static const Color textLight = Color(0xFF757575);
  static const Color accent = Color(0xFF2196F3);
  static const Color optimal = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color dangerous = Color(0xFFF44336);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}


void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const CoolingApp());
}

class CoolingApp extends StatelessWidget {
  const CoolingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koronka Cooling',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary, // Tema akan menggunakan warna primary baru
          brightness: Brightness.light,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, // Tombol juga akan menggunakan warna baru
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2), // Border fokus juga
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ... (Sisa kode main.dart Anda tetap sama)
// Class AuthGate, MainPage, dll. tidak perlu diubah.

/// Widget ini berfungsi sebagai "gerbang" otentikasi.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _checkLoginFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const MainPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  // Kunci untuk mengontrol Scaffold (terutama untuk membuka drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    ConfigurationPage(),
    ThingsPage(),
    MaintenancePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }
  
  Future<void> _performLogout() async {
    await AuthService().logout();
    if (mounted) {
      // Tutup drawer terlebih dahulu sebelum navigasi
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan kunci ke Scaffold
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            // PERUBAHAN: Menghapus judul halaman dari sini
            title: Row(
              children: [
                Container(
                  width: 120, 
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/logo/logo_horizontal.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // PERUBAHAN: Mengganti tombol logout dengan tombol profil
              IconButton(
                icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 28),
                tooltip: 'Profil Akun',
                onPressed: () {
                  // Membuka endDrawer saat tombol ditekan
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      // PERUBAHAN: Menambahkan endDrawer untuk profil
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Header untuk drawer
            const UserAccountsDrawerHeader(
              accountName: Text(
                "Admin", // Username sementara
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text("admin@koronka.id"), // Email sementara
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.background,
                child: Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
            // Opsi menu di drawer
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Info'),
              onTap: () {
                // TODO: Implementasi navigasi ke halaman Info
                Navigator.pop(context); // Tutup drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                // TODO: Implementasi navigasi ke halaman Settings
                Navigator.pop(context); // Tutup drawer
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.dangerous),
              title: const Text('Logout', style: TextStyle(color: AppColors.dangerous)),
              onTap: _performLogout,
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: IndexedStack(
          key: ValueKey(_selectedIndex),
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.tune_rounded, Icons.tune_outlined, 'Config'),
                _buildNavItem(2, Icons.devices_other_rounded, Icons.devices_other_outlined, 'Things'),
                _buildNavItem(3, Icons.build_rounded, Icons.build_outlined, 'Maintenance'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textLight,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
