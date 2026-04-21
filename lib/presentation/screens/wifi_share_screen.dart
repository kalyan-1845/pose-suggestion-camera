import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';

class WifiShareScreen extends StatefulWidget {
  final String? imagePathToShare; // If null, user is receiving. If provided, user is sending.

  const WifiShareScreen({super.key, this.imagePathToShare});

  @override
  State<WifiShareScreen> createState() => _WifiShareScreenState();
}

class _WifiShareScreenState extends State<WifiShareScreen> {
  // Sending State
  HttpServer? _server;
  String? _shareUrl;
  
  // Receiving State
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.imagePathToShare != null) {
      _startServer();
    } else {
      _initScanner();
    }
  }

  Future<void> _startServer() async {
    try {
      final ip = await NetworkInfo().getWifiIP();
      if (ip == null) throw Exception("Please connect to Wi-Fi to share.");

      _server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
      _shareUrl = "http://\$ip:8080/download";

      if (mounted) setState(() {});

      _server!.listen((HttpRequest request) async {
        if (request.uri.path == '/download') {
           final file = File(widget.imagePathToShare!);
           if (await file.exists()) {
             request.response
                ..headers.contentType = ContentType("image", "jpeg")
                ..headers.set(HttpHeaders.contentDisposition, 'attachment; filename="shared_pose_image.jpg"');
             await file.openRead().pipe(request.response);
           } else {
             request.response.statusCode = HttpStatus.notFound;
             request.response.close();
           }
        } else {
           request.response.statusCode = HttpStatus.notFound;
           request.response.close();
        }
      });
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error: \$e")));
      }
    }
  }

  Future<void> _initScanner() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      
      _cameraController = CameraController(backCamera, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
      
      _cameraController!.startImageStream((CameraImage image) async {
         if (_isDownloading) return;
         
         final WriteBuffer allBytes = WriteBuffer();
         for (final Plane plane in image.planes) {
           allBytes.putUint8List(plane.bytes);
         }
         final bytes = allBytes.done().buffer.asUint8List();
         
         final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
         final InputImageRotation imageRotation = InputImageRotation.values.firstWhere(
           (r) => r.rawValue == backCamera.sensorOrientation,
           orElse: () => InputImageRotation.rotation90deg,
         );
         
         final inputImageFormat = InputImageFormat.values.firstWhere(
           (f) => f.rawValue == image.format.raw,
           orElse: () => InputImageFormat.nv21,
         );

         final inputImage = InputImage.fromBytes(
           bytes: bytes,
           metadata: InputImageMetadata(
              size: imageSize,
              rotation: imageRotation,
              format: inputImageFormat,
              bytesPerRow: image.planes[0].bytesPerRow,
           ),
         );

         final barcodes = await _barcodeScanner.processImage(inputImage);
         for (final barcode in barcodes) {
            if (barcode.rawValue != null && barcode.rawValue!.startsWith("http://")) {
               _downloadImage(barcode.rawValue!);
               break;
            }
         }
      });

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Scanner init error: \$e");
    }
  }

  Future<void> _downloadImage(String url) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
       final response = await http.get(Uri.parse(url));
       if (response.statusCode == 200) {
          final dir = await getApplicationDocumentsDirectory();
          final file = File('\${dir.path}/received_share_\${DateTime.now().millisecondsSinceEpoch}.jpg');
          await file.writeAsBytes(response.bodyBytes);
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image received successfully!")));
             Navigator.of(context).pop();
          }
       } else {
          throw Exception("Failed to download");
       }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download error: \$e")));
       }
    } finally {
       if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    _server?.close();
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSending = widget.imagePathToShare != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isSending ? 'Send via Wi-Fi' : 'Scan to Receive', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isSending ? _buildSendView() : _buildReceiveView(),
    );
  }

  Widget _buildSendView() {
     if (_shareUrl == null) {
        return const Center(child: CircularProgressIndicator(color: AppColors.accentCyan));
     }

     return Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           const Text(
             "Ask the receiver to tap 'Receive' and scan this QR!",
             style: TextStyle(color: Colors.white, fontSize: 16),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 30),
           Container(
             padding: const EdgeInsets.all(16),
             color: Colors.white,
             child: QrImageView(
               data: _shareUrl!,
               version: QrVersions.auto,
               size: 250.0,
             ),
           ),
           const SizedBox(height: 30),
           Text(
             "Local Address: \n\$_shareUrl",
             style: const TextStyle(color: Colors.white54, fontSize: 13),
             textAlign: TextAlign.center,
           ),
         ],
       ),
     );
  }

  Widget _buildReceiveView() {
     if (_cameraController == null || !_cameraController!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator(color: AppColors.accentCyan));
     }

     return Stack(
       fit: StackFit.expand,
       children: [
         CameraPreview(_cameraController!),
         Container(
            decoration: BoxDecoration(
               color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
               child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                     border: Border.all(color: AppColors.accentCyan, width: 3),
                     color: Colors.transparent,
                  ),
               ),
            ),
         ),
         const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Align QR Code inside square to receive",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
         ),
         if (_isDownloading)
           Container(
             color: Colors.black54,
             child: const Center(
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                    CircularProgressIndicator(color: AppColors.accentCyan),
                    SizedBox(height: 16),
                    Text("Downloading raw image...", style: TextStyle(color: Colors.white, fontSize: 16)),
                 ],
               ),
             ),
           ),
       ],
     );
  }
}
