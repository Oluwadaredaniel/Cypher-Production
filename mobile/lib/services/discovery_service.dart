import 'package:nsd/nsd.dart';
import '../services/logging_service.dart';

class DiscoveryService {
  final _log = LoggingService();

  Future<void> findServers(Function(String name, String host, int port) onFound) async {
    _log.info('Starting mDNS discovery...');
    final discovery = await startDiscovery('_cypher._tcp.local.');

    discovery.addListener(() {
      for (final service in discovery.services) {
        if (service.host != null) {
          _log.info('Found CYPHER server: ${service.name} at ${service.host}');
          onFound(service.name ?? 'Unknown', service.host!, service.port ?? 5000);
        }
      }
    });

    // Stop discovery after some time if needed or keep it running
  }
}
