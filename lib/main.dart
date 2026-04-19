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
import 'screens/notifications/notifications_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/overtime/overtime_screen.dart';
import 'screens/leave/team_calendar_screen.dart';
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
        navigatorKey: ApiConfig.navigatorKey,
        title: 'Charlie HRMS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.dark,
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary);
              }
              return TextStyle(fontSize: 11, color: Colors.grey[500]);
            }),
          ),
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: AppColors.primary,
          useMaterial3: true,
          brightness: Brightness.dark,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
          '/notifications': (_) => const NotificationsScreen(),
          '/expenses': (_) => const ExpensesScreen(),
          '/overtime': (_) => const OvertimeScreen(),
          '/team-calendar': (_) => const TeamCalendarScreen(),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0078D4), Color(0xFF00BCF2)]),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20)],
                ),
                child: const Center(child: Text('C', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary))),
              ),
              const SizedBox(height: 20),
              const Text('Charlie HRMS', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
              const SizedBox(height: 28),
              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
