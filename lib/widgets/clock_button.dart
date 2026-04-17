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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Day Complete', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 16)),
          ],
        ),
      );
    }

    final isIn = !isClockedIn;
    return SizedBox(
      width: 160,
      height: 160,
      child: ElevatedButton(
        onPressed: loading ? null : (isIn ? onClockIn : onClockOut),
        style: ElevatedButton.styleFrom(
          backgroundColor: isIn ? AppColors.success : AppColors.danger,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
        ),
        child: loading
            ? const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isIn ? Icons.login : Icons.logout, size: 36),
                  const SizedBox(height: 8),
                  Text(isIn ? 'Clock In' : 'Clock Out', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
