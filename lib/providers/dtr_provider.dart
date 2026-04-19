import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../config/api.dart';
import '../models/dtr.dart';

class DtrProvider extends ChangeNotifier {
  final Dio _dio = ApiConfig.createDio();
  TodayDtr? _today;
  List<DailyTimeRecord> _history = [];
  bool _loading = false;
  String? _error;
  String? _message;
  bool _hasPendingSync = false;
  String? _pendingAction; // 'clock-in' or 'clock-out'
  DateTime? _pendingTime;

  TodayDtr? get today => _today;
  List<DailyTimeRecord> get history => _history;
  bool get loading => _loading;
  String? get error => _error;
  String? get message => _message;
  bool get hasPendingSync => _hasPendingSync;

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> fetchToday() async {
    try {
      final res = await _dio.get('/dtr/today');
      final data = res.data['data'];
      final isClockedIn = res.data['clocked_in'] ?? false;
      _today = data != null
          ? TodayDtr.fromJson({...data, 'is_clocked_in': isClockedIn})
          : TodayDtr(isClockedIn: false);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> clockIn() async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (!await _isOnline()) {
      // Queue offline
      _pendingAction = 'clock-in';
      _pendingTime = DateTime.now();
      _hasPendingSync = true;
      _message = 'Clocked in offline at ${_pendingTime!.hour.toString().padLeft(2, '0')}:${_pendingTime!.minute.toString().padLeft(2, '0')}. Will sync when online.';
      _today = TodayDtr(clockIn: _formatTime(_pendingTime!), isClockedIn: true);
      _loading = false;
      notifyListeners();
      return true;
    }

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

    if (!await _isOnline()) {
      _pendingAction = 'clock-out';
      _pendingTime = DateTime.now();
      _hasPendingSync = true;
      _message = 'Clocked out offline at ${_formatTime(_pendingTime!)}. Will sync when online.';
      _today = TodayDtr(
        clockIn: _today?.clockIn,
        clockOut: _formatTime(_pendingTime!),
        isClockedIn: false,
      );
      _loading = false;
      notifyListeners();
      return true;
    }

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

  Future<bool> breakOut() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.post('/dtr/break-out');
      _message = res.data['message'];
      await fetchToday();
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Break out failed.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> breakIn() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.post('/dtr/break-in');
      _message = res.data['message'];
      await fetchToday();
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Break in failed.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  /// Try to sync any pending offline clock action
  Future<void> syncPending() async {
    if (!_hasPendingSync || _pendingAction == null) return;
    if (!await _isOnline()) return;

    try {
      await _dio.post('/dtr/$_pendingAction');
      _hasPendingSync = false;
      _pendingAction = null;
      _pendingTime = null;
      _message = 'Offline record synced successfully.';
      await fetchToday();
      notifyListeners();
    } catch (_) {
      // Keep pending, will retry next time
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

  /// Export DTR as CSV and share
  Future<bool> exportDtr({required int month, required int year}) async {
    try {
      final res = await _dio.get('/dtr/export',
          queryParameters: {'month': month, 'year': year},
          options: Options(responseType: ResponseType.bytes));

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/dtr_${year}_$month.csv');
      await file.writeAsBytes(res.data);

      await Share.shareXFiles([XFile(file.path)], text: 'DTR Export - $month/$year');
      return true;
    } catch (_) {
      return false;
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}
