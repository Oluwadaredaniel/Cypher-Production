import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FileProvider extends ChangeNotifier {
  final ApiService _api;

  List<dynamic> _items = [];
  List<dynamic> get items => _items;

  List<String> _breadcrumb = ['Home'];
  List<String> get breadcrumb => _breadcrumb;

  String _currentPath = '';
  String get currentPath => _currentPath;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FileProvider(this._api);

  Future<void> browse(String? path) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (path == null || path.isEmpty) {
        final response = await _api.get('/files');
        _items = response;
        _breadcrumb = ['Home'];
        _currentPath = '';
      } else {
        final response = await _api.get('/files/browse', queryParams: {'path': path});
        _items = response;
        _currentPath = path;

        // Update breadcrumb (simplified for now)
        final parts = path.split(RegExp(r'[/\\]')).where((p) => p.isNotEmpty).toList();
        _breadcrumb = ['Home', ...parts];
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadFile(String localPath) async {
    if (_currentPath.isEmpty) return; // Can't upload to root
    await _api.upload('/files/upload', localPath, _currentPath);
    await browse(_currentPath);
  }
}
