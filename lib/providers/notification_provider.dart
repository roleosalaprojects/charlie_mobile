import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';

class NotificationProvider extends ChangeNotifier {
  final Dio _dio = ApiConfig.createDio();
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  Future<void> fetchUnreadCount() async {
    try {
      final res = await _dio.get('/notifications');
      _unreadCount = res.data['unread_count'] ?? 0;
      notifyListeners();
    } catch (_) {}
  }
}
