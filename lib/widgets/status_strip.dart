import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dtr_provider.dart';
import '../providers/leave_provider.dart';
import '../providers/notification_provider.dart';
import '../utils/helpers.dart';

/// Horizontally-scrolling strip of at-a-glance status chips shown at the top
/// of the feed. Each chip routes to its detail screen on tap.
class StatusStrip extends StatelessWidget {
  const StatusStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final dtr = context.watch<DtrProvider>();
    final leave = context.watch<LeaveProvider>();
    final notif = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();
    final isManager = auth.user?.isManager ?? false;

    final chips = <_ChipSpec>[];

    // Today DTR
    final today = dtr.today;
    if (today != null) {
      final hasIn = today.clockIn != null;
      chips.add(_ChipSpec(
        icon: hasIn ? Icons.check_circle_rounded : Icons.schedule_outlined,
        label: 'Today',
        value: hasIn ? 'In ${_shortTime(today.clockIn!)}' : 'Not in yet',
        color: hasIn ? AppColors.success : AppColors.gray,
        onTap: () => _goto(context, 1), // DTR tab
      ));
    }

    // Top leave balance (first with non-zero available)
    final topLeave = leave.balances.where((b) => b.available > 0).firstOrNull;
    if (topLeave != null) {
      chips.add(_ChipSpec(
        icon: Icons.beach_access_outlined,
        label: _shortLeaveName(topLeave.leaveType),
        value: '${topLeave.available.toStringAsFixed(0)}d left',
        color: AppColors.info,
        onTap: () => _goto(context, 2), // Leave tab
      ));
    }

    // Pending approvals (managers only)
    if (isManager) {
      chips.add(_ChipSpec(
        icon: Icons.fact_check_outlined,
        label: 'Approvals',
        value: 'Review',
        color: AppColors.warning,
        onTap: () => Navigator.pushNamed(context, '/approvals'),
      ));
    }

    // Notifications (if unread)
    if (notif.unreadCount > 0) {
      chips.add(_ChipSpec(
        icon: Icons.notifications_active_outlined,
        label: 'Alerts',
        value: '${notif.unreadCount} new',
        color: AppColors.danger,
        onTap: () => Navigator.pushNamed(context, '/notifications'),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _StatusChip(spec: chips[i]),
      ),
    );
  }

  void _goto(BuildContext context, int tabIndex) {
    // The HomeScreen exposes a static setter; see home_screen.dart.
    HomeScreenNavigator.jumpToTab(context, tabIndex);
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

  String _shortLeaveName(String name) {
    if (name.isEmpty) return 'Leave';
    final parts = name.split(' ');
    if (parts.length == 1) return name.length > 10 ? name.substring(0, 10) : name;
    return parts.map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
  }
}

class _ChipSpec {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  _ChipSpec({required this.icon, required this.label, required this.value, required this.color, required this.onTap});
}

class _StatusChip extends StatefulWidget {
  final _ChipSpec spec;
  const _StatusChip({required this.spec});

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: spec.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.96 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: const BoxConstraints(minWidth: 120),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: spec.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(spec.icon, size: 18, color: spec.color),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(spec.label, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(spec.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bridge for cross-widget tab switching. HomeScreen installs the callback.
class HomeScreenNavigator {
  static void Function(int)? _jumpTo;

  static void register(void Function(int) fn) => _jumpTo = fn;
  static void unregister() => _jumpTo = null;

  static void jumpToTab(BuildContext _, int index) {
    final fn = _jumpTo;
    if (fn != null) fn(index);
  }
}
