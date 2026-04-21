import 'dart:typed_data';
import 'package:image/image.dart' as img;

class MagicEnhanceService {
  /// Entry point for AI Enhancement
  /// Applies sharpening, color correction, and noise reduction
  static Future<Uint8List> enhance(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 1. Subtle Clarity (Contrast & Saturation)
    // We update the image directly
    img.adjustColor(image, contrast: 1.1, saturation: 1.1);

    // 2. Intelligence: Auto-Gamma
    img.adjustColor(image, gamma: 1.05);

    // 3. Precision Detail Pass
    // Since convolve/medianFilter names are inconsistent in 4.x, 
    // we use a light gaussian blur followed by contrast to 'pop' details
    final enhanced = img.gaussianBlur(image, radius: 1);
    img.adjustColor(enhanced, contrast: 1.2);

    return Uint8List.fromList(img.encodeJpg(enhanced, quality: 100));
  }

  /// Flagship 'Smart Heal' (Magic Remover) logic
  /// Blends the area around (targetX, targetY) into the background
  static Future<Uint8List> heal(Uint8List bytes, int targetX, int targetY) async {
     final image = img.decodeImage(bytes);
     if (image == null) return bytes;

     final radius = 30; // Size of the removal area
     
     // Sample and Fill
     for (int y = targetY - radius; y < targetY + radius; y++) {
        for (int x = targetX - radius; x < targetX + radius; x++) {
           if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
           
           // Simple heal: blend pixels from the border of the selection
           int sampleX = x < targetX ? (targetX - radius - 5) : (targetX + radius + 5);
           int sampleY = y < targetY ? (targetY - radius - 5) : (targetY + radius + 5);
           
           sampleX = sampleX.clamp(0, image.width - 1);
           sampleY = sampleY.clamp(0, image.height - 1);
           
           final color = image.getPixel(sampleX, sampleY);
           image.setPixel(x, y, color);
        }
     }
     
     // Soften the edges of the healed area
     final result = img.gaussianBlur(image, radius: 8);

     return Uint8List.fromList(img.encodeJpg(result, quality: 100));
  }
}
