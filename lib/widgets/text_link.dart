import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Text link dengan icon untuk aksi seperti "How to Play"
class TextLink extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const TextLink({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.contentMedium,
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
        ),
      ),
    );
  }
}