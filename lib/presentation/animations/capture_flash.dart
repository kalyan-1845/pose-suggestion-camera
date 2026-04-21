import 'package:flutter/material.dart';

/// Full-screen white flash animation on photo capture
class CaptureFlash extends StatefulWidget {
  const CaptureFlash({super.key});

  @override
  State<CaptureFlash> createState() => _CaptureFlashState();
}

class _CaptureFlashState extends State<CaptureFlash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) {
        return Container(
          color: Colors.white.withOpacity(_opacity.value),
        );
      },
    );
  }
}
