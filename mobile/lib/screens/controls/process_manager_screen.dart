import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';

class ProcessManagerScreen extends StatefulWidget {
  const ProcessManagerScreen({super.key});

  @override
  State<ProcessManagerScreen> createState() => _ProcessManagerScreenState();
}

class _ProcessManagerScreenState extends State<ProcessManagerScreen> {
  List<dynamic> _processes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProcesses();
  }

  Future<void> _fetchProcesses() async {
    try {
      final res = await context.read<ApiService>().get('/processes');
      setState(() {
        _processes = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _killProcess(int pid) async {
    try {
      await context.read<ApiService>().post('/processes/kill', body: {'pid': pid});
      _fetchProcesses();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Manager'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchProcesses)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _processes.length,
              itemBuilder: (context, index) {
                final proc = _processes[index];
                return ListTile(
                  title: Text(proc['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('PID: ${proc['pid']} | CPU: ${proc['cpu']}% | RAM: ${proc['ram']} MB'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, color: CypherColors.error),
                    onPressed: () => _killProcess(proc['pid']),
                  ),
                );
              },
            ),
    );
  }
}
