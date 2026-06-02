import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../services/discovery_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import 'pairing_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final DiscoveryService _discovery = DiscoveryService();
  final List<DiscoveredServer> _servers = [];
  bool _isSearching = true;

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

  void _startSearch() {
    setState(() {
      _servers.clear();
      _isSearching = true;
    });

    _discovery.findServers((name, host, port) {
      if (!mounted) return;
      if (!_servers.any((s) => s.host == host)) {
        setState(() {
          _servers.add(DiscoveredServer(name: name, host: host, port: port));
        });
      }
    });

    // Auto-stop searching UI after 10s
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) setState(() => _isSearching = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PairingScreen())),
            child: const Text('Manual IP', style: TextStyle(color: CypherColors.primary)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'Searching for PCs',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure Cypher is running on your PC and both devices are on the same WiFi.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            if (_isSearching && _servers.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: CypherColors.primary),
                      const SizedBox(height: 24),
                      Text('Scanning network...', style: TextStyle(color: CypherColors.secondaryText)),
                    ],
                  ),
                ),
              )
            else if (_servers.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 64, color: CypherColors.tertiaryText),
                      const SizedBox(height: 16),
                      const Text('No PCs found automatically'),
                      const SizedBox(height: 24),
                      CustomButton(text: 'Try Again', onPressed: _startSearch),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final server = _servers[index];
                    return FadeInRight(
                      delay: Duration(milliseconds: index * 100),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CustomCard(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PairingScreen(initialIp: server.host),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: CypherColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.computer_rounded, color: CypherColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(server.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(server.host, style: const TextStyle(color: CypherColors.secondaryText, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: CypherColors.tertiaryText),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DiscoveredServer {
  final String name;
  final String host;
  final int port;
  DiscoveredServer({required this.name, required this.host, required this.port});
}
