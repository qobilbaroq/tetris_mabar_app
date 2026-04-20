import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/danger_button.dart';
import '../core/network/network_manager.dart';
import 'game_screen.dart';

/// Lobby screen shown to a participant who joined a room.
class LobbyJoinScreen extends StatefulWidget {
  const LobbyJoinScreen({super.key});

  @override
  State<LobbyJoinScreen> createState() => _LobbyJoinScreenState();
}

class _LobbyJoinScreenState extends State<LobbyJoinScreen> {
  void _onNetworkChange() {
    if (NetworkManager.instance.isHostDisconnected) {
      NetworkManager.instance.removeListener(_onNetworkChange);
      
      // Clean up local resources just in case, though it's already mostly handled
      NetworkManager.instance.close();
      
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room closed by the host'),
          backgroundColor: AppColors.dangerBgDark,
        ),
      );
      return;
    }

    if (NetworkManager.instance.isGameStarted) {
      NetworkManager.instance.removeListener(_onNetworkChange);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GameScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    NetworkManager.instance.addListener(_onNetworkChange);
  }

  @override
  void dispose() {
    NetworkManager.instance.removeListener(_onNetworkChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NetworkManager.instance,
      builder: (context, _) {
        final net = NetworkManager.instance;
        
        // Host might be the first player, or we find it by flag
        final hostName = net.players.firstWhere(
          (p) => p['isHost'] == true, 
          orElse: () => {'name': 'Unknown'},
        )['name'];

        return Scaffold(
          backgroundColor: AppColors.surfaceMain,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back + title (no card background)
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
                          children: [
                            const Text(
                              'Room ID (IP)',
                              style: TextStyle(
                                color: AppColors.contentMedium,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              net.hostIp ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 20,
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
                                hostName,
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

                  // Leave button
                  DangerButton(
                    text: 'Leave',
                    icon: Icons.logout,
                    onPressed: () {
                      net.close();
                      Navigator.pop(context);
                    },
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