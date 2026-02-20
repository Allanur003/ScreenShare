import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

enum ViewMode { view, mouse }

class RDPViewerScreen extends StatefulWidget {
  final String serverUrl;

  const RDPViewerScreen({super.key, required this.serverUrl});

  @override
  State<RDPViewerScreen> createState() => _RDPViewerScreenState();
}

class _RDPViewerScreenState extends State<RDPViewerScreen> {
  ViewMode currentMode = ViewMode.view;
  double mouseX = 0.5;
  double mouseY = 0.5;
  String quality = '60';
  bool isConnected = false;
  Timer? _connectionCheckTimer;
  
  @override
  void initState() {
    super.initState();
    _saveServerUrl();
    _checkConnection();
    _startConnectionCheck();
    
    // Set immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _saveServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', widget.serverUrl);
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.serverUrl}/api/clients'),
      ).timeout(const Duration(seconds: 3));
      
      setState(() {
        isConnected = response.statusCode == 200;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }
  }

  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _checkConnection(),
    );
  }

  String get streamUrl => '${widget.serverUrl}/video_feed?q=$quality&t=${DateTime.now().millisecondsSinceEpoch}';

  void _setMode(ViewMode mode) {
    setState(() {
      currentMode = mode;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _sendMouseAction(String action, Map<String, dynamic> data) async {
    try {
      await http.post(
        Uri.parse('${widget.serverUrl}/api/mouse'),
        headers: {'Content-Type': 'application/json'},
        body: '{"action": "$action", ${data.entries.map((e) => '"${e.key}": ${e.value}').join(', ')}}',
      );
    } catch (e) {
      debugPrint('Mouse action error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Stream
          _buildVideoStream(),
          
          // Mode Toggle (Top)
          _buildModeToggle(),
          
          // Quality Badge
          _buildQualityBadge(),
          
          // Mouse Controls (Bottom)
          if (currentMode == ViewMode.mouse) _buildMouseControls(),
          
          // Status Bar (View Mode)
          if (currentMode == ViewMode.view) _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildVideoStream() {
    return Positioned.fill(
      bottom: currentMode == ViewMode.mouse ? 180 : 0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Image.network(
            streamUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6366f1),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Color(0xFFef4444),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bağlantı Hatası',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.serverUrl,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94a3b8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Täzeden synanyş'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366f1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeButton(
                  icon: Icons.visibility,
                  label: 'Görkez',
                  mode: ViewMode.view,
                ),
                const SizedBox(width: 5),
                _buildModeButton(
                  icon: Icons.mouse,
                  label: 'Kantrol',
                  mode: ViewMode.mouse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required ViewMode mode,
  }) {
    final isActive = currentMode == mode;
    
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFFec4899)],
                )
              : null,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFF94a3b8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF94a3b8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBadge() {
    return Positioned(
      top: 70,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isConnected ? const Color(0xFF10b981) : const Color(0xFFef4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              quality == '30' ? 'Tiz' : quality == '60' ? 'HD' : 'Pro',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMouseControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Column(
          children: [
            // Touch Area
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  final RenderBox box = context.findRenderObject() as RenderBox;
                  final localPosition = box.globalToLocal(details.globalPosition);
                  
                  setState(() {
                    mouseX = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                    mouseY = ((localPosition.dy - 80) / (box.size.height - 180)).clamp(0.0, 1.0);
                  });
                  
                  _sendMouseAction('move', {'x': mouseX, 'y': mouseY});
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '👆 Elin bilen syçany hereket etdirin',
                      style: TextStyle(
                        color: Color(0xFF94a3b8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Buttons Row
            Row(
              children: [
                // Left Click
                Expanded(
                  child: _buildMouseButton(
                    label: '🖱️ Sol Tık',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366f1), Color(0xFF818cf8)],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _sendMouseAction('click', {'button': 'left'});
                    },
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Right Click
                Expanded(
                  child: _buildMouseButton(
                    label: '🖱️ Sağ Tık',
                    gradient: const LinearGradient(
                      colors: [Color(0xFFec4899), Color(0xFFf472b6)],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _sendMouseAction('click', {'button': 'right'});
                    },
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Scroll Controls
                SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildScrollButton(
                          icon: Icons.arrow_upward,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _sendMouseAction('scroll', {'amount': 3});
                          },
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: _buildScrollButton(
                          icon: Icons.arrow_downward,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _sendMouseAction('scroll', {'amount': -3});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMouseButton({
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF06b6d4), Color(0xFF22d3ee)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFF10b981) : const Color(0xFFef4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? '' : 'Serwera baglanmady',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94a3b8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
