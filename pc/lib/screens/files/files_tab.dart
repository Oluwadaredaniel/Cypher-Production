import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../services/api_service.dart';

class FilesTab extends StatefulWidget {
  const FilesTab({super.key});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  List<dynamic> _sharedFolders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSharedFolders();
  }

  Future<void> _fetchSharedFolders() async {
    try {
      final res = await context.read<ApiService>().get('/files/shared');
      setState(() {
        _sharedFolders = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('File Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Manage folders shared with your mobile devices.', style: TextStyle(color: CypherColors.secondaryText)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SHARED FOLDERS',
                style: TextStyle(
                  color: CypherColors.tertiaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Add folder picker
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Folder'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_sharedFolders.isEmpty)
             _buildEmptyState()
          else
            Expanded(
              child: ListView.separated(
                itemCount: _sharedFolders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final folder = _sharedFolders[index];
                  return _buildFolderItem(folder);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(Map<String, dynamic> folder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CypherColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CypherColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open_rounded, color: CypherColors.warning),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(folder['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(folder['path'], style: const TextStyle(color: CypherColors.tertiaryText, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: CypherColors.error, size: 20),
            onPressed: () {
              // TODO: Remove folder logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_rounded, size: 64, color: CypherColors.tertiaryText.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No folders shared yet.', style: TextStyle(color: CypherColors.tertiaryText)),
        ],
      ),
    );
  }
}
