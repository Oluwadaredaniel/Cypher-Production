import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  void addNotification(Map<String, dynamic> notif) {
    _notifications.insert(0, notif);
    if (_notifications.length > 50) _notifications.removeLast();
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}
