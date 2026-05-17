import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class WatermarkService {
  static Future<Uint8List> applyCinematicWatermark(
    Uint8List imageBytes, 
    String deviceName, {
    String watermarkStyle = 'leica',
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    final width = image.width;
    final height = image.height;
    
    // Calculate watermark bar height (8% of image height)
    final barHeight = (height * 0.08).toInt();
    
    // Determine bar and text styling colors based on style choice
    final isWhiteBar = watermarkStyle == 'leica' || watermarkStyle == 'fuji';
    final barColor = isWhiteBar ? img.ColorRgb8(255, 255, 255) : img.ColorRgb8(0, 0, 0);
    final textColor = isWhiteBar ? img.ColorRgb8(0, 0, 0) : img.ColorRgb8(255, 255, 255);
    final secondaryTextColor = isWhiteBar ? img.ColorRgb8(100, 100, 100) : img.ColorRgb8(180, 180, 180);

    final newImage = img.Image(width: width, height: height + barHeight);
    
    // Pre-fill white/black background of the expanded canvas
    img.fill(newImage, color: barColor);
    
    // Render the original photo at the top
    img.compositeImage(newImage, image);

    final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now());
    
    String brandLogoText = "AURA";
    String lensSpec = "50mm f/1.2";
    String exposureSpec = "ISO 100  50mm  f/1.2  1/250s";
    
    if (watermarkStyle == 'leica') {
      brandLogoText = "LEICA M11";
      lensSpec = "NOCTILUX-M 50mm f/0.95 ASPH.";
      exposureSpec = "ISO 64  50mm  f/0.95  1/180s";
    } else if (watermarkStyle == 'hasselblad') {
      brandLogoText = "HASSELBLAD X2D";
      lensSpec = "XCD 38mm f/2.5";
      exposureSpec = "ISO 100  38mm  f/2.5  1/120s";
    } else if (watermarkStyle == 'fuji') {
      brandLogoText = "FUJIFILM GFX 100 II";
      lensSpec = "GF 80mm f/1.7 R WR";
      exposureSpec = "ISO 200  80mm  f/1.7  1/250s";
    } else {
      brandLogoText = "AURA $deviceName";
      lensSpec = "AI Dual Cam f/1.8";
      exposureSpec = "ISO 160  26mm  f/1.8  1/125s";
    }

    final font = image.width > 2000 ? img.arial48 : img.arial24;
    final smallFont = image.width > 2000 ? img.arial24 : img.arial14;

    // Draw Brand logo text (Left aligned)
    img.drawString(
      newImage,
      font: font,
      x: (width * 0.05).toInt(),
      y: height + (barHeight * 0.22).toInt(),
      brandLogoText,
      color: textColor,
    );

    // Draw Lens Specs below Brand logo
    img.drawString(
      newImage,
      font: smallFont,
      x: (width * 0.05).toInt(),
      y: height + (barHeight * 0.58).toInt(),
      lensSpec,
      color: secondaryTextColor,
    );

    // Draw Exposure Info (Right aligned)
    final expWidth = exposureSpec.length * (font.size ~/ 2.4);
    img.drawString(
      newImage,
      font: font,
      x: (width * 0.95).toInt() - expWidth.toInt(),
      y: height + (barHeight * 0.22).toInt(),
      exposureSpec,
      color: textColor,
    );

    // Draw Capture Date below Exposure Specs
    final dateWidth = dateStr.length * (smallFont.size ~/ 2.4);
    img.drawString(
      newImage,
      font: smallFont,
      x: (width * 0.95).toInt() - dateWidth.toInt(),
      y: height + (barHeight * 0.58).toInt(),
      dateStr,
      color: secondaryTextColor,
    );

    return Uint8List.fromList(img.encodeJpg(newImage, quality: 95));
  }
}
