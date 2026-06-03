import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  Logger _logger = Logger();
  File? _logFile;

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal() {
    _initializeLogger();
  }

  Future<void> _initializeLogger() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logPath = '${directory.path}/logs';
      final logDir = Directory(logPath);

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toString().split('.')[0].replaceAll(':', '-');
      _logFile = File('$logPath/cypher_$timestamp.log');

      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTime,
        ),
      );
    } catch (e) {
      // Fallback logger if file initialization fails
      _logger = Logger();
    }
  }

  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message);
    _writeToFile('[DEBUG] $message');
  }

  void info(String message) {
    _logger.i(message);
    _writeToFile('[INFO] $message');
  }

  void warning(String message) {
    _logger.w(message);
    _writeToFile('[WARN] $message');
  }

  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    _writeToFile('[ERROR] $message - $error');
  }

  void critical(String message) {
    _logger.f(message);
    _writeToFile('[CRITICAL] $message');
  }

  Future<void> _writeToFile(String message) async {
    if (_logFile == null) return;
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _logFile!.writeAsString(
        '[$timestamp] $message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      _logger.e('Failed to write log', error: e);
    }
  }

  Future<String> getLogContent() async {
    if (_logFile == null) return 'Log file not initialized';
    return await _logFile!.readAsString();
  }

  Future<void> cleanOldLogs() async {
    if (_logFile == null) return;
    final logDir = _logFile!.parent;
    final files = logDir.listSync();
    final now = DateTime.now();

    for (var file in files) {
      if (file is File) {
        final stat = file.statSync();
        final age = now.difference(stat.changed);
        if (age.inDays > 7) {
          file.deleteSync();
        }
      }
    }
  }
}
