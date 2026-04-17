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
    return Employee(
      id: json['id'],
      employeeNo: json['employee_no'] ?? '',
      fullName: json['full_name'] ?? '',
      photoUrl: json['photo_url'],
      position: json['position'],
      department: json['department'],
      branch: json['branch'],
    );
  }
}
