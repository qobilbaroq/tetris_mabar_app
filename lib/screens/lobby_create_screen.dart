import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/outlined_button.dart';

/// Lobby screen shown to the host (create flow).
class LobbyCreateScreen extends StatelessWidget {
  const LobbyCreateScreen({super.key});

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

              // Back button + title (no card background)
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.contentHigh,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Lobby',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.contentHigh,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // Balance spacing
                ],
              ),

              const SizedBox(height: 24),

              // Room card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Room ID',
                          style: TextStyle(
                            color: AppColors.contentMedium,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ABCD',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.contentHigh,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Host',
                          style: TextStyle(
                            color: AppColors.contentMedium,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TetrisMaster',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Players ( 3 )',
                style: TextStyle(
                  color: AppColors.contentHigh,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              // Players list
              Column(
                children: const [
                  _PlayerTile(name: 'TetrisMaster', isHost: true),
                  SizedBox(height: 12),
                  _PlayerTile(name: 'TetrisMaster'),
                  SizedBox(height: 12),
                  _PlayerTile(name: 'TetrisMaster'),
                ],
              ),

              const Spacer(),

              // Bottom actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedGameButton(
                      text: 'Leave',
                      icon: Icons.exit_to_app,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'START GAME',
                      icon: Icons.play_arrow,
                      iconInBox: false,
                      onPressed: () {
                        // start game
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final String name;
  final bool isHost;

  const _PlayerTile({required this.name, this.isHost = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.contentHigh,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (isHost) ...[
                    const SizedBox(width: 8),
                    const Text(
                      'Host',
                      style: TextStyle(
                        color: AppColors.contentMedium,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Text(
            '0 / 0',
            style: TextStyle(
              color: AppColors.contentMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}