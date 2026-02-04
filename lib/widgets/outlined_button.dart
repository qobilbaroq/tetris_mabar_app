import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Outlined button dengan border dan transparan background
/// Digunakan untuk aksi sekunder seperti "Join Room"
class OutlinedGameButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final double height;

  const OutlinedGameButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.contentHigh,
          side: const BorderSide(
            color: AppColors.borderDefault,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.brandPrimary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.contentHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}