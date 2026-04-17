class LeaveBalance {
  final String leaveType;
  final double entitled;
  final double used;
  final double pending;
  final double available;

  LeaveBalance({
    required this.leaveType,
    required this.entitled,
    required this.used,
    required this.pending,
    required this.available,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      leaveType: json['leave_type'] ?? json['type'] ?? '',
      entitled: _d(json['entitled']),
      used: _d(json['used']),
      pending: _d(json['pending']),
      available: _d(json['available']),
    );
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

class LeaveType {
  final int id;
  final String name;
  final String code;

  LeaveType({required this.id, required this.name, required this.code});

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class LeaveApplication {
  final int id;
  final String? applicationNo;
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final double totalDays;
  final String reason;
  final String status;
  final String? filedAt;
  final Map<String, dynamic>? leaveType;

  LeaveApplication({
    required this.id,
    this.applicationNo,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.filedAt,
    this.leaveType,
  });

  String get leaveTypeName => leaveType?['name'] ?? '';

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    return LeaveApplication(
      id: json['id'],
      applicationNo: json['application_no'],
      leaveTypeId: json['leave_type_id'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalDays: LeaveBalance._d(json['total_days']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      filedAt: json['filed_at'],
      leaveType: json['leave_type'],
    );
  }
}
