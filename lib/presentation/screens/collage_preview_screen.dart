import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';

class CollagePreviewScreen extends StatefulWidget {
  final List<String> imagePaths;

  const CollagePreviewScreen({super.key, required this.imagePaths});

  @override
  State<CollagePreviewScreen> createState() => _CollagePreviewScreenState();
}

class _CollagePreviewScreenState extends State<CollagePreviewScreen> {
  String? _collagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _createCollage();
  }

  Future<void> _createCollage() async {
    final images = <img.Image>[];
    for (final path in widget.imagePaths) {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) images.add(decoded);
    }

    if (images.length < 4) return;

    // Create 2x2 grid
    final w = images[0].width;
    final h = images[0].height;
    
    final collage = img.Image(width: w * 2, height: h * 2);
    
    img.compositeImage(collage, images[0], dstX: 0, dstY: 0);
    img.compositeImage(collage, images[1], dstX: w, dstY: 0);
    img.compositeImage(collage, images[2], dstX: 0, dstY: h);
    img.compositeImage(collage, images[3], dstX: w, dstY: h);

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/collage_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final collageFile = File(path);
    await collageFile.writeAsBytes(img.encodeJpg(collage, quality: 90));

    if (mounted) {
      setState(() => _collagePath = path);
    }
  }

  Future<void> _saveToGallery() async {
    if (_collagePath == null) return;
    setState(() => _isSaving = true);
    await Gal.putImage(_collagePath!);
    setState(() => _isSaving = false);
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Collage saved to Gallery!')),
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AuraPose Collage', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_collagePath != null)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => Share.shareXFiles([XFile(_collagePath!)]),
            ),
        ],
      ),
      body: Center(
        child: _collagePath == null
            ? const CircularProgressIndicator(color: AppColors.accentCyan)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
                    ),
                    child: Image.file(File(_collagePath!)),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveToGallery,
                    icon: _isSaving 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.save_alt),
                    label: Text(_isSaving ? 'Saving...' : 'Save to Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
