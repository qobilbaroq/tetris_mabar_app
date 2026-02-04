import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Info text dengan icon untuk menampilkan informasi/petunjuk
class InfoText extends StatelessWidget {
  final String text;
  final IconData icon;

  const InfoText({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: AppColors.brandPrimary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.contentMedium,
          ),
        ),
      ],
    );
  }
}
