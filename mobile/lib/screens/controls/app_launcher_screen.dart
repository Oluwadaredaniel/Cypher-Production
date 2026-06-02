import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_card.dart';

class AppLauncherScreen extends StatefulWidget {
  const AppLauncherScreen({super.key});

  @override
  State<AppLauncherScreen> createState() => _AppLauncherScreenState();
}

class _AppLauncherScreenState extends State<AppLauncherScreen> {
  List<dynamic> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApps();
  }

  Future<void> _fetchApps() async {
    try {
      final res = await context.read<ApiService>().get('/apps');
      setState(() {
        _apps = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchApp(String path) async {
    try {
      await context.read<ApiService>().post('/apps/launch', body: {'path': path});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App launched successfully')));
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Launcher'), backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                final app = _apps[index];
                return GestureDetector(
                  onTap: () => _launchApp(app['path']),
                  child: Column(
                    children: [
                      CustomCard(
                        padding: const EdgeInsets.all(12),
                        child: const Icon(Icons.apps_rounded, color: CypherColors.primary, size: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app['name'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
