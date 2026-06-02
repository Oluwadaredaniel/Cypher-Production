import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<dynamic> _history = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await context.read<ApiService>().get('/history');
      setState(() => _history = response);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History'), backgroundColor: Colors.transparent, elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _history.length,
              separatorBuilder: (_, __) => const Divider(color: CypherColors.cardBorder, height: 32),
              itemBuilder: (context, index) {
                final item = _history[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item['success'] ? CypherColors.success.withOpacity(0.1) : CypherColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['success'] ? Icons.check : Icons.close,
                        size: 16,
                        color: item['success'] ? CypherColors.success : CypherColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['endpoint'].toString().toUpperCase().replaceAll('/', ' '),
                            style: const TextStyle(color: CypherColors.primaryText, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['timestamp'],
                            style: const TextStyle(color: CypherColors.tertiaryText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
