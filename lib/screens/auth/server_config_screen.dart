import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _urlCtrl = TextEditingController();
  bool _testing = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final url = await ApiConfig.getBaseUrl();
    // Strip /api/v1 for display
    _urlCtrl.text = url.replaceAll('/api/v1', '');
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;

    setState(() { _testing = true; _status = null; });

    try {
      var testUrl = url;
      if (testUrl.endsWith('/')) testUrl = testUrl.substring(0, testUrl.length - 1);
      final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 10)));
      await dio.get('$testUrl/api/v1/auth/me');
      // 401 means server is reachable (just not authenticated)
      setState(() { _status = 'connected'; });
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        setState(() { _status = 'connected'; });
      } else {
        setState(() { _status = 'failed'; });
      }
    } catch (_) {
      setState(() { _status = 'failed'; });
    } finally {
      setState(() { _testing = false; });
    }
  }

  Future<void> _save() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) return;

    await ApiConfig.setBaseUrl(url);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.dns_outlined, size: 56, color: AppColors.primary),
                const SizedBox(height: 16),
                Text('Server Setup', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Enter your Charlie HRMS server address', style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                TextField(
                  controller: _urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'Server URL',
                    hintText: 'https://hrms.yourcompany.com',
                    prefixIcon: Icon(Icons.link),
                    border: OutlineInputBorder(),
                    helperText: 'e.g. https://hrms.yourcompany.com or http://192.168.1.100:81',
                  ),
                ),
                const SizedBox(height: 16),

                // Test connection button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _testing ? null : _testConnection,
                    icon: _testing
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_find),
                    label: const Text('Test Connection'),
                  ),
                ),

                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _status == 'connected' ? Icons.check_circle : Icons.error,
                        color: _status == 'connected' ? AppColors.success : AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _status == 'connected' ? 'Server reachable' : 'Cannot reach server',
                        style: TextStyle(
                          color: _status == 'connected' ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
