/// Simple localization for Charlie HRMS.
/// Usage: S.of(context).attendance
class S {
  final String locale;
  S(this.locale);

  static S of(dynamic context) {
    // For now returns English. To switch, save locale preference and
    // read from a provider. This wiring is ready for future expansion.
    return _localizedValues['en']!;
  }

  static final Map<String, S> _localizedValues = {
    'en': _EnStrings(),
    'fil': _FilStrings(),
  };

  // Common
  String get appName => '';
  String get dashboard => '';
  String get attendance => '';
  String get leave => '';
  String get announcements => '';
  String get profile => '';
  String get login => '';
  String get logout => '';
  String get email => '';
  String get password => '';
  String get save => '';
  String get cancel => '';
  String get submit => '';
  String get approve => '';
  String get reject => '';
  String get pending => '';
  String get approved => '';
  String get rejected => '';
  String get clockIn => '';
  String get clockOut => '';
  String get breakOut => '';
  String get breakIn => '';
  String get payslips => '';
  String get loans => '';
  String get overtime => '';
  String get expenses => '';
  String get notifications => '';
  String get settings => '';
  String get fileLeave => '';
  String get teamCalendar => '';
  String get exportCsv => '';
  String get noRecords => '';
}

class _EnStrings extends S {
  _EnStrings() : super('en');
  @override String get appName => 'Charlie HRMS';
  @override String get dashboard => 'Dashboard';
  @override String get attendance => 'Attendance';
  @override String get leave => 'Leave';
  @override String get announcements => 'Announcements';
  @override String get profile => 'Profile';
  @override String get login => 'Login';
  @override String get logout => 'Logout';
  @override String get email => 'Email';
  @override String get password => 'Password';
  @override String get save => 'Save';
  @override String get cancel => 'Cancel';
  @override String get submit => 'Submit';
  @override String get approve => 'Approve';
  @override String get reject => 'Reject';
  @override String get pending => 'Pending';
  @override String get approved => 'Approved';
  @override String get rejected => 'Rejected';
  @override String get clockIn => 'Clock In';
  @override String get clockOut => 'Clock Out';
  @override String get breakOut => 'Break Out';
  @override String get breakIn => 'Break In';
  @override String get payslips => 'Payslips';
  @override String get loans => 'Loans';
  @override String get overtime => 'Overtime';
  @override String get expenses => 'Expenses';
  @override String get notifications => 'Notifications';
  @override String get settings => 'Settings';
  @override String get fileLeave => 'File Leave';
  @override String get teamCalendar => 'Team Calendar';
  @override String get exportCsv => 'Export CSV';
  @override String get noRecords => 'No records found';
}

class _FilStrings extends S {
  _FilStrings() : super('fil');
  @override String get appName => 'Charlie HRMS';
  @override String get dashboard => 'Dashboard';
  @override String get attendance => 'Attendance';
  @override String get leave => 'Leave';
  @override String get announcements => 'Mga Anunsyo';
  @override String get profile => 'Profile';
  @override String get login => 'Mag-login';
  @override String get logout => 'Mag-logout';
  @override String get email => 'Email';
  @override String get password => 'Password';
  @override String get save => 'I-save';
  @override String get cancel => 'Kanselahin';
  @override String get submit => 'Isumite';
  @override String get approve => 'Aprubahan';
  @override String get reject => 'Tanggihan';
  @override String get pending => 'Naghihintay';
  @override String get approved => 'Aprubado';
  @override String get rejected => 'Tinanggihan';
  @override String get clockIn => 'Pumasok';
  @override String get clockOut => 'Umalis';
  @override String get breakOut => 'Break Out';
  @override String get breakIn => 'Break In';
  @override String get payslips => 'Payslip';
  @override String get loans => 'Utang';
  @override String get overtime => 'Overtime';
  @override String get expenses => 'Gastusin';
  @override String get notifications => 'Mga Abiso';
  @override String get settings => 'Settings';
  @override String get fileLeave => 'Mag-file ng Leave';
  @override String get teamCalendar => 'Kalendaryo ng Team';
  @override String get exportCsv => 'I-export ang CSV';
  @override String get noRecords => 'Walang nakitang record';
}
