# AUTO-UPDATE SYSTEM FOR CYPHER

---

## MOBILE (Android)

### Option 1: Firebase App Distribution (Recommended)
- Free tier: 500 testers
- Can trigger in-app update notifications
- Automatic version checking

### Implementation
Add to `pubspec.yaml`:
```yaml
in_app_update: ^4.1.0
```

`lib/services/update_service.dart`:
```dart
import 'package:in_app_update/in_app_update.dart';

class UpdateService {
  static Future<void> checkForUpdates() async {
    try {
      final info = await InAppUpdate.checkForFlexibleUpdate();
      if (info.updateAvailable) {
        await InAppUpdate.performFlexibleUpdate();
        // Show "Restart" button after download
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      // Log warning: Update check failed
    }
  }
}
```

Check on app start in `initState()`:
```dart
void initState() {
  super.initState();
  UpdateService.checkForUpdates();
}
```

---

## PC (Windows)

### GitHub Releases (Free)
Host APK and EXE on GitHub releases and check version against API.

`pc/lib/services/update_service.dart` (Concept):
```dart
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String GITHUB_API = "https://api.github.com/repos/Oluwadaredaniel/Cypher/releases/latest";

  static Future<void> checkUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    
    // Call GitHub API, compare version, show dialog if update available
  }
}
```

---

## VERSIONING STRATEGY
Format: **MAJOR.MINOR.PATCH+BUILD**
Example: `1.0.0+1`, `1.1.0+5`

- **PATCH**: Bug fixes
- **MINOR**: New features
- **MAJOR**: Breaking changes
- **BUILD**: Incremented for every release (automated)

---

## DEPLOYMENT CHECKLIST
- ☐ Update version in `pubspec.yaml`
- ☐ Update version in `server.py`
- ☐ Write release notes (user-friendly)
- ☐ Create GitHub release tag
- ☐ Upload APK and EXE files
- ☐ Test update on device/PC
- ☐ Announce on X/Twitter
- ☐ Monitor Sentry for issues
