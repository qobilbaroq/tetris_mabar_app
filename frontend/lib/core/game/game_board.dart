import 'dart:math';
import 'package:flutter/material.dart';
import 'block.dart';

class GameConfig {
  static const int rows = 20;
  static const int cols = 10;
  static const double cellSize = 25.0;
}

class GameBoard extends ChangeNotifier {
  late List<List<BlockType>> _grid;
  ActiveBlock? _activeBlock;
  List<Block> _nextBlocks = [];
  
  int _score = 0;
  int _linesCleared = 0;
  bool _isGameOver = false;
  bool _isPaused = false;

  final Random _random = Random();

  List<List<BlockType>> get grid => _grid;
  ActiveBlock? get activeBlock => _activeBlock;
  List<Block> get nextBlocks => _nextBlocks;
  int get score => _score;
  int get linesCleared => _linesCleared;
  bool get isGameOver => _isGameOver;
  bool get isPaused => _isPaused;

  GameBoard() {
    _initialize();
  }

  void _initialize() {
    _grid = List.generate(
      GameConfig.rows,
      (_) => List.generate(GameConfig.cols, (_) => BlockType.empty),
    );
    _nextBlocks = List.generate(3, (_) => _generateRandomBlock());
    _spawnBlock();
  }

  Block _generateRandomBlock() {
    final types = [
      BlockType.I,
      BlockType.J,
      BlockType.L,
      BlockType.O,
      BlockType.S,
      BlockType.T,
      BlockType.Z,
    ];
    return Block.fromType(types[_random.nextInt(types.length)]);
  }

  void _spawnBlock() {
    if (_nextBlocks.isEmpty) return;
    
    final nextBlock = _nextBlocks.removeAt(0);
    _activeBlock = ActiveBlock(
      block: nextBlock,
      x: (GameConfig.cols ~/ 2) - (nextBlock.shape[0].length ~/ 2),
      y: 0,
    );
    
    _nextBlocks.add(_generateRandomBlock());
    
    if (_checkCollision(_activeBlock!.block, _activeBlock!.x, _activeBlock!.y)) {
      _isGameOver = true;
    }
    
    notifyListeners();
  }

  bool _checkCollision(Block block, int x, int y) {
    for (int i = 0; i < block.shape.length; i++) {
        for (int j = 0; j < block.shape[i].length; j++) {
        if (block.shape[i][j] == 1) {
          final newX = x + j;
          final newY = y + i;
          
          if (newX < 0 || newX >= GameConfig.cols || newY >= GameConfig.rows) {
            return true;
          }
          
          if (newY >= 0 && _grid[newY][newX] != BlockType.empty) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void _lockBlock() {
    if (_activeBlock == null) return;
    
    for (int i = 0; i < _activeBlock!.block.shape.length; i++) {
      for (int j = 0; j < _activeBlock!.block.shape[i].length; j++) {
        if (_activeBlock!.block.shape[i][j] == 1) {
          final x = _activeBlock!.x + j;
          final y = _activeBlock!.y + i;
          
          if (y >= 0) {
            _grid[y][x] = _activeBlock!.block.type;
          }
        }
      }
    }
    
    _clearLines();
    _spawnBlock();
  }

  void _clearLines() {
    int linesCleared = 0;
    
    for (int i = GameConfig.rows - 1; i >= 0; i--) {
      if (_grid[i].every((cell) => cell != BlockType.empty)) {
        _grid.removeAt(i);
        _grid.insert(0, List.generate(GameConfig.cols, (_) => BlockType.empty));
        linesCleared++;
        i++;
      }
    }
    
    if (linesCleared > 0) {
      _linesCleared += linesCleared;
      _score += linesCleared * 100 * linesCleared;
      notifyListeners();
    }
  }

  void moveLeft() {
    if (_isGameOver || _isPaused || _activeBlock == null) return;
    
    if (!_checkCollision(_activeBlock!.block, _activeBlock!.x - 1, _activeBlock!.y)) {
      _activeBlock!.x--;
      notifyListeners();
    }
  }

  void moveRight() {
    if (_isGameOver || _isPaused || _activeBlock == null) return;
    
    if (!_checkCollision(_activeBlock!.block, _activeBlock!.x + 1, _activeBlock!.y)) {
      _activeBlock!.x++;
      notifyListeners();
    }
  }

  void moveDown() {
    if (_isGameOver || _isPaused || _activeBlock == null) return;
    
    if (!_checkCollision(_activeBlock!.block, _activeBlock!.x, _activeBlock!.y + 1)) {
      _activeBlock!.y++;
      _score += 1;
      notifyListeners();
    } else {
      _lockBlock();
    }
  }

  void hardDrop() {
    if (_isGameOver || _isPaused || _activeBlock == null) return;
    
    int dropDistance = 0;
    while (!_checkCollision(_activeBlock!.block, _activeBlock!.x, _activeBlock!.y + dropDistance + 1)) {
      dropDistance++;
    }
    
    _activeBlock!.y += dropDistance;
    _score += dropDistance * 2;
    _lockBlock();
    notifyListeners();
  }

  void rotate() {
    if (_isGameOver || _isPaused || _activeBlock == null) return;
    
    final rotatedBlock = _activeBlock!.block.rotate();
    
    if (!_checkCollision(rotatedBlock, _activeBlock!.x, _activeBlock!.y)) {
      _activeBlock!.block = rotatedBlock;
      notifyListeners();
    }
  }

  void update() {
    if (_isGameOver || _isPaused) return;
    
    if (_activeBlock != null) {
      if (!_checkCollision(_activeBlock!.block, _activeBlock!.x, _activeBlock!.y + 1)) {
        _activeBlock!.y++;
        notifyListeners();
      } else {
        _lockBlock();
      }
    }
  }

  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }

  void reset() {
    _score = 0;
    _linesCleared = 0;
    _isGameOver = false;
    _isPaused = false;
    _activeBlock = null;
    _initialize();
  }

  Color getCellColor(int row, int col) {
    if (_activeBlock != null) {
      final block = _activeBlock!.block;
      final relRow = row - _activeBlock!.y;
      final relCol = col - _activeBlock!.x;
      
      if (relRow >= 0 &&
          relRow < block.shape.length &&
          relCol >= 0 &&
          relCol < block.shape[relRow].length &&
          block.shape[relRow][relCol] == 1) {
        return block.color;
      }
    }
    
    return _grid[row][col].color;
  }

  bool isCellFilled(int row, int col) {
    if (_grid[row][col] != BlockType.empty) return true;
    
    if (_activeBlock != null) {
      final block = _activeBlock!.block;
      final relRow = row - _activeBlock!.y;
      final relCol = col - _activeBlock!.x;
      
      if (relRow >= 0 &&
          relRow < block.shape.length &&
          relCol >= 0 &&
          relCol < block.shape[relRow].length &&
          block.shape[relRow][relCol] == 1) {
        return true;
      }
    }
    
    return false;
  }
}
