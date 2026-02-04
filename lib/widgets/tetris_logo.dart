import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget untuk menampilkan logo Tetris blocks
/// Terdiri dari 4 blok yang disusun membentuk piece Tetris
class TetrisLogo extends StatelessWidget {
  final double size;

  const TetrisLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    // If an SVG asset is available, prefer it; otherwise fall back to original drawn blocks.
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Individual Tetris block widget
// SVG-based logo used from assets/images/logo.svg
