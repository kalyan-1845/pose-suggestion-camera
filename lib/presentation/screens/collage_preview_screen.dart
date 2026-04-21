import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/app_colors.dart';

class CollagePreviewScreen extends StatefulWidget {
  final List<String> imagePaths;

  const CollagePreviewScreen({super.key, required this.imagePaths});

  @override
  State<CollagePreviewScreen> createState() => _CollagePreviewScreenState();
}

class _CollagePreviewScreenState extends State<CollagePreviewScreen> {
  final GlobalKey _collageKey = GlobalKey();
  bool _isSaved = false;

  Future<void> _savePhoto() async {
    try {
      final boundary = _collageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'photobooth_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = '${directory.path}/$fileName';

      await File(savedPath).writeAsBytes(pngBytes);
      
      // Request permissions for Android 13+ and older
      if (Platform.isAndroid) {
        await Permission.storage.request();
        await Permission.photos.request();
      }

      await Gal.putImage(savedPath); // Save natively

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
                const SizedBox(width: 8),
                const Text('Photo Strip saved!'),
              ],
            ),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.accentRed),
        );
      }
    }
  }

  Future<void> _sharePhoto() async {
    try {
      final boundary = _collageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final savedPath = '${directory.path}/shared_photobooth.png';
      await File(savedPath).writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(savedPath)],
        text: 'My Photo Booth session! 📸✨',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  void _retake() {
    Navigator.of(context).pop();
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Collage Preview ──
          Center(
            child: InteractiveViewer( // Allow zooming
              child: RepaintBoundary(
                key: _collageKey,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white, // Classic polaroid border
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.75, // Standard portrait ratio
                        physics: const NeverScrollableScrollPhysics(),
                        children: widget.imagePaths.map((path) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(path),
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Watermark / Brand
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Pose AI \nPhoto Booth',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Top Gradient ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Top bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                const Text(
                  'Your Collage',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _goHome,
                  icon: const Icon(Icons.home, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),

          // ── Bottom controls ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 20, left: 20, right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.95), Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   _ActionButton(
                     icon: Icons.replay,
                     label: 'Retake',
                     color: AppColors.textSecondary,
                     onTap: _retake,
                   ),
                   _ActionButton(
                     icon: _isSaved ? Icons.check_circle : Icons.save_alt,
                     label: _isSaved ? 'Saved!' : 'Save',
                     color: AppColors.accentGreen,
                     onTap: _savePhoto,
                   ),
                   _ActionButton(
                     icon: Icons.share,
                     label: 'Share',
                     color: AppColors.accentCyan,
                     onTap: _sharePhoto,
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
