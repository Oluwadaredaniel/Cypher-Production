import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/theme/cypher_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/system_provider.dart';
import 'providers/file_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/logging_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Setup Structured Logging
  final logger = LoggingService();
  logger.info('Initializing Cypher Production Mobile...');

  // 2. Setup Persistent Storage
  final storage = await StorageService.init();

  // 3. Initialize API Service
  final api = ApiService();

  // 4. Initialize Production Monitoring (GlitchTip - Sentry-compatible)
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://011915baf51240f19f98c283a67fece4@app.glitchtip.com/24279';
      options.environment = 'production';
      options.release = '1.0.0+1';
      options.tracesSampleRate = 0.1;
      options.beforeSend = (event, {hint}) {
        if (event.request != null) {
          event.request!.headers?.remove('X-Auth-Token');
        }
        return event;
      };
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          Provider.value(value: api),
          Provider.value(value: storage),
          Provider.value(value: logger),
          ChangeNotifierProvider(create: (_) => AuthProvider(api, storage)),
          ChangeNotifierProxyProvider<AuthProvider, SystemProvider>(
            create: (context) => SystemProvider(context.read<ApiService>()),
            update: (context, auth, previous) => previous!..fetchStatus(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, FileProvider>(
            create: (context) => FileProvider(context.read<ApiService>()),
            update: (context, auth, previous) => previous!,
          ),
        ],
        child: const CypherApp(),
      ),
    ),
  );
}

class CypherApp extends StatelessWidget {
  const CypherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CYPHER',
      debugShowCheckedModeBanner: false,
      theme: CypherTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
