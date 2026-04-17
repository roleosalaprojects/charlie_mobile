import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const primary = Color(0xFF009EF7);
  static const success = Color(0xFF50CD89);
  static const warning = Color(0xFFFFC700);
  static const danger = Color(0xFFF1416C);
  static const info = Color(0xFF7239EA);
  static const gray = Color(0xFFB5B5C3);
  static const dark = Color(0xFF3F4254);
  static const lightBg = Color(0xFFF5F5F8);
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
