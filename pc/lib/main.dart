import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/cypher_theme.dart';
import 'providers/system_provider.dart';
import 'services/api_service.dart';
import 'services/logging_service.dart';
import 'screens/dashboard/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Logging
  final logger = LoggingService();
  logger.info('Starting CYPHER PC Dashboard');

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1000, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'CYPHER PC',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final api = ApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: logger),
        ChangeNotifierProvider(create: (_) => SystemProvider(api)),
      ],
      child: const CypherPCApp(),
    ),
  );
}

class CypherPCApp extends StatelessWidget {
  const CypherPCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CYPHER',
      debugShowCheckedModeBanner: false,
      theme: CypherTheme.darkTheme,
      home: const PCSplashScreen(),
    );
  }
}
