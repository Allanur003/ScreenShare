import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'qr_scanner_screen.dart';
import 'rdp_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String? savedServerUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedServer();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedServer() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedServerUrl = prefs.getString('server_url');
    });
  }

  Future<void> _clearSavedServer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
    setState(() {
      savedServerUrl = null;
    });
  }

  void _navigateToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
  }

  void _navigateToViewer(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RDPViewerScreen(serverUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0f172a),
              const Color(0xFF1e293b),
              const Color(0xFF0f172a),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    _buildHeader(),
                    
                    const SizedBox(height: 60),
                    
                    // Main Action Buttons
                    _buildActionButtons(),
                    
                    const SizedBox(height: 40),
                    
                    // Saved Server Section
                    if (savedServerUrl != null) _buildSavedServer(),
                    
                    const Spacer(),
                    
                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366f1), Color(0xFFec4899)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366f1).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.computer,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6366f1), Color(0xFFec4899)],
          ).createShader(bounds),
          child: const Text(
            '⚡ AERO RDP',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Mobil Uzak Masaüstü',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF94a3b8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildGlassButton(
          icon: Icons.qr_code_scanner,
          title: 'QR Kod Tara',
          subtitle: 'Sunucuya hızlı bağlan',
          gradient: const LinearGradient(
            colors: [Color(0xFF6366f1), Color(0xFF818cf8)],
          ),
          onTap: _navigateToScanner,
        ),
        const SizedBox(height: 16),
        _buildGlassButton(
          icon: Icons.edit,
          title: 'Manuel Bağlan',
          subtitle: 'IP adresi gir',
          gradient: const LinearGradient(
            colors: [Color(0xFFec4899), Color(0xFFf472b6)],
          ),
          onTap: _showManualConnectDialog,
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94a3b8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF94a3b8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedServer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF06b6d4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF06b6d4).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.history,
            color: Color(0xFF06b6d4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Son Bağlantı',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94a3b8),
                  ),
                ),
                Text(
                  savedServerUrl!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Color(0xFF10b981)),
            onPressed: () => _navigateToViewer(savedServerUrl!),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFef4444)),
            onPressed: _clearSavedServer,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          'v1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748b),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Offline Çalışır • Güvenli Bağlantı',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF64748b),
          ),
        ),
      ],
    );
  }

  void _showManualConnectDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Manuel Bağlantı'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'http://192.168.1.100:5000',
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(context);
                _navigateToViewer(url);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
            ),
            child: const Text('Bağlan'),
          ),
        ],
      ),
    );
  }
}