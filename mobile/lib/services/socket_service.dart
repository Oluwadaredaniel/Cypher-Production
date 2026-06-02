import 'package:socket_io_client/socket_io_client.dart' as io;
import '../services/logging_service.dart';

class SocketService {
  io.Socket? _socket;
  final LoggingService _log = LoggingService();

  void connect(String ip, String token, {Function(Map<String, dynamic>)? onStats, Function(Map<String, dynamic>)? onEvent}) {
    _socket = io.io('http://$ip:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'extraHeaders': {'X-Auth-Token': token}
    });

    _socket!.onConnect((_) {
      _log.info('WebSocket Connected');
    });

    _socket!.on('system_stats', (data) {
      if (onStats != null) onStats(Map<String, dynamic>.from(data));
    });

    _socket!.on('log_event', (data) {
      if (onEvent != null) onEvent(Map<String, dynamic>.from(data));
    });

    _socket!.onDisconnect((_) => _log.warning('WebSocket Disconnected'));
  }

  void disconnect() {
    _socket?.disconnect();
  }
}
