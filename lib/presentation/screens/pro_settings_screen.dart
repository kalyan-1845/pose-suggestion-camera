import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class ProSettingsScreen extends StatefulWidget {
  const ProSettingsScreen({super.key});

  @override
  State<ProSettingsScreen> createState() => _ProSettingsScreenState();
}

class _ProSettingsScreenState extends State<ProSettingsScreen> {
  bool _gridEnabled = false;
  bool _mirrorFrontCamera = true;
  String _saveFormat = 'JPEG (High)';
  bool _autoBrightness = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gridEnabled = prefs.getBool('pro_grid') ?? false;
      _mirrorFrontCamera = prefs.getBool('pro_mirror') ?? true;
      _saveFormat = prefs.getString('pro_format') ?? 'JPEG (High)';
      _autoBrightness = prefs.getBool('pro_auto_bright') ?? true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pro Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
           _buildSectionTitle('VIEWFINDER'),
           _buildSwitchTile('Rule of Thirds Grid', 'Overlay a 3x3 grid for perfect composition.', _gridEnabled, (val) {
              setState(() => _gridEnabled = val);
              _saveSetting('pro_grid', val);
           }),
           _buildSwitchTile('Mirror Front Camera', 'Save selfies exactly as they appear on screen.', _mirrorFrontCamera, (val) {
              setState(() => _mirrorFrontCamera = val);
              _saveSetting('pro_mirror', val);
           }),

           const SizedBox(height: 20),
           _buildSectionTitle('CAPTURE QUALITY'),
           ListTile(
             title: const Text('Save Format', style: TextStyle(color: Colors.white)),
             subtitle: Text(_saveFormat, style: const TextStyle(color: AppColors.accentCyan)),
             trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
             onTap: () {
                // Show dropdown logic here for RAW / JPEG etc.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RAW capture requires native API upgrade!')));
             },
           ),
           _buildSwitchTile('Auto Brightness Boost', 'Max screen brightness when using camera.', _autoBrightness, (val) {
              setState(() => _autoBrightness = val);
              _saveSetting('pro_auto_bright', val);
           }),
           
           const SizedBox(height: 40),
           const Center(
              child: Text("Pose AI Camera Pro \\n Version 1.0.0", 
                 textAlign: TextAlign.center, 
                 style: TextStyle(color: Colors.white54, fontSize: 12)
              ),
           )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.accentCyan,
      contentPadding: EdgeInsets.zero,
    );
  }
}
