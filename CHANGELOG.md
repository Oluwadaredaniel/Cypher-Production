# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-06-03

### Initial Production Release

#### Added
- **Instant Local Discovery**: Auto-find PC on the network using mDNS.
- **Secure 6-Digit Pairing**: Handshake with cryptographically secure tokens.
- **Unified Activity Log**: Real-time audit of every command and connection.
- **Remote Control**: Shutdown, restart, sleep, and workstation lock.
- **App Launcher**: List and launch Windows apps from the phone.
- **Process Manager**: Monitor and kill PC processes.
- **Bidirectional File Transfer**: Local streaming for any file size.
- **Clipboard Sync**: Two-way text sync between PC and phone.
- **Guest Access**: QR-code based temporary sharing with web and app UI.
- **Live Monitoring**: CPU/RAM usage graphs and battery status.

#### Visuals
- Premium Dark Theme across all platforms.
- Animated Splash screens and Onboarding flows.
- Connection Lost recovery screens.

#### Technical
- Python Flask + Socket.IO Backend.
- Flutter Mobile (Android/iOS) and Desktop (Windows) apps.
- Daily rotating structured JSON logging.
- Sentry integration for error tracking.
