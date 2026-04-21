import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class WatermarkService {
  static Future<Uint8List> applyCinematicWatermark(Uint8List imageBytes, String deviceName) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final width = image.width;
    final height = image.height;
    
    // Calculate watermark bar height (roughly 8% of image height)
    final barHeight = (height * 0.08).toInt();
    
    // Create a new image with extra height for the bar
    final newImage = img.Image(width: width, height: height + barHeight);
    
    // Copy original image
    img.compositeImage(newImage, image);
    
    // Fill the bottom bar with black
    img.fillRect(newImage, x1: 0, y1: height, x2: width, y2: height + barHeight, color: img.ColorRgb8(0, 0, 0));

    // Prepare text
    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());
    final branding = "Shot on $deviceName | AuraPose AI";

    // Standard pro fonts are usually sans-serif
    // Note: 'image' package fonts are limited, but we can use arial_24/48
    final font = image.width > 2000 ? img.arial48 : img.arial24;

    // Draw branding (Left aligned)
    img.drawString(
      newImage,
      font: font,
      x: (width * 0.05).toInt(),
      y: height + (barHeight ~/ 2) - (font.lineHeight ~/ 2),
      branding,
      color: img.ColorRgb8(255, 255, 255),
    );

    // Draw date (Right aligned)
    final dateWidth = dateStr.length * (font.size ~/ 2); // Rough estimate
    img.drawString(
      newImage,
      font: font,
      x: (width * 0.95).toInt() - dateWidth.toInt(),
      y: height + (barHeight ~/ 2) - (font.lineHeight ~/ 2),
      dateStr,
      color: img.ColorRgb8(180, 180, 180),
    );

    return Uint8List.fromList(img.encodeJpg(newImage, quality: 95));
  }
}
