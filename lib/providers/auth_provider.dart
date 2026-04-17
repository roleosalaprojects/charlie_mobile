import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../config/api.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio = ApiConfig.createDio();
  final LocalAuthentication _localAuth = LocalAuthentication();
  AppUser? _user;
  bool _loading = false;
  String? _error;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get mustChangePassword => _user?.mustChangePassword ?? false;
  bool get biometricAvailable => _biometricAvailable;
  bool get biometricEnabled => _biometricEnabled;

  Future<void> checkBiometric() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      final saved = await ApiConfig.storage.read(key: 'biometric_enabled');
      _biometricEnabled = saved == 'true';
    } on PlatformException {
      _biometricAvailable = false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await ApiConfig.storage.write(key: 'biometric_enabled', value: enabled.toString());
    notifyListeners();
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Charlie HRMS',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
        'device_name': 'charlie_app',
      });

      final data = res.data;
      await ApiConfig.saveToken(data['token']);
      _user = AppUser.fromJson(data['user'], employeeJson: data['employee']);
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Login failed.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await ApiConfig.getToken();
    if (token == null) return false;

    try {
      final res = await _dio.get('/auth/me');
      final data = res.data;
      _user = AppUser.fromJson(data['user'], employeeJson: data['employee'] is Map ? (data['employee'] as Map<String, dynamic>) : null);
      notifyListeners();
      return true;
    } catch (_) {
      await ApiConfig.clearToken();
      return false;
    }
  }

  /// Auto-login with biometric: requires stored token + biometric pass
  Future<bool> tryBiometricLogin() async {
    await checkBiometric();
    if (!_biometricEnabled || !_biometricAvailable) return false;

    final token = await ApiConfig.getToken();
    if (token == null) return false;

    final authenticated = await authenticateWithBiometric();
    if (!authenticated) return false;

    return await tryAutoLogin();
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await ApiConfig.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _dio.put('/password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      });
      await tryAutoLogin();
      _loading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to change password.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
