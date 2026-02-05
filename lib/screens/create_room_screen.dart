import 'package:flutter/material.dart';
import 'package:tetris_mabar_app/screens/lobby_create_screen.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/info_text.dart';
import '../widgets/primary_button.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back Button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.contentHigh,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Create Room',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.contentHigh,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Set up a room and start the game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.contentMedium,
                ),
              ),

              const SizedBox(height: 48),

              // Username Input
              CustomInputField(
                label: 'Username',
                hint: 'TetrisMaster',
                icon: Icons.person_outline,
                controller: _usernameController,
                iconOnRight: true,
              ),

              const Spacer(),

              // Info Text
              const InfoText(text: 'Send the code to your friend to join'),

              const SizedBox(height: 16),

              // Create Room Button
              PrimaryButton(
                text: 'Create Room',
                icon: Icons.arrow_forward,
                iconInBox: false,
                iconOnRight: true,
                onPressed: () {
                  // TODO: Create room logic
                  final username = _usernameController.text.trim();
                  if (username.isNotEmpty) {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LobbyCreateScreen(),
                    ),
                  );
                  }
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
