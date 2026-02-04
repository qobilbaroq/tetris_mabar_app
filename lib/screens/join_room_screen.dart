import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/info_text.dart';
import '../widgets/primary_button.dart';

/// Screen untuk bergabung ke room yang sudah dibuat
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _roomIdController.dispose();
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
                'Join Room',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.contentHigh,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter details to connect to a game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.contentMedium,
                ),
              ),

              const SizedBox(height: 48),

              // Username Input (icon on right)
              CustomInputField(
                label: 'Username',
                hint: 'TetrisMaster',
                icon: Icons.person_outline,
                controller: _usernameController,
                iconOnRight: true,
              ),

              const SizedBox(height: 16),

              // Room ID Input
              CustomInputField(
                label: 'Room ID',
                hint: 'zxcv',
                icon: Icons.vpn_key_outlined,
                controller: _roomIdController,
              ),

              const Spacer(),

              // Info Text
              const InfoText(text: 'ask host for IP & Port details'),

              const SizedBox(height: 16),

              // Join Room Button
              PrimaryButton(
                text: 'Join Room',
                icon: Icons.arrow_forward,
                iconInBox: false,
                iconOnRight: true,
                onPressed: () {
                  final username = _usernameController.text.trim();
                  final roomId = _roomIdController.text.trim();
                  if (username.isNotEmpty && roomId.isNotEmpty) {
                    // TODO: implement join room logic
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
