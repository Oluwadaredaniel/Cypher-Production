# LOGGING STANDARDS FOR CYPHER

## REQUIREMENTS
- Log to file AND console
- Different log levels: DEBUG, INFO, WARN, ERROR, CRITICAL
- Timestamps on every log
- Environment-aware (dev/staging/production)
- No sensitive data in logs
- Structured logging (JSON format for analysis)

---

## MOBILE APP (Flutter)
Implement using 'logger' package.

### Configuration
Add to `pubspec.yaml`:
```yaml
logger: ^2.0.0
```

### Implementation (`mobile/lib/services/logging_service.dart`)
```dart
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  late Logger _logger;
  late File _logFile;

  factory LoggingService() {
    return _instance;
  }

  LoggingService._internal() {
    _initializeLogger();
  }

  Future<void> _initializeLogger() async {
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
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceAppStart,
      ),
    );
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
    try {
      final timestamp = DateTime.now().toIso8601String();
      await _logFile.writeAsString(
        '[$timestamp] $message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      _logger.e('Failed to write log', error: e);
    }
  }

  // Get logs for diagnostics
  Future<String> getLogContent() async {
    return await _logFile.readAsString();
  }

  // Clear old logs (keep last 7 days)
  Future<void> cleanOldLogs() async {
    final logDir = _logFile.parent;
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
```

---

## PC APP (Flutter)
Same structure as the Mobile App in `pc/lib/services/logging_service.dart`.

---

## BACKEND (Python)
Create `backend/core/services/logging_service.py`:

```python
import logging
import json
from datetime import datetime
from pathlib import Path

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        
        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)
        
        return json.dumps(log_data)

def setup_logging(app_name='cypher', log_level=logging.INFO):
    log_dir = Path.home() / '.cypher' / 'logs'
    log_dir.mkdir(parents=True, exist_ok=True)
    
    logger = logging.getLogger(app_name)
    logger.setLevel(log_level)
    
    # File handler (JSON)
    fh = logging.FileHandler(log_dir / f'{app_name}.log')
    fh.setFormatter(JSONFormatter())
    
    # Console handler (human readable)
    ch = logging.StreamHandler()
    ch.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    
    logger.addHandler(fh)
    logger.addHandler(ch)
    
    return logger
```

---

## STANDARDS
- ❌ Never log passwords, tokens, or auth credentials
- ❌ Never log full file paths in production
- ❌ Never log sensitive user data
- ✓ Always log errors with context
- ✓ Always log important state changes
- ✓ Use structured logging (JSON) for backend
- ✓ Rotate logs daily
