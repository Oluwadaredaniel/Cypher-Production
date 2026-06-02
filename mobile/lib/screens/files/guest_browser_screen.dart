import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
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

  Future<void> _downloadFile(String path, String name) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading $name...')));
      final url = Uri.parse('${widget.baseUrl}/guest/files/download').replace(queryParameters: {
        'token': widget.token,
        'path': path,
      });
      final res = await http.get(url);

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$name');
      await file.writeAsBytes(res.bodyBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saved to: ${file.path}'),
          backgroundColor: CypherColors.success,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('${widget.baseUrl}/guest/files/upload').replace(queryParameters: {
        'token': widget.token,
      });

      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', result.files.single.path!));

      final response = await request.send();
      if (response.statusCode == 200) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful'), backgroundColor: CypherColors.success));
        _fetchFiles(_currentPath);
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isLoading = false);
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
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _uploadFile),
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
                    onTap: () => _fetchFiles(),
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
                        trailing: isFolder ? null : IconButton(
                          icon: const Icon(Icons.download, size: 20),
                          onPressed: () => _downloadFile(item['path'], item['name']),
                        ),
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
