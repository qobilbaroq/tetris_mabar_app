import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Primary button dengan background brand color
/// Digunakan untuk aksi utama seperti "Create Room"
class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final double height;
  final bool iconInBox;
  final bool iconOnRight;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.height = 56,
    this.iconInBox = true,
    this.iconOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: AppColors.contentHigh,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!iconOnRight) ...[
              _buildIcon(),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.contentHigh,
              ),
            ),
            if (iconOnRight) ...[
              const SizedBox(width: 12),
              _buildIcon(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconInBox) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.contentHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.brandPrimary,
          size: 18,
        ),
      );
    } else {
      return Icon(
        icon,
        color: AppColors.contentHigh,
        size: 22,
      );
    }
  }
}