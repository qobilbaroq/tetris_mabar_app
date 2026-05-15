import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TetrisLogo extends StatelessWidget {
  final double size;

  const TetrisLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
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

