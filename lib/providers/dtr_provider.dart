import 'dart:io';
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

  TodayDtr? get today => _today;
  List<DailyTimeRecord> get history => _history;

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
}
