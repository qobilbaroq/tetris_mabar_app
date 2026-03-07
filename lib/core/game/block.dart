import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BlockColors {
  static const Color cyan = AppColors.blockI;
  static const Color blue = AppColors.blockJ;
  static const Color orange = AppColors.blockL;
  static const Color yellow = AppColors.blockO;
  static const Color green = AppColors.blockS;
  static const Color purple = AppColors.blockT;
  static const Color red = AppColors.blockZ;
  static const Color empty = Colors.transparent;
}

enum BlockType { I, J, L, O, S, T, Z, empty }

extension BlockTypeExtension on BlockType {
  Color get color {
    switch (this) {
      case BlockType.I:
        return BlockColors.cyan;
      case BlockType.J:
        return BlockColors.blue;
      case BlockType.L:
        return BlockColors.orange;
      case BlockType.O:
        return BlockColors.yellow;
      case BlockType.S:
        return BlockColors.green;
      case BlockType.T:
        return BlockColors.purple;
      case BlockType.Z:
        return BlockColors.red;
      case BlockType.empty:
        return BlockColors.empty;
    }
  }
}

class Block {
  final BlockType type;
  final List<List<int>> shape;
  final Color color;

  Block({
    required this.type,
    required this.shape,
    required this.color,
  });

  factory Block.fromType(BlockType type) {
    switch (type) {
      case BlockType.I:
        return Block(
          type: type,
          shape: [
            [0, 0, 0, 0],
            [1, 1, 1, 1],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
          ],
          color: BlockColors.cyan,
        );
      case BlockType.J:
        return Block(
          type: type,
          shape: [
            [1, 0, 0],
            [1, 1, 1],
            [0, 0, 0],
          ],
          color: BlockColors.blue,
        );
      case BlockType.L:
        return Block(
          type: type,
          shape: [
            [0, 0, 1],
            [1, 1, 1],
            [0, 0, 0],
          ],
          color: BlockColors.orange,
        );
      case BlockType.O:
        return Block(
          type: type,
          shape: [
            [1, 1],
            [1, 1],
          ],
          color: BlockColors.yellow,
        );
      case BlockType.S:
        return Block(
          type: type,
          shape: [
            [0, 1, 1],
            [1, 1, 0],
            [0, 0, 0],
          ],
          color: BlockColors.green,
        );
      case BlockType.T:
        return Block(
          type: type,
          shape: [
            [0, 1, 0],
            [1, 1, 1],
            [0, 0, 0],
          ],
          color: BlockColors.purple,
        );
      case BlockType.Z:
        return Block(
          type: type,
          shape: [
            [1, 1, 0],
            [0, 1, 1],
            [0, 0, 0],
          ],
          color: BlockColors.red,
        );
      case BlockType.empty:
        return Block(
          type: type,
          shape: [],
          color: BlockColors.empty,
        );
    }
  }

  Block rotate() {
    if (shape.isEmpty) return this;
    
    final int rows = shape.length;
    final int cols = shape[0].length;
    List<List<int>> newShape = List.generate(
      cols,
      (i) => List.generate(rows, (j) => 0),
    );

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        newShape[j][rows - 1 - i] = shape[i][j];
      }
    }

    return Block(type: type, shape: newShape, color: color);
  }
}

class ActiveBlock {
  Block block;
  int x;
  int y;

  ActiveBlock({
    required this.block,
    required this.x,
    required this.y,
  });
}
