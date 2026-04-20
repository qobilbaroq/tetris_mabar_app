import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetworkManager extends ChangeNotifier {
  static final NetworkManager instance = NetworkManager._internal();
  NetworkManager._internal();

  bool isHost = false;
  String? hostIp;
  int hostPort = 8080;
  
  List<Map<String, dynamic>> players = [];
  String? localUsername;
  bool isGameStarted = false;
  bool isHostDisconnected = false;
  
  String? shortCode;
  bool isGameEnded = false;
  String endMessage = '';
  List<List<int>> opponentBoardGrid = [];

  // Server properties
  HttpServer? _server;
  final List<WebSocket> _clients = [];

  // Client properties
  WebSocketChannel? _channel;

  // Start hosting a game
  Future<void> startHost(String username) async {
    isHost = true;
    localUsername = username;
    players = [{'name': username, 'isHost': true}];
    isGameStarted = false;
    
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
      if (interfaces.isNotEmpty) {
        hostIp = interfaces.first.addresses.first.address;
        shortCode = hostIp!.split('.').last;
      } else {
        hostIp = '127.0.0.1';
        shortCode = '1';
      }

      _server = await HttpServer.bind(InternetAddress.anyIPv4, hostPort);
      notifyListeners();

      _server!.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then(_handleClient);
        }
      });
    } catch (e) {
      debugPrint('Error starting host: $e');
    }
  }

  void _handleClient(WebSocket client) {
    _clients.add(client);
    client.listen((message) {
      final data = jsonDecode(message);
      _handleServerMessage(data, client);
    }, onDone: () {
      _clients.remove(client);
      // Remove player
      final disconnectedPlayerName = _getPlayerNameBySocket(client);
      players.removeWhere((p) => p['name'] == disconnectedPlayerName);
      _broadcast({'type': 'players_update', 'players': players});
      
      if (isGameStarted && players.length == 1) {
        isGameEnded = true;
        endMessage = 'You Win! Opponent Left';
        notifyListeners();
        _broadcast({'type': 'you_win', 'reason': 'Opponent Left'});
      } else {
        notifyListeners();
      }
    });
  }

  String _getPlayerNameBySocket(WebSocket client) {
    // In a real app we'd map socket to name, here we just guess it's the non-host if 2 players
    // For simplicity, we just rely on players count
    return 'Player';
  }

  void _handleServerMessage(Map<String, dynamic> data, WebSocket? sender) {
    if (data['type'] == 'join') {
      players.add({'name': data['name'], 'isHost': false});
      _broadcast({'type': 'players_update', 'players': players});
      notifyListeners();
    } else if (data['type'] == 'board_update') {
      opponentBoardGrid = List<List<int>>.from(data['board'].map((row) => List<int>.from(row)));
      notifyListeners();
      // Forward to other clients if more than 2 players, else just keep for host
      // Since host is also playing, host just saves it to opponentBoardGrid.
      // If we had 3 players, we'd broadcast to others.
    } else if (data['type'] == 'i_lost') {
      isGameEnded = true;
      endMessage = 'You Win!';
      notifyListeners();
      // Tell others someone died
      _broadcast({'type': 'you_win', 'reason': 'Opponent Lost!'});
    }
  }

  void _broadcast(Map<String, dynamic> data) {
    final message = jsonEncode(data);
    for (var client in _clients) {
      client.add(message);
    }
  }

  // Join a room
  Future<void> joinRoom(String ip, String username) async {
    isHost = false;
    localUsername = username;
    isGameStarted = false;
    isGameEnded = false;
    isHostDisconnected = false;
    endMessage = '';
    opponentBoardGrid = [];
    players = [];
    
    // Process short code
    if (!ip.contains('.')) {
      try {
        final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
        if (interfaces.isNotEmpty) {
          final myIp = interfaces.first.addresses.first.address;
          final parts = myIp.split('.');
          parts[3] = ip; // replace last part with short code
          ip = parts.join('.');
        }
      } catch (e) {
        debugPrint('IP parsing error: $e');
      }
    }
    hostIp = ip;
    notifyListeners();
    
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse('ws://$ip:$hostPort'));
      
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        _handleClientMessage(data);
      }, onDone: () {
        if (!isHost) {
          isHostDisconnected = true;
          if (isGameStarted && !isGameEnded) {
            isGameEnded = true;
            endMessage = 'Host Disconnected!';
          }
          notifyListeners();
        }
      });

      _send({'type': 'join', 'name': username});
    } catch (e) {
      debugPrint('Error joining room: $e');
    }
  }

  void _handleClientMessage(Map<String, dynamic> data) {
    if (data['type'] == 'players_update') {
      players = List<Map<String, dynamic>>.from(data['players']);
      notifyListeners();
    } else if (data['type'] == 'start_game') {
      isGameStarted = true;
      isGameEnded = false;
      notifyListeners();
    } else if (data['type'] == 'board_update') {
      opponentBoardGrid = List<List<int>>.from(data['board'].map((row) => List<int>.from(row)));
      notifyListeners();
    } else if (data['type'] == 'game_over') {
      isGameEnded = true;
      endMessage = 'You Win!';
      notifyListeners();
    } else if (data['type'] == 'you_win') {
      isGameEnded = true;
      endMessage = data['reason'] ?? 'You Win!';
      notifyListeners();
    }
  }

  void _send(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void startGame() {
    if (isHost) {
      isGameStarted = true;
      isGameEnded = false;
      _broadcast({'type': 'start_game'});
      notifyListeners();
    }
  }

  void sendBoard(List<List<int>> board) {
    if (isHost) {
      _broadcast({'type': 'board_update', 'board': board});
    } else {
      _send({'type': 'board_update', 'board': board});
    }
  }

  void sendGameOver() {
    isGameEnded = true;
    endMessage = 'GAME OVER';
    notifyListeners();

    if (isHost) {
      _broadcast({'type': 'you_win', 'reason': 'Opponent Lost!'});
    } else {
      _send({'type': 'i_lost'});
    }
  }

  void close() {
    _server?.close(force: true);
    _channel?.sink.close();
    for (var client in _clients) {
      client.close();
    }
    _clients.clear();
    players.clear();
    isHost = false;
    hostIp = null;
    isGameStarted = false;
    notifyListeners();
  }
}
