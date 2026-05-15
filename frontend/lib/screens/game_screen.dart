import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/game/block.dart';
import '../core/game/game_board.dart';
import '../core/game/tetris_painter.dart';
import '../core/network/network_manager.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameBoard _gameBoard;
  late GameBoard _opponentBoard;
  Timer? _gameTimer;

  // We will calculate cell size dynamically based on layout constraints


  @override
  void initState() {
    super.initState();
    _gameBoard = GameBoard();
    _opponentBoard = GameBoard(); // We won't use this directly to play, just to draw
    _gameBoard.addListener(_onGameBoardChanged);
    NetworkManager.instance.addListener(_onNetworkChanged);
    _startGame();
  }

  void _onNetworkChanged() {
    if (NetworkManager.instance.isGameEnded) {
      _gameTimer?.cancel();
    }
    setState(() {});
  }

  void _onGameBoardChanged() {
    // Sync board to opponent
    final grid = _gameBoard.grid;
    final intGrid = grid.map((row) => row.map((b) => b.index).toList()).toList();
    NetworkManager.instance.sendBoard(intGrid);

    if (_gameBoard.isGameOver && !NetworkManager.instance.isGameEnded) {
      NetworkManager.instance.sendGameOver();
    }
    
    setState(() {});
  }

  void _startGame() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!_gameBoard.isPaused && !_gameBoard.isGameOver) {
        _gameBoard.update();
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _gameBoard.removeListener(_onGameBoardChanged);
    NetworkManager.instance.removeListener(_onNetworkChanged);
    _gameBoard.dispose();
    _opponentBoard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceMain,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Gameplay title
                  const Text(
                    'Gameplay',
                    style: TextStyle(
                      color: AppColors.contentLow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Quit button
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.surfaceCard,
                          title: const Text(
                            'Quit Game?',
                            style: TextStyle(color: AppColors.contentHigh),
                          ),
                          content: const Text(
                            'Are you sure you want to quit?',
                            style: TextStyle(color: AppColors.contentMedium),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.contentMedium)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close dialog
                                Navigator.pop(context); // Pop GameScreen
                              },
                              child: const Text(
                                'Quit',
                                style: TextStyle(color: AppColors.dangerText),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBgDark,
                        border: Border.all(color: AppColors.dangerText.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Quit',
                        style: TextStyle(
                          color: AppColors.dangerText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Player info dan preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Player info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Players',
                            style: TextStyle(
                              color: AppColors.contentMedium,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.brandPrimary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.contentHigh,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                NetworkManager.instance.players.firstWhere(
                                  (p) => p['name'] != NetworkManager.instance.localUsername,
                                  orElse: () => {'name': 'Opponent'}
                                )['name'] as String,
                                style: const TextStyle(
                                  color: AppColors.contentHigh,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // Opponent mini screen
                      Container(
                        width: 40,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderDefault,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.5),
                          child: CustomPaint(
                            size: const Size(40, 80),
                            painter: OpponentPainter(
                              gridData: NetworkManager.instance.opponentBoardGrid,
                              cellSize: 4.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Game area
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        final double cellDynamicSize = availableHeight / GameConfig.rows;
                        final double boardDynamicWidth = cellDynamicSize * GameConfig.cols;
                        final double boardDynamicHeight = availableHeight;

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main game board (Canvas)
                            Container(
                              width: boardDynamicWidth,
                              height: boardDynamicHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CustomPaint(
                                  size: Size(boardDynamicWidth, boardDynamicHeight),
                                  painter: TetrisPainter(
                                    gameBoard: _gameBoard,
                                    cellSize: cellDynamicSize,
                                  ),
                                ),
                              ),
                            ),
                            
                            // Next blocks panel
                            Container(
                              width: 80,
                              height: boardDynamicHeight * 0.5,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Preview blocks
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: 3,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final previewBlocks = _gameBoard.nextBlocks;
                                        if (index >= previewBlocks.length) return const SizedBox();
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          height: 48,
                                          child: CustomPaint(
                                            size: const Size(double.infinity, 48),
                                            painter: PreviewPainter(
                                              block: previewBlocks[index],
                                              cellSize: 14,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // D-pad controls
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildControlButton(
                                    icon: Icons.chevron_left,
                                    onTap: _gameBoard.moveLeft,
                                    isCircle: true,
                                  ),
                                  const SizedBox(width: 30),
                                  _buildControlButton(
                                    icon: Icons.chevron_right,
                                    onTap: _gameBoard.moveRight,
                                    isCircle: true,
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 0,
                                child: _buildControlButton(
                                  icon: Icons.keyboard_arrow_down,
                                  onTap: _gameBoard.moveDown,
                                  isCircle: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Action buttons
                      Column(
                        children: [
                          GestureDetector(
                            onTap: _gameBoard.rotate,
                            child: Container(
                              width: 100,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF142B42),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.brandPrimary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: AppColors.brandPrimary,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _gameBoard.hardDrop,
                            child: Container(
                              width: 100,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.dangerBgDark,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.dangerText.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.keyboard_double_arrow_down,
                                color: AppColors.dangerText,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Game Over or Win overlay
            if (_gameBoard.isGameOver || NetworkManager.instance.isGameEnded)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          NetworkManager.instance.isGameEnded ? NetworkManager.instance.endMessage : 'GAME OVER',
                          style: TextStyle(
                            color: NetworkManager.instance.isGameEnded ? Colors.greenAccent : AppColors.contentHigh,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Score: ${_gameBoard.score}',
                          style: const TextStyle(
                            color: AppColors.contentMedium,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            NetworkManager.instance.close();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPrimary,
                            foregroundColor: AppColors.contentHigh,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isCircle = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: AppColors.contentHigh,
          size: 28,
        ),
      ),
    );
  }
}
