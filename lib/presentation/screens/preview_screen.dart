import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pdf/widgets.dart' as pw;
import 'wifi_share_screen.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/magic_enhance_service.dart';
import 'package:image/image.dart' as img;

/// Preview screen for captured photo with save/share/retake options
class PreviewScreen extends StatefulWidget {
  final String imagePath;
  final String templateId;
  final String templateName;
  final double matchScore;
  final bool isFrontCamera;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.templateId,
    required this.templateName,
    required this.matchScore,
    required this.isFrontCamera,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  double _brightness = 0.0;
  double _contrast = 1.0;
  bool _isSaved = false;
  bool _isMagicRemoverMode = false;
  bool _isProcessingRemoval = false;
  late String _currentImagePath;
  final List<String> _editHistory = []; // For Undo functionality

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  Future<void> _savePhoto() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'pose_${widget.templateId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${directory.path}/$fileName';

      await File(_currentImagePath).copy(savedPath);

      // Request permissions for Android 13+ and older
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        // For Android 13+ (API 33+)
        await Permission.photos.request();
      }

      // Save natively to System Gallery using Gal package
      await Gal.putImage(_currentImagePath);

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 20),
                const SizedBox(width: 8),
                const Text('Photo saved!'),
              ],
            ),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    }
  }

  Future<void> _sharePhoto() async {
    try {
      await Share.shareXFiles(
        [XFile(_currentImagePath)],
        text: 'Captured with Pose AI Camera! 📸 Pose: ${widget.templateName}',
      );
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  void _retake() {
    Navigator.of(context).pop();
  }

  Future<void> _openProEditor() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.file(
          File(_currentImagePath),
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (bytes) async {
              final newPath = '${(await getTemporaryDirectory()).path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
              final file = await File(newPath).writeAsBytes(bytes);
              
              // AUTO-SAVE to gallery immediately for "Pro" experience
              await Gal.putImage(file.path);

              setState(() {
                 _currentImagePath = file.path;
                 _isSaved = true;
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edits saved to gallery!'))
                );
              }
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveAsPdf() async {
    try {
       final pdf = pw.Document();
       final image = pw.MemoryImage(File(_currentImagePath).readAsBytesSync());
       pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
       
       final dir = await getApplicationDocumentsDirectory();
       final file = File('\${dir.path}/document_\${DateTime.now().millisecondsSinceEpoch}.pdf');
       await file.writeAsBytes(await pdf.save());

       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved as Lossless PDF Document!')));
       }
    } catch (e) {
       debugPrint('PDF Error: \$e');
    }
  }

  void _shareViaQR() {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (_) => WifiShareScreen(imagePathToShare: _currentImagePath)),
     );
  }

  void _magicRemove() {
    setState(() {
      _isMagicRemoverMode = !_isMagicRemoverMode;
    });
    
    if (_isMagicRemoverMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI MAGIC REMOVER: Tap an object to erase it.'),
          duration: Duration(seconds: 4),
        )
      );
    }
  }

  Future<void> _tapToErase(TapDownDetails details) async {
    if (!_isMagicRemoverMode || _isProcessingRemoval) return;
    
    setState(() => _isProcessingRemoval = true);
    
    try {
      final bytes = await File(_currentImagePath).readAsBytes();
      
      // Get logical to local pixel mapping
      // This is a simplified mapping assuming contain fit
      final size = MediaQuery.of(context).size;
      final image = img.decodeImage(bytes);
      if (image == null) return;
      
      final tapX = (details.localPosition.dx / size.width * image.width).toInt();
      final tapY = (details.localPosition.dy / size.height * image.height).toInt();

      final processedBytes = await MagicEnhanceService.heal(bytes, tapX, tapY);
      
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/healed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(path).writeAsBytes(processedBytes);
      
      // Add previous path to history before updating
      _editHistory.add(_currentImagePath);

      setState(() {
        _currentImagePath = path;
        _isProcessingRemoval = false;
      });
      
      // AUTO-SAVE HEALED PHOTO TO GALLERY (Flagship behavior)
      await Gal.putImage(path);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Object erased and saved to Gallery!'))
      );
    } catch (e) {
      debugPrint('Heal error: $e');
      setState(() => _isProcessingRemoval = false);
    }
  }

  Future<void> _shareAsDocument() async {
    try {
      final file = File(_currentImagePath);
      final xFile = XFile(file.path, mimeType: 'application/octet-stream');
      
      await Share.shareXFiles(
        [xFile],
        text: 'AuraPose AI HQ Document',
      );
    } catch (e) {
      debugPrint('Doc share error: $e');
    }
  }

  void _goHome() {
    // Pop back to the main camera screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Photo Preview ──
          GestureDetector(
            onTapDown: _tapToErase,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix([
                _contrast, 0, 0, 0, _brightness * 30,
                0, _contrast, 0, 0, _brightness * 30,
                0, 0, _contrast, 0, _brightness * 30,
                0, 0, 0, 1, 0,
              ]),
              child: widget.isFrontCamera
                  ? Transform.scale(
                      scaleX: -1,
                      child: Image.file(
                        File(_currentImagePath),
                        fit: BoxFit.contain,
                        key: ValueKey(_currentImagePath),
                      ),
                    )
                  : Image.file(
                      File(_currentImagePath),
                      fit: BoxFit.contain,
                      key: ValueKey(_currentImagePath),
                    ),
            ),
          ),
          
          if (_isMagicRemoverMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "MAGIC REMOVER ACTIVE: TAP TO ERASE",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          if (_isProcessingRemoval)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accentPurple),
                    SizedBox(height: 16),
                    Text("AI Erasing...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          // ── Top gradient ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Top bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
                // Match score badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.scoreColor(widget.matchScore).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.scoreColor(widget.matchScore),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.matchScore >= 85 ? Icons.star : Icons.auto_awesome,
                        color: AppColors.scoreColor(widget.matchScore),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.matchScore.toInt()}% match',
                        style: TextStyle(
                          color: AppColors.scoreColor(widget.matchScore),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_editHistory.isNotEmpty)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentImagePath = _editHistory.removeLast();
                      });
                    },
                    icon: const Icon(Icons.undo, color: Colors.white, size: 28),
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pose name
                  Text(
                    widget.templateName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Brightness slider
                  Row(
                    children: [
                      const Icon(Icons.brightness_6, color: Colors.white54, size: 18),
                      Expanded(
                        child: Slider(
                          value: _brightness,
                          min: -1.0,
                          max: 1.0,
                          activeColor: AppColors.accentCyan,
                          inactiveColor: Colors.white24,
                          onChanged: (v) => setState(() => _brightness = v),
                        ),
                      ),
                    ],
                  ),

                  // Contrast slider
                  Row(
                    children: [
                      const Icon(Icons.contrast, color: Colors.white54, size: 18),
                      Expanded(
                        child: Slider(
                          value: _contrast,
                          min: 0.5,
                          max: 2.0,
                          activeColor: AppColors.accentPurple,
                          inactiveColor: Colors.white24,
                          onChanged: (v) => setState(() => _contrast = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pro Advanced Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProButton(icon: Icons.edit, label: 'Pro Editor', onTap: _openProEditor),
                      _ProButton(icon: Icons.auto_fix_high, label: 'Magic Remover', onTap: _magicRemove, isActive: _isMagicRemoverMode),
                      _ProButton(icon: Icons.file_present, label: 'As Doc', onTap: _shareAsDocument),
                      _ProButton(icon: Icons.qr_code, label: 'WiFi Send', onTap: _shareViaQR),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
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
            width: 56,
            height: 56,
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

class _ProButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ProButton({required this.icon, required this.label, required this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
       onTap: onTap,
       child: Column(
          children: [
             Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accentPurple.withOpacity(0.4) : Colors.white12, 
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? Border.all(color: AppColors.accentPurple) : null,
                ),
                child: Icon(icon, color: isActive ? AppColors.accentPurple : Colors.white, size: 20),
             ),
             const SizedBox(height: 4),
             Text(label, style: TextStyle(color: isActive ? AppColors.accentPurple : Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
       ),
    );
  }
}
