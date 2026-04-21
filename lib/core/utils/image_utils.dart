import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/foundation.dart';

/// Utility for converting CameraImage to InputImage for ML Kit
class ImageUtils {
  ImageUtils._();

  /// Convert CameraImage to InputImage for ML Kit processing
  static InputImage? cameraImageToInputImage(
    CameraImage image,
    CameraDescription camera,
    int sensorOrientation,
  ) {
    // Determine image rotation based on device and camera orientation
    final InputImageRotation rotation =
        _rotationIntToImageRotation(sensorOrientation);

    // Get the image format
    final InputImageFormat? format = _getInputImageFormat(image.format.group);

    if (format == null) return null;

    // For single-plane images (BGRA8888 on iOS)
    if (image.planes.length == 1) {
      return InputImage.fromBytes(
        bytes: image.planes[0].bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    }

    // For multi-plane images (NV21/YUV420 on Android)
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  /// Convert rotation integer to InputImageRotation enum
  static InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// Get InputImageFormat from ImageFormatGroup
  static InputImageFormat? _getInputImageFormat(ImageFormatGroup group) {
    switch (group) {
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv_420_888;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return null;
    }
  }
}
