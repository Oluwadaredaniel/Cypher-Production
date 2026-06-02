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

  // Initialize Logging
  final logger = LoggingService();
  logger.info('Starting CYPHER Mobile - Production Grade');

  final storage = await StorageService.init();
  final api = ApiService();

  // Initialize Sentry for Error Tracking & Analytics
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://example@sentry.io/123';
      options.tracesSampleRate = 1.0;
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
