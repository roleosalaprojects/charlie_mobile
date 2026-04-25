import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF6366F1); // indigo-500
  static const primaryDark = Color(0xFF4F46E5); // indigo-600
  static const accent = Color(0xFF8B5CF6); // violet-500

  // Semantic
  static const success = Color(0xFF10B981); // emerald-500
  static const warning = Color(0xFFF59E0B); // amber-500
  static const danger = Color(0xFFEF4444); // red-500
  static const info = Color(0xFF06B6D4); // cyan-500

  // Neutrals
  static const gray = Color(0xFF94A3B8); // slate-400
  static const dark = Color(0xFF0F172A); // slate-900
  static const muted = Color(0xFF64748B); // slate-500
  static const lightBg = Color(0xFFF8FAFC); // slate-50
  static const scaffoldBg = Color(0xFFF8FAFC);

  /// Indigo → violet brand gradient.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  /// Soft card shadow — use in place of raw boxShadow lists.
  static List<BoxShadow> get softShadow => [
        BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
      ];
}

class Fmt {
  static String date(String? iso) {
    if (iso == null) return '--';
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  static String dateShort(String? iso) {
    if (iso == null) return '--';
    try {
      return DateFormat('MMM dd').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  static String time(String? t) {
    if (t == null) return '--';
    return t;
  }

  static String timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM dd').format(dt);
    } catch (_) {
      return '';
    }
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'present':
      return AppColors.success;
    case 'absent':
      return AppColors.danger;
    case 'on_leave':
      return AppColors.info;
    case 'holiday':
      return AppColors.primary;
    case 'rest_day':
      return AppColors.gray;
    case 'half_day':
      return AppColors.warning;
    case 'approved':
      return AppColors.success;
    case 'pending':
      return AppColors.warning;
    case 'rejected':
      return AppColors.danger;
    case 'withdrawn':
      return AppColors.gray;
    default:
      return AppColors.gray;
  }
}
