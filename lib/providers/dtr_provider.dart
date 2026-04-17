import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../models/dtr.dart';

class DtrProvider extends ChangeNotifier {
  final Dio _dio = ApiConfig.createDio();
  TodayDtr? _today;
  List<DailyTimeRecord> _history = [];
  bool _loading = false;
  String? _error;
  String? _message;

  TodayDtr? get today => _today;
  List<DailyTimeRecord> get history => _history;
  bool get loading => _loading;
  String? get error => _error;
  String? get message => _message;

  Future<void> fetchToday() async {
    try {
      final res = await _dio.get('/dtr/today');
      final data = res.data['data'];
      _today = data != null ? TodayDtr.fromJson(data) : TodayDtr(isClockedIn: false);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> clockIn() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.post('/dtr/clock-in');
      _message = res.data['message'];
      await fetchToday();
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Clock in failed.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clockOut() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.post('/dtr/clock-out');
      _message = res.data['message'];
      await fetchToday();
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Clock out failed.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchHistory({int? month, int? year}) async {
    try {
      final now = DateTime.now();
      final res = await _dio.get('/dtr', queryParameters: {
        'month': month ?? now.month,
        'year': year ?? now.year,
      });
      _history = (res.data['data'] as List)
          .map((d) => DailyTimeRecord.fromJson(d))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<List<DailyTimeRecord>> fetchRange(DateTime start, DateTime end) async {
    try {
      final res = await _dio.get('/dtr', queryParameters: {
        'month': start.month,
        'year': start.year,
      });
      return (res.data['data'] as List)
          .map((d) => DailyTimeRecord.fromJson(d))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
