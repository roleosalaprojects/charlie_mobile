import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class PayslipsScreen extends StatefulWidget {
  const PayslipsScreen({super.key});

  @override
  State<PayslipsScreen> createState() => _PayslipsScreenState();
}

class _PayslipsScreenState extends State<PayslipsScreen> {
  final Dio _dio = ApiConfig.createDio();
  List<dynamic> _payslips = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/payslips');
      _payslips = res.data['data'] ?? [];
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Payslips')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _payslips.isEmpty
              ? EmptyState(icon: Icons.receipt_long_outlined, title: 'No payslips yet', onAction: _fetch)
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _payslips.length,
                    itemBuilder: (_, i) {
                      final p = _payslips[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.receipt, color: Colors.white, size: 20),
                          ),
                          title: Text('Net Pay: P${_fmt(p['net_pay'])}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Gross: P${_fmt(p['gross_pay'])} | Deductions: P${_fmt(p['total_deductions'])}', style: const TextStyle(fontSize: 12)),
                          trailing: Text('${p['days_worked'] ?? 0} days', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '0.00';
    final d = double.tryParse(v.toString()) ?? 0;
    return d.toStringAsFixed(2);
  }
}
