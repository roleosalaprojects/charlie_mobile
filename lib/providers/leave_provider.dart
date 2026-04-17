import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/api.dart';
import '../models/leave.dart';

class LeaveProvider extends ChangeNotifier {
  final Dio _dio = ApiConfig.createDio();
  List<LeaveBalance> _balances = [];
  List<LeaveType> _types = [];
  List<LeaveApplication> _applications = [];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  List<LeaveBalance> get balances => _balances;
  List<LeaveType> get types => _types;
  List<LeaveApplication> get applications => _applications;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> fetchBalances() async {
    try {
      final res = await _dio.get('/leaves/balances');
      _balances = (res.data['data'] as List)
          .map((b) => LeaveBalance.fromJson(b))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchTypes() async {
    try {
      final res = await _dio.get('/leaves/types');
      _types = (res.data['data'] as List)
          .map((t) => LeaveType.fromJson(t))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchApplications({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _applications = [];
    }
    if (!_hasMore || _loading) return;

    _loading = true;
    notifyListeners();

    try {
      final res = await _dio.get('/leaves', queryParameters: {'page': _page});
      final list = (res.data['data'] as List)
          .map((a) => LeaveApplication.fromJson(a))
          .toList();
      _applications.addAll(list);
      _hasMore = res.data['next_page_url'] != null;
      _page++;
      _loading = false;
      notifyListeners();
    } catch (_) {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> fileLeave({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.post('/leaves', data: {
        'leave_type_id': leaveTypeId,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      });
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to file leave.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdraw(int id) async {
    try {
      await _dio.post('/leaves/$id/withdraw');
      _applications.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to withdraw.';
      notifyListeners();
      return false;
    }
  }
}
