# MONITORING STANDARDS FOR CYPHER

Use Sentry for production error tracking.

## MOBILE & PC APP (Flutter)

### Configuration
Add to `pubspec.yaml`:
```yaml
sentry_flutter: ^7.0.0
```

### main.dart Setup
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://YOUR_SENTRY_DSN@sentry.io/PROJECT_ID';
      options.environment = kDebugMode ? 'dev' : 'production';
      options.release = '1.0.0+1'; // Match pubspec version
      
      // Don't send logs from dev
      options.enabled = !kDebugMode;
      
      // Capture 100% of transactions in dev, 10% in production
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
      
      // Before sending error, sanitize it
      options.beforeSend = (event, hint) async {
        // Remove sensitive data
        event.request?.headers?.remove('authorization');
        return event;
      };
    },
    appRunner: () => runApp(const CypherApp()),
  );
}
```

### Error Capture
```dart
try {
  await fileDownload();
} catch (exception, stackTrace) {
  await Sentry.captureException(
    exception,
    stackTrace: stackTrace,
    hint: Hint.withMap({
      'file': fileName,
      'size': fileSize,
      'attempt': retryCount,
    }),
  );
  rethrow;
}
```

---

## BACKEND (Python)

### Installation
```bash
pip install sentry-sdk
```

### server.py Setup
```python
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

sentry_sdk.init(
    dsn="https://YOUR_SENTRY_DSN@sentry.io/PROJECT_ID",
    integrations=[FlaskIntegration()],
    traces_sample_rate=0.1,
    environment="production",
    release="1.0.0",
)
```

### Error Capture
```python
try:
    response = process_file_upload()
except Exception as e:
    sentry_sdk.capture_exception(e, extra={
        'file_size': file_size,
        'user_id': device_id,
    })
```

---

## MONITORING DASHBOARD
1. Go to [sentry.io](https://sentry.io)
2. Create a free account.
3. Add both projects (mobile + backend).
4. Set up alerts for critical errors.
5. Weekly email digest of top issues.
