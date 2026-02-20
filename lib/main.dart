import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/rdp_viewer_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0f172a),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Lock orientation to portrait for better UX
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const AeroRDPApp());
}

class AeroRDPApp extends StatelessWidget {
  const AeroRDPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AERO RDP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366f1),
        scaffoldBackgroundColor: const Color(0xFF0f172a),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366f1),
          secondary: Color(0xFFec4899),
          surface: Color(0xFF1e293b),
          background: Color(0xFF0f172a),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}