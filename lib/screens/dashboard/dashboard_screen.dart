import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dtr_provider.dart';
import '../../providers/leave_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/clock_button.dart';
import '../../widgets/leave_balance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dtrProv = context.read<DtrProvider>();
      dtrProv.syncPending(); // sync any offline clock actions
      dtrProv.fetchToday();
      context.read<LeaveProvider>().fetchBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dtr = context.watch<DtrProvider>();
    final leave = context.watch<LeaveProvider>();
    final emp = auth.user?.employee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charlie HRMS'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dtr.fetchToday();
          await leave.fetchBalances();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: emp?.photoUrl != null ? NetworkImage(emp!.photoUrl!) : null,
                      child: emp?.photoUrl == null ? const Icon(Icons.person, size: 28) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${emp?.fullName ?? auth.user?.name ?? ''}!',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (emp?.position != null)
                            Text('${emp!.position} - ${emp.department ?? ''}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clock In/Out
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Today's Attendance", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(DateTime.now().toString().substring(0, 10),
                        style: const TextStyle(fontSize: 12, color: AppColors.gray)),
                    const SizedBox(height: 16),
                    if (dtr.today != null && dtr.today!.clockIn != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _timeChip('In', dtr.today!.clockIn!, AppColors.success),
                          const SizedBox(width: 16),
                          _timeChip('Out', dtr.today!.clockOut ?? '--', AppColors.danger),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    ClockButton(
                      isClockedIn: dtr.today?.isClockedIn ?? false,
                      isCompleted: dtr.today?.clockIn != null && dtr.today?.clockOut != null,
                      loading: dtr.loading,
                      onClockIn: () => dtr.clockIn(),
                      onClockOut: () => dtr.clockOut(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Leave Balances
            if (leave.balances.isNotEmpty) ...[
              const Text('Leave Balances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: leave.balances.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => LeaveBalanceCard(balance: leave.balances[i]),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Quick Actions
            const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickAction(Icons.receipt_long, 'Payslips', '/payslips'),
                _quickAction(Icons.account_balance_wallet, 'Loans', '/loans'),
                _quickAction(Icons.schedule, 'File OT', '/file-overtime'),
                _quickAction(Icons.receipt, 'Expense', '/file-expense'),
                if (auth.user?.isManager ?? false)
                  _quickAction(Icons.approval, 'Approvals', '/approvals'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, String route) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: () => Navigator.pushNamed(context, route),
      backgroundColor: AppColors.primary.withValues(alpha: 0.06),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
    );
  }

  Widget _timeChip(String label, String time, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}
