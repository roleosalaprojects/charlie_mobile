import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/api.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().checkBiometric();
  }

  Future<void> _pickAndUploadPhoto(BuildContext ctx) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: ctx,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () => Navigator.pop(c, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () => Navigator.pop(c, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, maxWidth: 800, imageQuality: 80);
    if (picked == null) return;

    final authProv = ctx.read<AuthProvider>();
    try {
      final dio = ApiConfig.createDio();
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(picked.path, filename: picked.name),
      });
      await dio.post('/profile/photo', data: formData, options: Options(contentType: 'multipart/form-data'));
      if (!ctx.mounted) return;
      AppToast.success(ctx, 'Photo updated');
      authProv.tryAutoLogin();
    } catch (_) {
      if (!ctx.mounted) return;
      AppToast.error(ctx, 'Failed to upload photo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final emp = auth.user?.employee;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photo + name
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _pickAndUploadPhoto(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (emp?.photoUrl?.isNotEmpty ?? false) ? NetworkImage(emp!.photoUrl!) : null,
                        child: (emp?.photoUrl?.isEmpty ?? true) ? const Icon(Icons.person, size: 50) : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(emp?.fullName ?? auth.user?.name ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(emp?.employeeNo ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info cards
          _infoCard('Position', emp?.position ?? '--'),
          _infoCard('Department', emp?.department ?? '--'),
          _infoCard('Branch', emp?.branch ?? '--'),
          _infoCard('Email', auth.user?.email ?? '--'),

          const SizedBox(height: 24),

          // Biometric toggle
          if (auth.biometricAvailable)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint, color: AppColors.primary),
              title: const Text('Biometric Login'),
              subtitle: const Text('Use fingerprint or Face ID'),
              value: auth.biometricEnabled,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              tileColor: Theme.of(context).cardColor,
              onChanged: (v) => auth.setBiometricEnabled(v),
            ),
          if (auth.biometricAvailable) const SizedBox(height: 12),

          // Change Password
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.primary),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: Theme.of(context).cardColor,
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),

          // Settings (theme, server, about)
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.gray),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: Theme.of(context).cardColor,
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const SizedBox(height: 12),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('Logout', style: TextStyle(color: AppColors.danger)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tileColor: AppColors.danger.withValues(alpha: 0.05),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout', style: TextStyle(color: AppColors.danger))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await auth.logout();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
