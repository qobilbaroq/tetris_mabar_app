import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/tetris_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/outlined_button.dart';
import '../widgets/text_link.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

/// Home screen untuk aplikasi Tetris
/// Menampilkan logo, judul, dan menu utama
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo Tetris Blocks
              const TetrisLogo(size: 140),

              const SizedBox(height: 24),

              // Title TETRIS
              const Text(
                'TETRIS',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.contentHigh,
                  letterSpacing: 2,
                ),
              ),

              const Spacer(flex: 2),

              // Create Room Button
              PrimaryButton(
                text: 'Create Room',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateRoomScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Join Room Button
              OutlinedGameButton(
                text: 'Join Room',
                icon: Icons.login_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JoinRoomScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // How to Play Link
              TextLink(
                text: 'How to Play',
                icon: Icons.help_outline,
                onTap: () {
                  // TODO: Show how to play dialog/page
                },
              ),

              const Spacer(),

              // Version Text
              const Text(
                'v1.0.0 Beta',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.contentLow,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
