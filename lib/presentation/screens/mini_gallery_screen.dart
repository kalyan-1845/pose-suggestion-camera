import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import 'preview_screen.dart'; // We will use PreviewScreen to view and edit

class MiniGalleryScreen extends StatefulWidget {
  const MiniGalleryScreen({super.key});

  @override
  State<MiniGalleryScreen> createState() => _MiniGalleryScreenState();
}

class _MiniGalleryScreenState extends State<MiniGalleryScreen> {
  List<File> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final Directory docDir = await getApplicationDocumentsDirectory();
      // Look for files ending with .jpg or .png
      final List<FileSystemEntity> files = docDir.listSync(recursive: true);
      final List<File> imageFiles = files
          .whereType<File>()
          .where((file) {
            final ext = file.path.toLowerCase();
            return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png');
          })
          .toList();

      // Sort by modified descending
      imageFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      if (mounted) {
        setState(() {
          _images = imageFiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading gallery: \$e");
      if (mounted) {
         setState(() => _isLoading = false);
      }
    }
  }

  void _openImage(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewScreen(
          imagePath: file.path, 
          templateId: 'gallery', 
          templateName: 'Gallery Image', 
          matchScore: 100.0, 
          isFrontCamera: false,
        ),
      ),
    ).then((_) => _loadImages()); // reload on return in case of edits
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Mini Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accentCyan))
        : _images.isEmpty
          ? const Center(child: Text("No photos captured yet.", style: TextStyle(color: Colors.white54)))
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 3,
                 crossAxisSpacing: 4,
                 mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final file = _images[index];
                return GestureDetector(
                  onTap: () => _openImage(file),
                  child: Container(
                    decoration: BoxDecoration(
                       color: Colors.white12,
                       image: DecorationImage(
                         image: FileImage(file),
                         fit: BoxFit.cover,
                       ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
