import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../models/announcement.dart';

class AnnouncementProvider extends ChangeNotifier {
  final Dio _dio = ApiConfig.createDio();
  List<Announcement> _announcements = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;

  List<Announcement> get announcements => _announcements;
  bool get loading => _loading;
  bool get hasMore => _hasMore;

  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _announcements = [];
    }
    if (!_hasMore || _loading) return;

    _loading = true;
    notifyListeners();

    try {
      final res = await _dio.get('/announcements', queryParameters: {'page': _page});
      final list = (res.data['data'] as List)
          .map((a) => Announcement.fromJson(a))
          .toList();
      _announcements.addAll(list);
      _hasMore = res.data['has_more'] ?? false;
      _page++;
      _loading = false;
      notifyListeners();
    } catch (_) {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> post({required String title, required String body, bool isPinned = false, File? image}) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'body': body,
        'is_pinned': isPinned ? '1' : '0',
        if (image != null) 'image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
      });
      await _dio.post('/announcements', data: formData, options: Options(contentType: 'multipart/form-data'));
      await fetchFeed(refresh: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> react(int announcementId, String type) async {
    try {
      await _dio.post('/announcements/$announcementId/react', data: {'type': type});
      await fetchFeed(refresh: true);
    } catch (_) {}
  }

  Future<bool> comment(int announcementId, String body, {int? parentId}) async {
    try {
      await _dio.post('/announcements/$announcementId/comment', data: {
        'body': body,
        if (parentId != null) 'parent_id': parentId,
      });
      // Re-fetch to show new comment
      await fetchFeed(refresh: true);
      return true;
    } catch (_) {
      return false;
    }
  }
}
