import 'package:flutter/material.dart';
import '../models/leave.dart';
import '../utils/helpers.dart';

class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalance balance;

  const LeaveBalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final pct = balance.entitled > 0 ? (balance.available / balance.entitled).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: 135,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(balance.leaveType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(balance.available.toStringAsFixed(0), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(width: 3),
              Text('/ ${balance.entitled.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey[200],
              color: pct > 0.5 ? AppColors.success : (pct > 0.2 ? AppColors.warning : AppColors.danger),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
