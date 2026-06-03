# MONITORING STANDARDS FOR CYPHER

We use **GlitchTip** (Sentry-compatible) for error tracking and **OneUptime** for status monitoring and heartbeats.

## 1. Error Tracking (GlitchTip)
GlitchTip is used to capture crashes and performance data. Since it is Sentry-compatible, we use the standard Sentry SDKs.

### MOBILE & PC APP (Flutter)
Add to `pubspec.yaml`:
```yaml
sentry_flutter: ^7.0.0
```

`main.dart` Setup:
```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'https://YOUR_GLITCHTIP_DSN';
    options.environment = 'production';
  },
  appRunner: () => runApp(const CypherApp()),
);
```

### BACKEND (Python)
Install: `pip install sentry-sdk`

`server.py` Setup:
```python
import sentry_sdk
sentry_sdk.init(
    dsn="https://YOUR_GLITCHTIP_DSN",
    traces_sample_rate=0.1,
    environment="production",
)
```

---

## 2. Status & Heartbeats (OneUptime)
We use OneUptime to track server availability and "Install Heartbeats".

### Backend Heartbeat
Every time the server starts or stays alive, it pings OneUptime.

```python
import requests
def ping_oneuptime():
    try:
        requests.get("https://oneuptime.com/api/heartbeat/YOUR_HEARTBEAT_ID")
    except:
        pass
```

### Monitoring Dashboard
1. **GlitchTip**: View errors, stack traces, and adoption rates.
2. **OneUptime**: View global uptime and get alerted if the backend "heartbeat" stops.
