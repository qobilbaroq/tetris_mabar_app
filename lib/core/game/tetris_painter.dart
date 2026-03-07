import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'block.dart';
import 'game_board.dart';

class TetrisPainter extends CustomPainter {
  final GameBoard gameBoard;
  final double cellSize;

  TetrisPainter({
    required this.gameBoard,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBoardBackground(canvas, size);
    _drawGridLines(canvas, size);
    _drawBlocks(canvas);
    _drawBoardBorder(canvas, size);
  }

  void _drawBoardBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceCard
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    canvas.drawRRect(rrect, paint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceInput
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= GameConfig.rows; i++) {
      final y = i * cellSize;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (int i = 0; i <= GameConfig.cols; i++) {
      final x = i * cellSize;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawBlocks(Canvas canvas) {
    for (int row = 0; row < GameConfig.rows; row++) {
      for (int col = 0; col < GameConfig.cols; col++) {
        final color = gameBoard.getCellColor(row, col);
        
        if (color != Colors.transparent) {
          _drawBlock(canvas, row, col, color);
        }
      }
    }
  }

  void _drawBlock(Canvas canvas, int row, int col, Color color) {
    final x = col * cellSize;
    final y = row * cellSize;
    
    final blockRect = Rect.fromLTWH(
      x + 1,
      y + 1,
      cellSize - 2,
      cellSize - 2,
    );

    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(blockRect, basePaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(blockRect.left, blockRect.bottom),
      Offset(blockRect.left, blockRect.top),
      highlightPaint,
    );
    canvas.drawLine(
      Offset(blockRect.left, blockRect.top),
      Offset(blockRect.right, blockRect.top),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(blockRect.right, blockRect.top),
      Offset(blockRect.right, blockRect.bottom),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(blockRect.right, blockRect.bottom),
      Offset(blockRect.left, blockRect.bottom),
      shadowPaint,
    );

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.transparent,
          Colors.black.withOpacity(0.2),
        ],
      ).createShader(blockRect);

    canvas.drawRect(blockRect, gradientPaint);
  }

  void _drawBoardBorder(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.borderDefault
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant TetrisPainter oldDelegate) {
    return true; 
  }
}

class PreviewPainter extends CustomPainter {
  final Block? block;
  final double cellSize;

  PreviewPainter({
    required this.block,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.surfaceCard
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );

    canvas.drawRRect(rrect, bgPaint);

    if (block != null && block!.shape.isNotEmpty) {
      _drawBlock(canvas, block!, size);
    }

    final borderPaint = Paint()
      ..color = AppColors.borderDefault
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawBlock(Canvas canvas, Block block, Size size) {
    final shape = block.shape;
    final rows = shape.length;
    final cols = shape[0].length;
    
    final blockWidth = cols * cellSize;
    final blockHeight = rows * cellSize;
    
    final offsetX = (size.width - blockWidth) / 2;
    final offsetY = (size.height - blockHeight) / 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (shape[row][col] == 1) {
          final x = offsetX + col * cellSize;
          final y = offsetY + row * cellSize;
          
          _drawSingleBlock(canvas, x, y, block.color);
        }
      }
    }
  }

  void _drawSingleBlock(Canvas canvas, double x, double y, Color color) {
    final blockRect = Rect.fromLTWH(
      x + 1,
      y + 1,
      cellSize - 2,
      cellSize - 2,
    );

    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(blockRect, basePaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(blockRect.left, blockRect.bottom),
      Offset(blockRect.left, blockRect.top),
      highlightPaint,
    );
    canvas.drawLine(
      Offset(blockRect.left, blockRect.top),
      Offset(blockRect.right, blockRect.top),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(blockRect.right, blockRect.top),
      Offset(blockRect.right, blockRect.bottom),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(blockRect.right, blockRect.bottom),
      Offset(blockRect.left, blockRect.bottom),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant PreviewPainter oldDelegate) {
    return oldDelegate.block != block;
  }
}

class MultiPreviewPainter extends CustomPainter {
  final List<Block?> blocks;
  final double cellSize;

  MultiPreviewPainter({
    required this.blocks,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.surfaceCard
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );

    canvas.drawRRect(rrect, bgPaint);

    double currentY = 10;
    for (final block in blocks) {
      if (block != null && block.shape.isNotEmpty) {
        _drawBlock(canvas, block, size.width, currentY);
        currentY += 4 * cellSize + 8;
      }
    }

    final borderPaint = Paint()
      ..color = AppColors.borderDefault
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawBlock(Canvas canvas, Block block, double containerWidth, double yOffset) {
    final shape = block.shape;
    final rows = shape.length;
    final cols = shape[0].length;
    
    final blockWidth = cols * cellSize;
    final offsetX = (containerWidth - blockWidth) / 2;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (shape[row][col] == 1) {
          final x = offsetX + col * cellSize;
          final y = yOffset + row * cellSize;
          
          _drawSingleBlock(canvas, x, y, block.color);
        }
      }
    }
  }

  void _drawSingleBlock(Canvas canvas, double x, double y, Color color) {
    final blockRect = Rect.fromLTWH(
      x + 1,
      y + 1,
      cellSize - 2,
      cellSize - 2,
    );

    final basePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(blockRect, basePaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(blockRect.left, blockRect.bottom),
      Offset(blockRect.left, blockRect.top),
      highlightPaint,
    );
    canvas.drawLine(
      Offset(blockRect.left, blockRect.top),
      Offset(blockRect.right, blockRect.top),
      highlightPaint,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(blockRect.right, blockRect.top),
      Offset(blockRect.right, blockRect.bottom),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(blockRect.right, blockRect.bottom),
      Offset(blockRect.left, blockRect.bottom),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MultiPreviewPainter oldDelegate) {
    return true;
  }
}
