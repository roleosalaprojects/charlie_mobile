import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Dio _dio = ApiConfig.createDio();
  List<dynamic> _notifications = [];
  int _unreadCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/notifications');
      _notifications = res.data['data'] ?? [];
      _unreadCount = res.data['unread_count'] ?? 0;
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _markAllRead() async {
    try {
      await _dio.post('/notifications/mark-read');
      _fetch();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_unreadCount > 0)
            TextButton(onPressed: _markAllRead, child: const Text('Mark all read', style: TextStyle(fontSize: 13))),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? EmptyState(icon: Icons.notifications_none_rounded, title: 'No notifications', onAction: _fetch)
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (_, i) {
                      final n = _notifications[i];
                      final isRead = n['read'] == true;
                      return Card(
                        color: isRead ? null : AppColors.primary.withValues(alpha: 0.04),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: isRead ? Colors.grey[200] : AppColors.primary.withValues(alpha: 0.15),
                            child: Icon(
                              _iconFor(n['type']),
                              size: 18,
                              color: isRead ? Colors.grey[500] : AppColors.primary,
                            ),
                          ),
                          title: Text(n['message'] ?? '', style: TextStyle(fontSize: 13, fontWeight: isRead ? FontWeight.w400 : FontWeight.w600)),
                          subtitle: Text(n['time_ago'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          dense: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _iconFor(String? type) {
    switch (type) {
      case 'leave':
        return Icons.event_note;
      case 'payroll':
        return Icons.receipt_long;
      case 'overtime':
        return Icons.schedule;
      default:
        return Icons.notifications_outlined;
    }
  }
}
