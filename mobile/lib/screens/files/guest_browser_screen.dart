import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/colors.dart';
import '../../widgets/custom_card.dart';

class GuestBrowserScreen extends StatefulWidget {
  final String baseUrl;
  final String token;

  const GuestBrowserScreen({super.key, required this.baseUrl, required this.token});

  @override
  State<GuestBrowserScreen> createState() => _GuestBrowserScreenState();
}

class _GuestBrowserScreenState extends State<GuestBrowserScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles([String? path]) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${widget.baseUrl}/guest/files').replace(queryParameters: {
        'token': widget.token,
        if (path != null) 'path': path,
      });
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          _items = jsonDecode(res.body);
          _currentPath = path ?? '';
          _isLoading = false;
        });
      } else {
        throw Exception('Access Denied or Expired');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Browser'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
           const Center(
             child: Padding(
               padding: EdgeInsets.only(right: 16.0),
               child: Icon(Icons.timer_outlined, size: 16, color: CypherColors.warning),
             ),
           ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: CypherColors.primary))
          : Column(
              children: [
                if (_currentPath.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.arrow_back, size: 18),
                    title: const Text('Go Back', style: TextStyle(fontSize: 13)),
                    onTap: () => _fetchFiles(), // Simple back to root for now
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isFolder = item['type'] == 'folder';
                      return ListTile(
                        leading: Icon(
                          isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
                          color: isFolder ? CypherColors.warning : CypherColors.info,
                        ),
                        title: Text(item['name'], style: const TextStyle(fontSize: 14)),
                        onTap: () {
                          if (isFolder) _fetchFiles(item['path']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
