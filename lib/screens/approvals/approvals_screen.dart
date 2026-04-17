import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../config/api.dart';
import '../../utils/helpers.dart';
import '../../widgets/empty_state.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> with SingleTickerProviderStateMixin {
  final Dio _dio = ApiConfig.createDio();
  late TabController _tabCtrl;
  List<dynamic> _leaves = [];
  List<dynamic> _overtime = [];
  List<dynamic> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() => _loading = true);
    try {
      // Fetch pending items from each endpoint
      final leaveRes = await _dio.get('/leaves', queryParameters: {'page': 1});
      _leaves = (leaveRes.data['data'] as List).where((l) => l['status'] == 'pending').toList();

      final otRes = await _dio.get('/overtime', queryParameters: {'page': 1});
      _overtime = (otRes.data['data'] as List).where((o) => o['status'] == 'pending').toList();

      final expRes = await _dio.get('/expenses', queryParameters: {'page': 1});
      _expenses = (expRes.data['data'] as List).where((e) => e['status'] == 'pending').toList();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _approve(String type, int id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _dio.post('/$type/$id/approve');
      messenger.showSnackBar(const SnackBar(content: Text('Approved'), backgroundColor: AppColors.success));
      _fetchAll();
    } on DioException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.response?.data?['message'] ?? 'Failed'), backgroundColor: AppColors.danger));
    }
  }

  Future<void> _reject(String type, int id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Rejection Reason'),
          content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Enter reason...'), maxLines: 3),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Reject', style: TextStyle(color: AppColors.danger))),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await _dio.post('/$type/$id/reject', data: {'reason': reason});
      messenger.showSnackBar(const SnackBar(content: Text('Rejected'), backgroundColor: AppColors.warning));
      _fetchAll();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Leave (${_leaves.length})'),
            Tab(text: 'OT (${_overtime.length})'),
            Tab(text: 'Expense (${_expenses.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_leaves, 'leaves'),
                _buildList(_overtime, 'overtime'),
                _buildList(_expenses, 'expenses'),
              ],
            ),
    );
  }

  Widget _buildList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      return const EmptyState(icon: Icons.check_circle_outline, title: 'No pending items');
    }
    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_itemTitle(item, type), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(_itemSubtitle(item, type), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => _reject(type, item['id']), child: const Text('Reject', style: TextStyle(color: AppColors.danger))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _approve(type, item['id']),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _itemTitle(dynamic item, String type) {
    switch (type) {
      case 'leaves':
        return item['leave_type']?['name'] ?? 'Leave #${item['id']}';
      case 'overtime':
        return 'OT ${item['request_no'] ?? '#${item['id']}'}';
      case 'expenses':
        return item['claim_no'] ?? 'Expense #${item['id']}';
      default:
        return '#${item['id']}';
    }
  }

  String _itemSubtitle(dynamic item, String type) {
    switch (type) {
      case 'leaves':
        return '${Fmt.dateShort(item['start_date'])} - ${Fmt.dateShort(item['end_date'])} (${item['total_days']} days) - ${item['reason'] ?? ''}';
      case 'overtime':
        return '${Fmt.date(item['date'])} | ${item['planned_start']} - ${item['planned_end']} | ${item['reason'] ?? ''}';
      case 'expenses':
        return '${item['category']} | P${item['amount']} | ${item['description'] ?? ''}';
      default:
        return '';
    }
  }
}
