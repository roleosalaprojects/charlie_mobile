import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/api.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';

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
    final hasUrl = await ApiConfig.hasBaseUrl();
    if (!mounted) return;

    if (!hasUrl) {
      Navigator.pushReplacementNamed(context, '/server-config');
      return;
    }

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
        decoration: const BoxDecoration(gradient: AppColors.brandGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
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
