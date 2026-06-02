import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class ClipboardScreen extends StatefulWidget {
  const ClipboardScreen({super.key});

  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends State<ClipboardScreen> {
  String _pcClipboard = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPcClipboard();
  }

  Future<void> _fetchPcClipboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await context.read<ApiService>().get('/clipboard');
      setState(() => _pcClipboard = response['content'] ?? '');
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncToPc() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      try {
        await context.read<ApiService>().post('/clipboard', body: {'text': data!.text});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone clipboard synced to PC'), backgroundColor: CypherColors.success),
          );
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clipboard Sync'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PC CLIPBOARD', style: _labelStyle),
            const SizedBox(height: 16),
            Expanded(
              child: CustomCard(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _pcClipboard.isEmpty ? 'Clipboard is empty' : _pcClipboard,
                          style: const TextStyle(color: CypherColors.primaryText, fontFamily: 'monospace'),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Refresh PC',
                    onPressed: _fetchPcClipboard,
                    backgroundColor: CypherColors.tertiaryBackground,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Copy to Phone',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _pcClipboard));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to phone')));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Sync Phone Clipboard to PC',
              onPressed: _syncToPc,
              icon: Icons.sync,
            ),
          ],
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    color: CypherColors.tertiaryText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}
