import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newCtrl.text.length < 8) {
      AppToast.warning(context, 'Password too short', message: 'Use at least 8 characters.');
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      AppToast.warning(context, 'Passwords do not match');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.changePassword(_currentCtrl.text, _newCtrl.text);

    if (!mounted) return;

    if (success) {
      AppToast.success(context, 'Password updated');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      AppToast.error(context, 'Failed to change password', message: auth.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.warning),
                  SizedBox(width: 12),
                  Expanded(child: Text('You must change your password before continuing.', style: TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder(), helperText: 'Minimum 8 characters'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: auth.loading ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: auth.loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Change Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
