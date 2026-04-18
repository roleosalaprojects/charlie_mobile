class DailyTimeRecord {
  final int id;
  final String date;
  final String? clockIn;
  final String? breakStart;
  final String? breakEnd;
  final String? clockOut;
  final String status;
  final double? hoursWorked;
  final double? tardinessMinutes;
  final String? clockInMethod;

  DailyTimeRecord({
    required this.id,
    required this.date,
    this.clockIn,
    this.breakStart,
    this.breakEnd,
    this.clockOut,
    required this.status,
    this.hoursWorked,
    this.tardinessMinutes,
    this.clockInMethod,
  });

  factory DailyTimeRecord.fromJson(Map<String, dynamic> json) {
    return DailyTimeRecord(
      id: json['id'],
      date: json['date'] ?? '',
      clockIn: json['clock_in'],
      breakStart: json['break_start'],
      breakEnd: json['break_end'],
      clockOut: json['clock_out'],
      status: json['status'] ?? 'absent',
      hoursWorked: _toDouble(json['hours_worked']),
      tardinessMinutes: _toDouble(json['tardiness_minutes']),
      clockInMethod: json['clock_in_method'],
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class TodayDtr {
  final String? clockIn;
  final String? breakStart;
  final String? breakEnd;
  final String? clockOut;
  final String? status;
  final bool isClockedIn;

  TodayDtr({
    this.clockIn,
    this.breakStart,
    this.breakEnd,
    this.clockOut,
    this.status,
    required this.isClockedIn,
  });

  bool get isOnBreak => breakStart != null && breakEnd == null;
  bool get breakDone => breakStart != null && breakEnd != null;
  bool get dayComplete => clockIn != null && clockOut != null;

  factory TodayDtr.fromJson(Map<String, dynamic> json) {
    return TodayDtr(
      clockIn: json['clock_in'],
      breakStart: json['break_start'],
      breakEnd: json['break_end'],
      clockOut: json['clock_out'],
      status: json['status'],
      isClockedIn: json['is_clocked_in'] ?? false,
    );
  }
}
