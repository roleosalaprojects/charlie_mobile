import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      dtrProv.syncPending();
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
      body: RefreshIndicator(
        onRefresh: () async {
          await dtr.fetchToday();
          await leave.fetchBalances();
        },
        child: CustomScrollView(
          slivers: [
            // Gradient header
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0078D4), Color(0xFF00BCF2)]),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage: (emp?.photoUrl?.isNotEmpty ?? false) ? NetworkImage(emp!.photoUrl!) : null,
                          child: (emp?.photoUrl?.isEmpty ?? true) ? const Icon(Icons.person, size: 24, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, ${emp?.fullName ?? auth.user?.name ?? ''}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                              if (emp?.position != null)
                                Text('${emp!.position}', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Today's date
                    Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(height: 4),
                    // Time chips row
                    if (dtr.today != null && dtr.today!.clockIn != null)
                      Row(
                        children: [
                          _timeTag('In', _shortTime(dtr.today!.clockIn!)),
                          if (dtr.today!.breakStart != null) _timeTag('B.Out', _shortTime(dtr.today!.breakStart!)),
                          if (dtr.today!.breakEnd != null) _timeTag('B.In', _shortTime(dtr.today!.breakEnd!)),
                          if (dtr.today!.clockOut != null) _timeTag('Out', _shortTime(dtr.today!.clockOut!)),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clock button card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: ClockButton(
                            isClockedIn: dtr.today?.isClockedIn ?? false,
                            isCompleted: dtr.today?.dayComplete ?? false,
                            loading: dtr.loading,
                            onClockIn: () => dtr.clockIn(),
                            onClockOut: () => dtr.clockOut(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _quickTile(Icons.event_note_outlined, 'File\nLeave', AppColors.info, '/file-leave'),
                        const SizedBox(width: 10),
                        _quickTile(Icons.schedule_outlined, 'File\nOT', AppColors.warning, '/file-overtime'),
                        const SizedBox(width: 10),
                        _quickTile(Icons.receipt_long_outlined, 'Expense\nClaim', AppColors.success, '/file-expense'),
                        const SizedBox(width: 10),
                        _quickTile(Icons.receipt_outlined, 'My\nPayslips', AppColors.primary, '/payslips'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Leave Balances
                    if (leave.balances.isNotEmpty) ...[
                      const Text('Leave Balances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickTile(IconData icon, String label, Color color, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeTag(String label, String time) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label $time', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }

  String _shortTime(String raw) {
    if (raw == '--') return raw;
    if (!raw.contains('T') && !raw.contains('-')) return raw;
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
    } catch (_) {
      return raw;
    }
  }
}
