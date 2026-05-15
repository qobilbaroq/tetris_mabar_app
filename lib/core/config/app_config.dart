
import 'dart:io';

class AppConfig {
  static const String serverPort = '8080';
  static const String serverPath = '/ws';
  
  static const List<String> fallbackIPs = [
    '192.168.1.11',    
    'localhost',       
    '192.168.1.1',     
    '192.168.1.100', 
  ];

  static Future<String> getServerUrl() async {
    try {
      final ip = await _detectLocalServerIP();
      if (ip != null) {
        return 'ws://$ip:$serverPort$serverPath';
      }
    } catch (e) {
      print('Auto-detect IP failed: $e, using fallback');
    }
    
    // Fallback to default
    return 'ws://${fallbackIPs.first}:$serverPort$serverPath';
  }

  static Future<String?> _detectLocalServerIP() async {
    try {
      final interfaces = await NetworkInterface.list();
      
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4) {
            final ip = address.address;
            
            if (ip.startsWith('127.')) continue;
            
            final parts = ip.split('.');
            if (parts.length == 4) {
              parts[3] = '11';
              final serverIP = parts.join('.');
              
              if (await _isServerReachable(serverIP)) {
                return serverIP;
              }
              
              for (int i = 10; i <= 20; i++) {
                if (i == 11) continue;
                parts[3] = i.toString();
                final candidateIP = parts.join('.');
                
                if (await _isServerReachable(candidateIP)) {
                  return candidateIP;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error detecting local IP: $e');
    }
    
    return null;
  }

  static Future<bool> _isServerReachable(String ip) async {
    try {
      final socket = await Socket.connect(
        ip,
        int.parse(serverPort),
        timeout: const Duration(seconds: 1),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static const String serverUrl = 'ws://192.168.1.11:8080/ws';
}
