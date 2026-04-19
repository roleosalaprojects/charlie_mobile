import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load payslips'), backgroundColor: AppColors.danger),
        );
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _sharePayslip(dynamic payslip) async {
    try {
      final res = await _dio.get('/payslips/${payslip['id']}/download',
          options: Options(responseType: ResponseType.bytes));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/payslip_${payslip['id']}.txt');
      await file.writeAsBytes(res.data);
      await Share.shareXFiles([XFile(file.path)], text: 'Payslip');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Payslips')),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _payslips.isEmpty
                ? ListView(children: const [EmptyState(icon: Icons.receipt_long_outlined, title: 'No payslips yet')])
                : ListView.builder(
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
                          trailing: IconButton(
                            icon: const Icon(Icons.share_outlined, size: 20),
                            tooltip: 'Share Payslip',
                            onPressed: () => _sharePayslip(p),
                          ),
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
