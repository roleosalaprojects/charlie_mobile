import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class ClockButton extends StatelessWidget {
  final bool isClockedIn;
  final bool isCompleted;
  final bool loading;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;

  const ClockButton({
    super.key,
    required this.isClockedIn,
    required this.isCompleted,
    required this.loading,
    required this.onClockIn,
    required this.onClockOut,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Text('Day Complete', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      );
    }

    final isIn = !isClockedIn;
    final color = isIn ? AppColors.success : AppColors.danger;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: SizedBox(
        width: 140,
        height: 140,
        child: Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: loading ? null : (isIn ? onClockIn : onClockOut),
            child: Center(
              child: loading
                  ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isIn ? Icons.fingerprint : Icons.logout_rounded, size: 38, color: Colors.white),
                        const SizedBox(height: 6),
                        Text(isIn ? 'Clock In' : 'Clock Out',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
