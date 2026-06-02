import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../files/guest_browser_screen.dart';

class GuestAccessScreen extends StatefulWidget {
  const GuestAccessScreen({super.key});

  @override
  State<GuestAccessScreen> createState() => _GuestAccessScreenState();
}

class _GuestAccessScreenState extends State<GuestAccessScreen> {
  String? _qrData;
  bool _isScanning = false;

  Future<void> _generateGuestLink() async {
    try {
      // 1. Show Folder Picker (Conceptual, using Downloads for now)
      final res = await context.read<ApiService>().post('/guest/create', body: {
        'folders': [r'C:\Users\hp\Downloads'],
        'duration': 15
      });
      setState(() => _qrData = res['qr_data']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Access'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            if (_isScanning)
              SizedBox(
                height: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: MobileScanner(
                    onDetect: (capture) {
                      final barcode = capture.barcodes.first.rawValue;
                      if (barcode != null && barcode.startsWith('cypher://')) {
                        setState(() => _isScanning = false);
                        _joinGuestSession(barcode);
                      }
                    },
                  ),
                ),
              )
            else if (_qrData != null)
              _buildQrView()
            else
              _buildMainView(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildModeCard(
          'Share My PC',
          'Let someone else access specific folders on your PC via QR code.',
          Icons.ios_share_rounded,
          _generateGuestLink,
        ),
        const SizedBox(height: 24),
        _buildModeCard(
          'Access a PC',
          'Scan a Cypher QR code to browse another computer.',
          Icons.qr_code_scanner_rounded,
          () => setState(() => _isScanning = true),
        ),
      ],
    );
  }

  Widget _buildModeCard(String title, String desc, IconData icon, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: CypherColors.primary),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: CypherColors.secondaryText, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildQrView() {
    return Column(
      children: [
        CustomCard(
          padding: const EdgeInsets.all(32),
          child: QrImageView(
            data: _qrData!,
            version: QrVersions.auto,
            size: 200.0,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: Colors.white),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.white),
          ),
        ),
        const SizedBox(height: 32),
        const Text('GUEST ACCESS READY', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('Valid for 15 minutes', style: TextStyle(color: CypherColors.warning)),
        const SizedBox(height: 48),
        CustomButton(text: 'Stop Sharing', onPressed: () => setState(() => _qrData = null), backgroundColor: CypherColors.tertiaryBackground),
      ],
    );
  }

  void _joinGuestSession(String uri) {
    // Parse cypher://ip:port/guest?token=xyz
    final parts = uri.replaceFirst('cypher://', '').split('?');
    final host = parts[0].split('/')[0];
    final token = parts[1].replaceFirst('token=', '');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuestBrowserScreen(baseUrl: 'http://$host', token: token),
      ),
    );
  }
}
