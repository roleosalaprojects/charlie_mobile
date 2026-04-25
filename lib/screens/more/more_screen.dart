import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/leave_balance_card.dart';

/// Action hub — quick shortcuts to file leave/OT/expense, view payslips/loans,
/// manager approvals, team calendar. Replaces the old dashboard.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaveProvider>().fetchBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final leave = context.watch<LeaveProvider>();
    final isManager = auth.user?.isManager ?? false;

    final actions = <_Action>[
      _Action(Icons.event_note_outlined, 'File Leave', AppColors.info, '/file-leave'),
      _Action(Icons.schedule_outlined, 'File OT', AppColors.warning, '/file-overtime'),
      _Action(Icons.receipt_long_outlined, 'File Expense', AppColors.success, '/file-expense'),
      _Action(Icons.receipt_outlined, 'My Payslips', AppColors.primary, '/payslips'),
      _Action(Icons.request_quote_outlined, 'My Loans', AppColors.info, '/loans'),
      _Action(Icons.schedule_outlined, 'My OT', AppColors.warning, '/overtime'),
      _Action(Icons.wallet_outlined, 'My Expenses', AppColors.success, '/expenses'),
      _Action(Icons.calendar_month_outlined, 'Team Calendar', AppColors.primary, '/team-calendar'),
      if (isManager) _Action(Icons.fact_check_outlined, 'Approvals', AppColors.danger, '/approvals'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: RefreshIndicator(
        onRefresh: () => leave.fetchBalances(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Actions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: actions.length,
              itemBuilder: (_, i) => _ActionTile(action: actions[i]),
            ),
            const SizedBox(height: 24),
            if (leave.balances.isNotEmpty) ...[
              const Text('Leave Balances', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray)),
              const SizedBox(height: 12),
              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: leave.balances.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => LeaveBalanceCard(balance: leave.balances[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  _Action(this.icon, this.label, this.color, this.route);
}

class _ActionTile extends StatelessWidget {
  final _Action action;
  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: action.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(action.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.25)),
            ),
          ],
        ),
      ),
    );
  }
}
