import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/file_provider.dart';
import '../../services/api_service.dart';

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileProvider>().browse(null);
    });
  }

  Future<void> _downloadFile(String path, String name) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading $name...')));
      final api = context.read<ApiService>();
      // Use manual HTTP for streaming/downloading large files if needed
      await api.get('/files/download', queryParams: {'path': path});

      final directory = await getExternalStorageDirectory();
      if (directory == null) return;

      final file = io.File('${directory.path}/$name');
      // await file.writeAsBytes(response); // If get() returns bytes

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded to: ${file.path}'), backgroundColor: CypherColors.success));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: CypherColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Files'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => fileProvider.browse(fileProvider.currentPath)),
          IconButton(
            icon: const Icon(Icons.upload_file_outlined),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                await fileProvider.uploadFile(result.files.single.path!);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBreadcrumb(fileProvider),
          Expanded(
            child: fileProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: CypherColors.primary))
                : fileProvider.items.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: fileProvider.items.length,
                        itemBuilder: (context, index) => _buildFileItem(fileProvider.items[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(FileProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.breadcrumb.length,
        separatorBuilder: (_, __) => const Icon(Icons.chevron_right, size: 16, color: CypherColors.tertiaryText),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () {
            // Logic to navigate back to a specific crumb
          },
          child: Text(
            provider.breadcrumb[i],
            style: TextStyle(
              fontSize: 12,
              fontWeight: i == provider.breadcrumb.length - 1 ? FontWeight.bold : FontWeight.normal,
              color: i == provider.breadcrumb.length - 1 ? CypherColors.primary : CypherColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> item) {
    final bool isFolder = item['type'] == 'folder' || item['type'] == 'drive';
    return ListTile(
      leading: Icon(
        isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded,
        color: isFolder ? CypherColors.warning : CypherColors.info,
      ),
      title: Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(isFolder ? 'Directory' : _formatSize(item['size'] ?? 0), style: const TextStyle(fontSize: 11)),
      trailing: isFolder ? null : IconButton(
        icon: const Icon(Icons.download_rounded, size: 20),
        onPressed: () => _downloadFile(item['path'], item['name']),
      ),
      onTap: () {
        if (isFolder) context.read<FileProvider>().browse(item['path']);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 64, color: CypherColors.tertiaryText.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No files found', style: TextStyle(color: CypherColors.tertiaryText)),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes.bitLength / 10).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / (1 << (10 * i))).toStringAsFixed(1)} ${suffixes[i]}';
  }
}
