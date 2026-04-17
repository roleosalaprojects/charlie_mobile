import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api.dart';
import 'providers/auth_provider.dart';
import 'providers/dtr_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/announcement_provider.dart';
import 'providers/notification_provider.dart';
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
import 'utils/helpers.dart';

void main() {
  runApp(const CharlieApp());
}

class CharlieApp extends StatelessWidget {
  const CharlieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DtrProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Charlie HRMS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9F9F9),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.dark,
            elevation: 0.5,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          brightness: Brightness.dark,
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2D2D2D)),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
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
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    // Check if server URL is configured
    final hasUrl = await ApiConfig.hasBaseUrl();
    if (!mounted) return;

    if (!hasUrl) {
      Navigator.pushReplacementNamed(context, '/server-config');
      return;
    }

    // Try biometric login first, then auto-login
    final auth = context.read<AuthProvider>();
    var loggedIn = await auth.tryBiometricLogin();
    if (!loggedIn) {
      loggedIn = await auth.tryAutoLogin();
    }

    if (!mounted) return;

    if (loggedIn) {
      if (auth.mustChangePassword) {
        Navigator.pushReplacementNamed(context, '/change-password');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: AppColors.primary),
            SizedBox(height: 16),
            Text('Charlie HRMS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
