import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class NetworkManager extends ChangeNotifier {
  static final NetworkManager instance = NetworkManager._internal();
  NetworkManager._internal();

  // Server connection info
  String serverUrl = 'ws://localhost:8080/ws'; // Will be configurable
  String? roomCode;
  
  List<Map<String, dynamic>> players = [];
  String? localUsername;
  bool isGameStarted = false;
  bool isServerDisconnected = false;
  
  bool isGameEnded = false;
  String endMessage = '';
  List<List<int>> opponentBoardGrid = [];

  // WebSocket client
  WebSocketChannel? _channel;
  bool _isConnected = false;

  /// Create a new room (host creates room, joins it, and waits for others)
  Future<void> startHost(String username) async {
    localUsername = username;
    isGameStarted = false;
    isGameEnded = false;
    isServerDisconnected = false;
    endMessage = '';
    opponentBoardGrid = [];
    players = [{'name': username, 'isHost': true}];
    
    notifyListeners();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;

      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        _handleServerMessage(data);
      }, onDone: () {
        _isConnected = false;
        isServerDisconnected = true;
        if (isGameStarted && !isGameEnded) {
          isGameEnded = true;
          endMessage = 'Server Disconnected!';
        }
        notifyListeners();
      });

      // Request to create a room
      _send({
        'type': 'create_room',
        'name': username,
      });
    } catch (e) {
      debugPrint('Error starting host: $e');
      isServerDisconnected = true;
      notifyListeners();
    }
  }

  /// Join an existing room by room code
  Future<void> joinRoom(String roomCodeInput, String username) async {
    localUsername = username;
    roomCode = roomCodeInput;
    isGameStarted = false;
    isGameEnded = false;
    isServerDisconnected = false;
    endMessage = '';
    opponentBoardGrid = [];
    players = [];
    
    notifyListeners();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;

      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        _handleServerMessage(data);
      }, onDone: () {
        _isConnected = false;
        isServerDisconnected = true;
        if (isGameStarted && !isGameEnded) {
          isGameEnded = true;
          endMessage = 'Server Disconnected!';
        }
        notifyListeners();
      });

      // Request to join the room
      _send({
        'type': 'join',
        'roomCode': roomCodeInput,
        'name': username,
      });
    } catch (e) {
      debugPrint('Error joining room: $e');
      isServerDisconnected = true;
      notifyListeners();
    }
  }

  void _handleServerMessage(Map<String, dynamic> data) {
    final type = data['type'];

    if (type == 'room_created') {
      // Host receives room code after creating room
      roomCode = data['roomCode'];
      players = List<Map<String, dynamic>>.from(data['players']);
      notifyListeners();
    } else if (type == 'players_update') {
      players = List<Map<String, dynamic>>.from(data['players']);
      notifyListeners();
    } else if (type == 'start_game') {
      isGameStarted = true;
      isGameEnded = false;
      notifyListeners();
    } else if (type == 'board_update') {
      opponentBoardGrid = List<List<int>>.from(data['board'].map((row) => List<int>.from(row)));
      notifyListeners();
    } else if (type == 'you_win') {
      isGameEnded = true;
      endMessage = data['reason'] ?? 'You Win!';
      notifyListeners();
    } else if (type == 'error') {
      debugPrint('Server error: ${data['message']}');
      endMessage = data['message'] ?? 'Error occurred';
      notifyListeners();
    }
  }

  void _send(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      debugPrint('WebSocket not connected');
      return;
    }
    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void startGame() {
    _send({'type': 'start_game', 'roomCode': roomCode});
  }

  void sendBoard(List<List<int>> board) {
    _send({'type': 'board_update', 'board': board, 'roomCode': roomCode});
  }

  void sendGameOver() {
    isGameEnded = true;
    endMessage = 'GAME OVER';
    notifyListeners();
    _send({'type': 'i_lost', 'roomCode': roomCode});
  }

  void close() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
    }
    _isConnected = false;
    players.clear();
    roomCode = null;
    localUsername = null;
    isGameStarted = false;
    isGameEnded = false;
    isServerDisconnected = false;
    endMessage = '';
    notifyListeners();
  }

  /// Set the server URL (for configuration)
  void setServerUrl(String url) {
    serverUrl = url;
  }
}
