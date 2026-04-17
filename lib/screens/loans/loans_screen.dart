import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final Dio _dio = ApiConfig.createDio();
  List<dynamic> _loans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/loans');
      _loans = res.data['data'] ?? [];
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Loans')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? const EmptyState(icon: Icons.money_off_outlined, title: 'No active loans')
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _loans.length,
                    itemBuilder: (_, i) {
                      final l = _loans[i];
                      final type = l['loan_type']?['name'] ?? 'Loan';
                      final balance = double.tryParse(l['outstanding_balance']?.toString() ?? '0') ?? 0;
                      final principal = double.tryParse(l['principal_amount']?.toString() ?? '0') ?? 0;
                      final progress = principal > 0 ? ((principal - balance) / principal).clamp(0.0, 1.0) : 0.0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor(l['status'] ?? '').withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text((l['status'] ?? '').toString().toUpperCase(),
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor(l['status'] ?? ''))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _stat('Principal', 'P${principal.toStringAsFixed(2)}'),
                                  const SizedBox(width: 20),
                                  _stat('Balance', 'P${balance.toStringAsFixed(2)}', color: AppColors.danger),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey[200],
                                color: AppColors.primary,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 4),
                              Text('${(progress * 100).toStringAsFixed(0)}% paid', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _stat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }
}
