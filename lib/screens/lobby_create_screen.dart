import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/outlined_button.dart';
import '../core/network/network_manager.dart';
import 'game_screen.dart';

/// Lobby screen shown to the host (create flow).
class LobbyCreateScreen extends StatelessWidget {
  const LobbyCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NetworkManager.instance,
      builder: (context, _) {
        final net = NetworkManager.instance;
        
        return Scaffold(
          backgroundColor: AppColors.surfaceMain,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button + title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          net.close();
                          Navigator.pop(context);
                        },
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
                      const SizedBox(width: 24),
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
                          children: [
                            const Text(
                              'Room ID / Code',
                              style: TextStyle(
                                color: AppColors.contentMedium,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${net.shortCode} (${net.hostIp})',
                              style: const TextStyle(
                                fontSize: 18,
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
                              child: Text(
                                net.localUsername ?? '',
                                style: const TextStyle(
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

                  Text(
                    'Players ( ${net.players.length} )',
                    style: const TextStyle(
                      color: AppColors.contentHigh,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Players list
                  Expanded(
                    child: ListView.separated(
                      itemCount: net.players.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = net.players[index];
                        return _PlayerTile(
                          name: player['name'] as String,
                          isHost: player['isHost'] as bool,
                        );
                      },
                    ),
                  ),

                  // Bottom actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedGameButton(
                          text: 'Leave',
                          icon: Icons.exit_to_app,
                          onPressed: () {
                            net.close();
                            Navigator.pop(context);
                          },
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
                            net.startGame();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(),
                              ),
                            );
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
          const Text(
            'Ready',
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