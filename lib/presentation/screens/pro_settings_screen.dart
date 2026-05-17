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
  String _watermarkStyle = 'leica';
  String _voiceStyle = 'director';
  String _auraStyle = 'cyan';
  String _filmRecipe = 'none';

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
      _watermarkStyle = prefs.getString('pro_watermark_style') ?? 'leica';
      _voiceStyle = prefs.getString('pro_voice_style') ?? 'director';
      _auraStyle = prefs.getString('pro_aura_style') ?? 'cyan';
      _filmRecipe = prefs.getString('pro_film_recipe') ?? 'none';
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
           ListTile(
              title: const Text('HUD Neon Aura Accent', style: TextStyle(color: Colors.white)),
              subtitle: Text(_auraStyle == 'cyan' ? 'Electric Arctic Cyan' : (_auraStyle == 'pink' ? 'Cyberpunk Neon Pink' : (_auraStyle == 'green' ? 'Toxic Acid Green' : 'Sunset Amber')), style: const TextStyle(color: AppColors.accentCyan)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              contentPadding: EdgeInsets.zero,
              onTap: _showAuraStyleSelector,
           ),

            const SizedBox(height: 20),
            _buildSectionTitle('AI VOICE COACH'),
            ListTile(
              title: const Text('Coach Personality', style: TextStyle(color: Colors.white)),
              subtitle: Text(_voiceStyle == 'director' ? 'High-Energy Photographer' : (_voiceStyle == 'yogi' ? 'Zen Meditation Guru' : 'Cybernetic HUD Robot'), style: const TextStyle(color: AppColors.accentCyan)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              contentPadding: EdgeInsets.zero,
              onTap: _showVoiceStyleSelector,
            ),

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
           ListTile(
               title: const Text('Cinematic Watermark', style: TextStyle(color: Colors.white)),
               subtitle: Text(_watermarkStyle == 'default' ? 'Classic Device' : _watermarkStyle.toUpperCase(), style: const TextStyle(color: AppColors.accentCyan)),
               trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
               contentPadding: EdgeInsets.zero,
               onTap: _showWatermarkStyleSelector,
             ),
             ListTile(
               title: const Text('Film Simulation Preset', style: TextStyle(color: Colors.white)),
               subtitle: Text(_filmRecipe == 'none' ? 'Standard Camera Profile' : (_filmRecipe == 'classic_chrome' ? 'Fujifilm Classic Chrome' : (_filmRecipe == 'portra_400' ? 'Kodak Portra 400 Gold' : 'Aura Noir High-Contrast Grain')), style: const TextStyle(color: AppColors.accentCyan)),
               trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
               contentPadding: EdgeInsets.zero,
               onTap: _showFilmRecipeSelector,
             ),
            _buildSwitchTile('Auto Brightness Boost', 'Max screen brightness when using camera.', _autoBrightness, (val) {
               setState(() => _autoBrightness = val);
               _saveSetting('pro_auto_bright', val);
            }),
            
            const SizedBox(height: 40),
            const Center(
               child: Text("Pose AI Camera Pro \n Version 1.0.0", 
                  textAlign: TextAlign.center, 
                  style: TextStyle(color: Colors.white54, fontSize: 12)
               ),
            )
        ],
      ),
    );
  }

  void _showWatermarkStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final styles = {
          'leica': 'Leica M11 Style (50mm f/0.95)',
          'hasselblad': 'Hasselblad X2D Style (38mm f/2.5)',
          'fuji': 'Fujifilm GFX Style (80mm f/1.7)',
          'default': 'Classic Device Watermark (Shot on Device)',
        };
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Cinematic Watermark',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...styles.entries.map((entry) {
                final isSelected = _watermarkStyle == entry.key;
                return ListTile(
                  title: Text(entry.value, style: TextStyle(color: isSelected ? AppColors.accentCyan : Colors.white70)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.accentCyan) : null,
                  onTap: () {
                    setState(() {
                      _watermarkStyle = entry.key;
                    });
                    _saveSetting('pro_watermark_style', entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showVoiceStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final styles = {
          'director': 'High-Energy Photographer Personality',
          'yogi': 'Zen Meditation Coach Personality',
          'cyber': 'Cybernetic HUD Robot Personality',
        };
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Coach Personality',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...styles.entries.map((entry) {
                final isSelected = _voiceStyle == entry.key;
                return ListTile(
                  title: Text(entry.value, style: TextStyle(color: isSelected ? AppColors.accentCyan : Colors.white70)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.accentCyan) : null,
                  onTap: () {
                    setState(() {
                      _voiceStyle = entry.key;
                    });
                    _saveSetting('pro_voice_style', entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAuraStyleSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final styles = {
          'cyan': 'Electric Arctic Cyan (Classic)',
          'pink': 'Cyberpunk Neon Pink (Vibrant)',
          'green': 'Toxic Acid Green (Radioactive)',
          'amber': 'Sunset Amber (Warm Glow)',
        };
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select HUD Neon Aura Accent',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...styles.entries.map((entry) {
                final isSelected = _auraStyle == entry.key;
                return ListTile(
                  title: Text(entry.value, style: TextStyle(color: isSelected ? AppColors.accentCyan : Colors.white70)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.accentCyan) : null,
                  onTap: () {
                    setState(() {
                      _auraStyle = entry.key;
                    });
                    _saveSetting('pro_aura_style', entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFilmRecipeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final recipes = {
          'none': 'Standard Camera Profile (Unprocessed)',
          'classic_chrome': 'Fujifilm Classic Chrome (Cool teal & soft greens)',
          'portra_400': 'Kodak Portra 400 Gold (Warm highlights & warm skin)',
          'noir_grain': 'Aura Noir High-Contrast (Beautiful silver analog grain)',
        };
        
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Film Simulation Recipe',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...recipes.entries.map((entry) {
                final isSelected = _filmRecipe == entry.key;
                return ListTile(
                  title: Text(entry.value, style: TextStyle(color: isSelected ? AppColors.accentCyan : Colors.white70)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.accentCyan) : null,
                  onTap: () {
                    setState(() {
                      _filmRecipe = entry.key;
                    });
                    _saveSetting('pro_film_recipe', entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
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
