class AppUser {
  final int id;
  final String name;
  final String email;
  final List<String> roles;
  final bool mustChangePassword;
  final Employee? employee;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.mustChangePassword,
    this.employee,
  });

  factory AppUser.fromJson(Map<String, dynamic> json, {Map<String, dynamic>? employeeJson}) {
    return AppUser(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      mustChangePassword: json['must_change_password'] ?? false,
      employee: employeeJson != null ? Employee.fromJson(employeeJson) : null,
    );
  }

  bool hasRole(String role) => roles.contains(role);
  bool get isAdmin => roles.any((r) => ['super_admin', 'hr_admin', 'payroll_admin'].contains(r));
  bool get isManager => roles.contains('manager') || isAdmin;
}

class Employee {
  final int id;
  final String employeeNo;
  final String fullName;
  final String? photoUrl;
  final String? position;
  final String? department;
  final String? branch;

  Employee({
    required this.id,
    required this.employeeNo,
    required this.fullName,
    this.photoUrl,
    this.position,
    this.department,
    this.branch,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    // Handle both flat (login) and nested (me) formats
    final assignment = _nested(json, ['current_employment', 'current_assignment']);

    return Employee(
      id: json['id'],
      employeeNo: json['employee_no'] ?? '',
      fullName: json['full_name'] ?? _buildName(json),
      photoUrl: json['photo_url'],
      position: json['position'] ?? _nested(assignment, ['position', 'title']),
      department: json['department'] ?? _nested(assignment, ['department', 'name']),
      branch: json['branch'] ?? _nested(assignment, ['branch', 'name']),
    );
  }

  static dynamic _nested(dynamic obj, List<String> keys) {
    dynamic current = obj;
    for (final key in keys) {
      if (current is Map) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  static String _buildName(Map<String, dynamic> json) {
    final first = json['first_name'] ?? '';
    final last = json['last_name'] ?? '';
    if (first.isEmpty && last.isEmpty) return '';
    return '$first $last'.trim();
  }
}
