class DailyTimeRecord {
  final int id;
  final String date;
  final String? clockIn;
  final String? clockOut;
  final String status;
  final double? hoursWorked;
  final double? tardinessMinutes;
  final String? clockInMethod;

  DailyTimeRecord({
    required this.id,
    required this.date,
    this.clockIn,
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
  final String? clockOut;
  final String? status;
  final bool isClockedIn;

  TodayDtr({this.clockIn, this.clockOut, this.status, required this.isClockedIn});

  factory TodayDtr.fromJson(Map<String, dynamic> json) {
    return TodayDtr(
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      status: json['status'],
      isClockedIn: json['is_clocked_in'] ?? false,
    );
  }
}
