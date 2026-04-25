import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final Dio _dio = ApiConfig.createDio();
  List<dynamic> _claims = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _dio.get('/expenses');
      _claims = res.data['data'] ?? [];
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Expense Claims')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-file-expense',
        onPressed: () async {
          await Navigator.pushNamed(context, '/file-expense');
          _fetch();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _claims.isEmpty
                ? ListView(children: const [EmptyState(icon: Icons.receipt_outlined, title: 'No expense claims')])
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _claims.length,
                    itemBuilder: (_, i) {
                      final c = _claims[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: statusColor(c['status'] ?? '').withValues(alpha: 0.15),
                            child: Icon(Icons.receipt, size: 18, color: statusColor(c['status'] ?? '')),
                          ),
                          title: Text(c['claim_no'] ?? '#${c['id']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('${_cat(c['category'])} - P${c['amount']} - ${Fmt.date(c['expense_date'])}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor(c['status'] ?? '').withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text((c['status'] ?? '').toString().toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor(c['status'] ?? ''))),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _cat(dynamic v) => (v ?? '').toString().replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
}
