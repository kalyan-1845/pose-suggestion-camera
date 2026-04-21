import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final inputPath = 'C:/Users/prsnl/.gemini/antigravity/brain/fdb4ef68-aba0-4603-b712-4ca671501fd3/aurapose_logo_1776788563303.png';
  final outputPath = 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png';
  
  final bytes = await File(inputPath).readAsBytes();
  final image = img.decodeImage(bytes);
  
  if (image != null) {
    // Resize to standard xxxhdpi size (192x192)
    final resized = img.copyResize(image, width: 192, height: 192);
    final pngBytes = img.encodePng(resized);
    
    // Write to all mipmap folders
    final folders = ['hdpi', 'mdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];
    final sizes = [72, 48, 96, 144, 192];
    
    for (int i = 0; i < folders.length; i++) {
        final folder = folders[i];
        final size = sizes[i];
        final targetResized = img.copyResize(image, width: size, height: size);
        final file = File('android/app/src/main/res/mipmap-$folder/ic_launcher.png');
        await file.writeAsBytes(img.encodePng(targetResized));
        print('Wrote $folder icon');
    }
  } else {
    print('Failed to decode image');
  }
}
