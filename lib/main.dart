import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api.dart';
import 'providers/auth_provider.dart';
import 'providers/dtr_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/auth/server_config_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/leave/file_leave_screen.dart';
import 'screens/payslips/payslips_screen.dart';
import 'screens/loans/loans_screen.dart';
import 'screens/overtime/file_overtime_screen.dart';
import 'screens/expenses/file_expense_screen.dart';
import 'screens/approvals/approvals_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/overtime/overtime_screen.dart';
import 'screens/leave/team_calendar_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.load();
  runApp(CharlieApp(themeProvider: themeProvider));
}

class CharlieApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const CharlieApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DtrProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => MaterialApp(
          navigatorKey: ApiConfig.navigatorKey,
          title: 'Charlie HRMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: const SplashScreen(),
          routes: {
            '/server-config': (_) => const ServerConfigScreen(),
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const HomeScreen(),
            '/change-password': (_) => const ChangePasswordScreen(),
            '/file-leave': (_) => const FileLeaveScreen(),
            '/payslips': (_) => const PayslipsScreen(),
            '/loans': (_) => const LoansScreen(),
            '/file-overtime': (_) => const FileOvertimeScreen(),
            '/file-expense': (_) => const FileExpenseScreen(),
            '/approvals': (_) => const ApprovalsScreen(),
            '/notifications': (_) => const NotificationsScreen(),
            '/expenses': (_) => const ExpensesScreen(),
            '/overtime': (_) => const OvertimeScreen(),
            '/team-calendar': (_) => const TeamCalendarScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
        ),
      ),
    );
  }
}
