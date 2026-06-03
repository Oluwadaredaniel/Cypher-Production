import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

import '../navigation_wrapper.dart';

class PairingScreen extends StatefulWidget {
  final String? initialIp;
  const PairingScreen({super.key, this.initialIp});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  late final TextEditingController _ipController;
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.initialIp);
  }

  Future<void> _handlePairing() async {
    if (_ipController.text.isEmpty || _codeController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final success = await context.read<AuthProvider>().pair(
            _ipController.text.trim(),
            _codeController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const NavigationWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: CypherColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'Pair with PC',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the IP address and pairing code shown on your PC app.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  hintText: 'PC IP Address (e.g. 192.168.1.10)',
                  labelText: 'IP Address',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  hintText: '6-digit code',
                  labelText: 'Pairing Code',
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const Spacer(),
              CustomButton(
                text: 'Connect to PC',
                isLoading: _isLoading,
                onPressed: _handlePairing,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
