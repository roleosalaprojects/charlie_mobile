import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/leave_balance_card.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lp = context.read<LeaveProvider>();
      lp.fetchBalances();
      lp.fetchApplications(refresh: true);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<LeaveProvider>().fetchApplications();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LeaveProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Team Calendar',
            onPressed: () => Navigator.pushNamed(context, '/team-calendar'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-file-leave',
        onPressed: () => Navigator.pushNamed(context, '/file-leave'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await lp.fetchBalances();
          await lp.fetchApplications(refresh: true);
        },
        child: ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(16),
          children: [
            // Balances
            if (lp.balances.isNotEmpty) ...[
              const Text('My Balances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: lp.balances.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => LeaveBalanceCard(balance: lp.balances[i]),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Applications
            const Text('My Applications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (lp.applications.isEmpty && !lp.loading)
              Center(child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No leave applications yet.', style: TextStyle(color: Colors.grey[500])),
              )),

            ...lp.applications.map((la) => Dismissible(
                  key: ValueKey(la.id),
                  direction: la.status == 'pending' ? DismissDirection.endToStart : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.warning,
                    child: const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  confirmDismiss: (_) async {
                    if (la.status != 'pending') return false;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Withdraw Leave?'),
                        content: const Text('This will cancel your pending leave application.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Withdraw', style: TextStyle(color: AppColors.warning))),
                        ],
                      ),
                    );
                    if (confirm != true) return false;
                    final ok = await lp.withdraw(la.id);
                    if (!ok && context.mounted) {
                      AppToast.error(context, 'Failed to withdraw', message: lp.error);
                    }
                    return ok;
                  },
                  onDismissed: (_) {},
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(la.leaveTypeName.isNotEmpty ? la.leaveTypeName : 'Leave #${la.id}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${Fmt.dateShort(la.startDate)} - ${Fmt.dateShort(la.endDate)} (${la.totalDays.toStringAsFixed(1)} days)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor(la.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(la.status.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor(la.status))),
                      ),
                    ),
                  ),
                )),

            if (lp.loading)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}
